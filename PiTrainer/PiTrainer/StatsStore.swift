//
//  StatsStore.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation
import Combine

/// Simple statistics for a practice session
struct SessionSnapshot: Codable, Equatable {
    let attempts: Int
    let errors: Int
    let bestStreak: Int
    let elapsedTime: TimeInterval
    let digitsPerMinute: Double
    let date: Date
}

/// Stats specific to a single constant
struct ConstantStats: Codable, Equatable {
    var bestStreak: Int
    var lastSession: SessionSnapshot?
    
    static let empty = ConstantStats(bestStreak: 0, lastSession: nil)
}

/// Manages persistence of statistics and global records
class StatsStore: ObservableObject {
    
    // MARK: - Constants
    
    private let statsKey = "com.alexandre.pitrainer.stats"
    private let legacyGlobalBestStreakKey = "com.alexandre.pitrainer.globalBestStreak"
    private let legacyLastSessionKey = "com.alexandre.pitrainer.lastSession"
    private let keypadLayoutKey = "com.alexandre.pitrainer.keypadLayout"
    private let selectedConstantKey = "com.alexandre.pitrainer.selectedConstant"
    
    // MARK: - Published Properties
    
    @Published private(set) var stats: [Constant: ConstantStats] = [:]
    
    @Published var keypadLayout: KeypadLayout = .phone {
        didSet {
            userDefaults.set(keypadLayout.rawValue, forKey: keypadLayoutKey)
        }
    }
    
    @Published var selectedConstant: Constant = .pi {
        didSet {
            userDefaults.set(selectedConstant.rawValue, forKey: selectedConstantKey)
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadStats()
    }
    
    // MARK: - Public Methods
    
    /// Returns stats for a specific constant (or empty default)
    func stats(for constant: Constant) -> ConstantStats {
        return stats[constant] ?? .empty
    }
    
    /// Helper to get best streak for the currently selected constant (or any other)
    func bestStreak(for constant: Constant) -> Int {
        return stats(for: constant).bestStreak
    }
    
    /// Helper to get last session for the currently selected constant (or any other)
    func lastSession(for constant: Constant) -> SessionSnapshot? {
        return stats(for: constant).lastSession
    }

    /// Updates the best streak for a constant if the new value is higher
    /// - Parameter streak: The streak to compare
    /// - Parameter constant: The constant to update
    func updateBestStreakIfNeeded(_ streak: Int, for constant: Constant) {
        var currentStats = stats(for: constant)
        if streak > currentStats.bestStreak {
            currentStats.bestStreak = streak
            stats[constant] = currentStats
            persistStats()
        }
    }
    
    /// Saves the last session statistics for a specific constant
    /// - Parameter snapshot: The session snapshot to save
    /// - Parameter constant: The constant for which the session was played
    func saveSession(_ snapshot: SessionSnapshot, for constant: Constant) {
        var currentStats = stats(for: constant)
        currentStats.lastSession = snapshot
        
        // Also update best streak if needed (local check against current stats)
        if snapshot.bestStreak > currentStats.bestStreak {
            currentStats.bestStreak = snapshot.bestStreak
        }
        
        stats[constant] = currentStats
        persistStats()
    }
    
    /// Resets all statistics (for debugging or user request)
    func reset() {
        stats = [:]
        userDefaults.removeObject(forKey: statsKey)
    }
    
    // MARK: - Private Methods
    
    private func loadStats() {
        // 1. Load basic preferences
        if let layoutString = userDefaults.string(forKey: keypadLayoutKey),
           let layout = KeypadLayout(rawValue: layoutString) {
            keypadLayout = layout
        } else {
            keypadLayout = .phone
        }
        
        if let constantString = userDefaults.string(forKey: selectedConstantKey),
           let constant = Constant(rawValue: constantString) {
            selectedConstant = constant
        } else {
            selectedConstant = .pi
        }
        
        // 2. Load Stats
        if let data = userDefaults.data(forKey: statsKey),
           let decodedStats = try? JSONDecoder().decode([Constant: ConstantStats].self, from: data) {
            stats = decodedStats
        } else {
            // Check for migration
            migrateIfNeeded()
        }
    }
    
    private func migrateIfNeeded() {
        // Check if legacy keys exist
        let hasLegacyData = userDefaults.object(forKey: legacyGlobalBestStreakKey) != nil ||
                            userDefaults.object(forKey: legacyLastSessionKey) != nil
        
        if hasLegacyData {
            let legacyStreak = userDefaults.integer(forKey: legacyGlobalBestStreakKey)
            
            var legacySession: SessionSnapshot?
            if let sessionData = userDefaults.data(forKey: legacyLastSessionKey),
               let session = try? JSONDecoder().decode(SessionSnapshot.self, from: sessionData) {
                legacySession = session
            }
            
            // Migrate to .pi
            let piStats = ConstantStats(bestStreak: legacyStreak, lastSession: legacySession)
            stats[.pi] = piStats
            persistStats()
            
            // Cleanup legacy keys
            userDefaults.removeObject(forKey: legacyGlobalBestStreakKey)
            userDefaults.removeObject(forKey: legacyLastSessionKey)
        }
    }
    
    private func persistStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
    }
}
