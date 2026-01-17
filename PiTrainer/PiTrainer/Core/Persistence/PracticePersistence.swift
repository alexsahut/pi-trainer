//
//  PracticePersistence.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import Foundation

/// Protocol defining persistence operations for practice sessions and statistics.
protocol PracticePersistenceProtocol {
    /// Saves the highest index reached in a practice session for a specific constant.
    func saveHighestIndex(_ index: Int, for constantKey: String)
    /// Retrieves the highest index reached for a specific constant.
    func getHighestIndex(for constantKey: String) -> Int
    
    /// Records Persistence (PBs and metadata)
    func saveStats(_ stats: [Constant: ConstantStats])
    func loadStats() -> [Constant: ConstantStats]?
    
    /// User Preferences
    func saveKeypadLayout(_ layout: String)
    func loadKeypadLayout() -> String?
    
    func saveSelectedConstant(_ constant: String)
    func loadSelectedConstant() -> String?
}

/// Concrete implementation of PracticePersistence using UserDefaults.
/// This class centralizes all small data persistence to guarantee <1ms access time.
class PracticePersistence: PracticePersistenceProtocol {
    private let userDefaults: UserDefaults
    private let highestIndexKeyPrefix = "practice_highest_index_"
    private let statsKey = "com.alexandre.pitrainer.stats"
    private let keypadLayoutKey = "com.alexandre.pitrainer.keypadLayout"
    private let selectedConstantKey = "com.alexandre.pitrainer.selectedConstant"
    
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
}
