import Foundation

/// Story 17.4: Persists the personal best challenge score per Constant.
/// Uses UserDefaults — pattern identical to PersonalBestStore.
@MainActor
class ChallengeScoreStore {
    static let shared = ChallengeScoreStore()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private func key(for constant: Constant) -> String {
        "com.alexandre.pitrainer.challenge.bestScore.\(constant.rawValue)"
    }

    /// Returns the stored best score for the given constant, or nil if never set.
    /// ⚠️ UserDefaults.integer(forKey:) returns 0 for missing keys — must check .object to distinguish.
    func bestScore(for constant: Constant) -> Int? {
        guard defaults.object(forKey: key(for: constant)) != nil else { return nil }
        return defaults.integer(forKey: key(for: constant))
    }

    /// Determines if the given score qualifies as a new personal record.
    /// First score (previousBest == nil) is always a record.
    static func isNewRecord(score: Int, previousBest: Int?) -> Bool {
        guard let best = previousBest else { return true }
        return score > best
    }

    /// Saves the score only if it is strictly better than the current best.
    /// First score is always saved (currentBest == nil).
    func saveBestScore(_ score: Int, for constant: Constant) {
        let current = bestScore(for: constant)
        if Self.isNewRecord(score: score, previousBest: current) {
            defaults.set(score, forKey: key(for: constant))
        }
    }
}
