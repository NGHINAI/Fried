import StoreKit
import SwiftUI

/// StoreKit 2 with a 3-tier discount ladder (full / 50% off / 80% off), all
/// non-consumables that grant the same lifetime access. Source of truth is
/// `Transaction.currentEntitlements`. Also supports a local invite-to-unlock.
@MainActor
final class Store: ObservableObject {

    enum Discount: Int, CaseIterable {
        case full = 0, off50 = 1, off80 = 2

        var id: String {
            switch self {
            case .full:  return "com.fried.app.lifetime"
            case .off50: return "com.fried.app.lifetime.off50"
            case .off80: return "com.fried.app.lifetime.off80"
            }
        }
        var badge: String? {
            switch self {
            case .full:  return nil
            case .off50: return "50% OFF"
            case .off80: return "80% OFF — FINAL"
            }
        }
        var defaultPrice: String {
            switch self {
            case .full:  return "$4.99"
            case .off50: return "$2.49"
            case .off80: return "$0.99"
            }
        }
        var next: Discount? { Discount(rawValue: rawValue + 1) }
    }

    static let allIDs = Discount.allCases.map(\.id)

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchased = false
    @Published var invitedUnlock = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
        Task { await loadProducts(); await refresh() }
        if ProcessInfo.processInfo.environment["FRIED_PREVIEW_UNLOCK"] == "1" { invitedUnlock = true }
    }
    deinit { updatesTask?.cancel() }

    var hasAccess: Bool { isPurchased || invitedUnlock }

    func product(_ d: Discount) -> Product? { products.first { $0.id == d.id } }
    func priceText(_ d: Discount) -> String { product(d)?.displayPrice ?? d.defaultPrice }
    var fullPriceText: String { priceText(.full) }

    func loadProducts() async {
        products = (try? await Product.products(for: Self.allIDs)) ?? []
    }

    @discardableResult
    func purchase(_ d: Discount) async -> Bool {
        guard let product = product(d) else { return false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refresh()
                await transaction.finish()
                return true
            default:
                return false
            }
        } catch {
            print("[Store] purchase failed: \(error)")
            return false
        }
    }

    func restore() async { try? await AppStore.sync(); await refresh() }

    func refresh() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if let t = try? checkVerified(result),
               Self.allIDs.contains(t.productID), t.revocationDate == nil {
                owned = true
            }
        }
        isPurchased = owned
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let t = try? self.checkVerified(result) {
                    await self.refresh()
                    await t.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified(_, let error): throw error
        }
    }
}
