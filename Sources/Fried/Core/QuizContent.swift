import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let answers: [String]   // index 0 = least fried … last = most fried
}

/// 6 subjective, playful questions. Subjective-by-design keeps us clear of App Review 1.1.6.
enum QuizContent {
    static let maxIndex = 3
    static let questions: [QuizQuestion] = [
        .init(prompt: "How much short-form video a day?",
              answers: ["Barely any", "An hour-ish", "2–3 hours", "I've lost count"]),
        .init(prompt: "Can you watch a movie without your phone?",
              answers: ["Easily", "If it's good", "I'll peek", "No chance"]),
        .init(prompt: "Tabs open right now?",
              answers: ["Under 5", "A healthy mess", "20+", "My phone begs for mercy"]),
        .init(prompt: "First thing you touch when you wake up?",
              answers: ["Not my phone", "Alarm, then up", "A quick scroll", "I'm already on it"]),
        .init(prompt: "Do you finish what you start?",
              answers: ["Always", "Mostly", "Sometimes", "What were we doing"]),
        .init(prompt: "Pick your poison.",
              answers: ["None, really", "YouTube", "Reels / Insta", "TikTok / Shorts"])
    ]
}
