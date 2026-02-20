//
//  PracticePersistence.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import Foundation

/// Protocol defining persistence operations for practice sessions and statistics.
@MainActor
protocol PracticePersistenceProtocol: AnyObject {
    /// Saves the highest index reached in a practice session for a specific constant.
    func saveHighestIndex(_ index: Int, for constantKey: String)
    /// Retrieves the highest index reached for a specific constant.
    func getHighestIndex(for constantKey: String) -> Int
    
    var userDefaults: UserDefaults { get }
    
    /// Records Persistence (PRs and metadata)
    func saveStats(_ stats: [Constant: ConstantStats])
    func loadStats() -> [Constant: ConstantStats]?
    
    /// User Preferences
    func saveKeypadLayout(_ layout: String)
    func loadKeypadLayout() -> String?
    
    func saveSelectedConstant(_ constant: String)
    func loadSelectedConstant() -> String?
    
    func saveSelectedMode(_ mode: String)
    func loadSelectedMode() -> String?
    
    func saveSelectedGhostType(_ type: String)
    func loadSelectedGhostType() -> String?
    
    // Story 10.1: Auto-Advance Persistence
    func saveAutoAdvance(_ enabled: Bool)
    func loadAutoAdvance() -> Bool?
    
    // Story 11.1: Challenge Persistence
    func saveLastChallengeDate(_ date: Date)
    func loadLastChallengeDate() -> Date?
    
    // Story 11.2: XP Persistence
    func saveTotalCorrectDigits(_ count: Int)
    func loadTotalCorrectDigits() -> Int
}

/// Concrete implementation of PracticePersistence using UserDefaults.
/// This class centralizes all small data persistence to guarantee <1ms access time.
@MainActor
class PracticePersistence: PracticePersistenceProtocol {
    let userDefaults: UserDefaults
    private let highestIndexKeyPrefix = "practice_highest_index_"
    private let statsKey = "com.alexandre.pitrainer.stats"
    private let keypadLayoutKey = "com.alexandre.pitrainer.keypadLayout"
    private let selectedConstantKey = "com.alexandre.pitrainer.selectedConstant"
    private let selectedModeKey = "com.alexandre.pitrainer.selectedMode"
    private let selectedGhostTypeKey = "com.alexandre.pitrainer.selectedGhostType"
    private let autoAdvanceKey = "com.alexandre.pitrainer.autoAdvance"
    private let lastChallengeDateKey = "com.alexandre.pitrainer.lastChallengeDate"
    private let totalCorrectDigitsKey = "com.alexandre.pitrainer.totalCorrectDigits"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Practice Engine Logic
    
    private func highestIndexKey(for constant: String) -> String {
        return highestIndexKeyPrefix + constant
    }
    
    func saveHighestIndex(_ index: Int, for constantKey: String) {
        let storageKey = highestIndexKey(for: constantKey)
        let currentHigh = getHighestIndex(for: constantKey)
        if index > currentHigh {
            userDefaults.set(index, forKey: storageKey)
        }
    }
    
    func getHighestIndex(for constantKey: String) -> Int {
        return userDefaults.integer(forKey: highestIndexKey(for: constantKey))
    }
    
    // MARK: - Stats Logic
    
    func saveStats(_ stats: [Constant: ConstantStats]) {
        if let encoded = try? JSONEncoder().encode(stats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
    }
    
    func loadStats() -> [Constant: ConstantStats]? {
        guard let data = userDefaults.data(forKey: statsKey) else { return nil }
        return try? JSONDecoder().decode([Constant: ConstantStats].self, from: data)
    }
    
    // MARK: - Preferences
    
    func saveKeypadLayout(_ layout: String) {
        userDefaults.set(layout, forKey: keypadLayoutKey)
    }
    
    func loadKeypadLayout() -> String? {
        return userDefaults.string(forKey: keypadLayoutKey)
    }
    
    func saveSelectedConstant(_ constant: String) {
        userDefaults.set(constant, forKey: selectedConstantKey)
    }
    
    func loadSelectedConstant() -> String? {
        return userDefaults.string(forKey: selectedConstantKey)
    }
    
    func saveSelectedMode(_ mode: String) {
        userDefaults.set(mode, forKey: selectedModeKey)
    }
    
    func loadSelectedMode() -> String? {
        return userDefaults.string(forKey: selectedModeKey)
    }
    
    func saveSelectedGhostType(_ type: String) {
        userDefaults.set(type, forKey: selectedGhostTypeKey)
    }
    
    func loadSelectedGhostType() -> String? {
        return userDefaults.string(forKey: selectedGhostTypeKey)
    }
    
    func saveAutoAdvance(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: autoAdvanceKey)
    }
    
    func loadAutoAdvance() -> Bool? {
        // Return nil if not set, allows default handling in Store
        guard userDefaults.object(forKey: autoAdvanceKey) != nil else { return nil }
        return userDefaults.bool(forKey: autoAdvanceKey)
    }
    
    // MARK: - Challenge Persistence
    
    func saveLastChallengeDate(_ date: Date) {
        userDefaults.set(date, forKey: lastChallengeDateKey)
    }
    
    func loadLastChallengeDate() -> Date? {
        return userDefaults.object(forKey: lastChallengeDateKey) as? Date
    }
    
    // MARK: - XP Persistence
    
    func saveTotalCorrectDigits(_ count: Int) {
        userDefaults.set(count, forKey: totalCorrectDigitsKey)
    }
    
    func loadTotalCorrectDigits() -> Int {
        return userDefaults.integer(forKey: totalCorrectDigitsKey)
    }
}
