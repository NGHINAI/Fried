import StoreKit
import SwiftUI

/// StoreKit 2 — a single non-consumable "Lifetime Unlock". Source of truth for
/// access is `Transaction.currentEntitlements`. Also supports a local
/// "invite to unlock" path (no payment), the viral alternative to buying.
@MainActor
final class Store: ObservableObject {
    static let lifetimeID = "com.fried.app.lifetime"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchased = false
    @Published var invitedUnlock = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
        Task { await loadProducts(); await refresh() }
    }
    deinit { updatesTask?.cancel() }

    /// The single gate the rest of the app reads.
    var hasAccess: Bool { isPurchased || invitedUnlock }

    var lifetime: Product? { products.first { $0.id == Self.lifetimeID } }
    var priceText: String { lifetime?.displayPrice ?? "$4.99" }

    func loadProducts() async {
        do { products = try await Product.products(for: [Self.lifetimeID]) }
        catch { print("[Store] load failed: \(error)") }
    }

    @discardableResult
    func purchase() async -> Bool {
        guard let product = lifetime else { return false }
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

    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }

    func refresh() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if let t = try? checkVerified(result),
               t.productID == Self.lifetimeID, t.revocationDate == nil {
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
