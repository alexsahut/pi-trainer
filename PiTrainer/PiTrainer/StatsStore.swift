//
//  StatsStore.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation
import Combine

/// Detailed record of a practice session
struct SessionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let constant: Constant
    let mode: PracticeEngine.Mode
    let attempts: Int
    let errors: Int
    let bestStreakInSession: Int
    let durationSeconds: TimeInterval
    let digitsPerMinute: Double
    
    // Legacy support init (if needed) or convenience
}

/// Statistics specific to a single constant
struct ConstantStats: Codable, Equatable {
    var bestStreak: Int
    var lastSession: SessionRecord?
    var sessionHistory: [SessionRecord]
    
    static let empty = ConstantStats(bestStreak: 0, lastSession: nil, sessionHistory: [])
}

/// Manages persistence of statistics and global records
class StatsStore: ObservableObject {
    
    // MARK: - Constants
    
    private let statsKey = "com.alexandre.pitrainer.stats"
    // Legacy keys for migration
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
    private let maxHistoryCount = 200
    
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
    func lastSession(for constant: Constant) -> SessionRecord? {
        return stats(for: constant).lastSession
    }
    
    /// Returns the history for a specific constant, most recent first
    func history(for constant: Constant) -> [SessionRecord] {
        return stats(for: constant).sessionHistory
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
    
    /// Adds a new session record to history and updates stats
    /// - Parameter record: The session record to add
    func addSessionRecord(_ record: SessionRecord) {
        var currentStats = stats(for: record.constant)
        
        // Update last session
        currentStats.lastSession = record
        
        // Update best streak if needed
        if record.bestStreakInSession > currentStats.bestStreak {
            currentStats.bestStreak = record.bestStreakInSession
        }
        
        // Add to history (FIFO, max 200)
        // We prepend to keep list sorted by date desc if needed, or just append and sort later.
        // Requirement says "History", usually viewed newest first.
        // Let's modify to prepend for "Recent Sessions" view easily.
        currentStats.sessionHistory.insert(record, at: 0)
        
        if currentStats.sessionHistory.count > maxHistoryCount {
            currentStats.sessionHistory = Array(currentStats.sessionHistory.prefix(maxHistoryCount))
        }
        
        stats[record.constant] = currentStats
        persistStats()
    }
    
    /// Clears the history for a specific constant (but keeps best streak)
    func clearHistory(for constant: Constant) {
        var currentStats = stats(for: constant)
        currentStats.sessionHistory = []
        currentStats.lastSession = nil // Should we clear last session too? Usually yes if clearing history.
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
        // Define temporary legacy struct for migration
        struct LegacySessionSnapshot: Codable {
            let attempts: Int
            let errors: Int
            let bestStreak: Int
            let elapsedTime: TimeInterval
            let digitsPerMinute: Double
            let date: Date
        }
        
        // Check if legacy keys exist
        let hasLegacyData = userDefaults.object(forKey: legacyGlobalBestStreakKey) != nil ||
                            userDefaults.object(forKey: legacyLastSessionKey) != nil
        
        if hasLegacyData {
            let legacyStreak = userDefaults.integer(forKey: legacyGlobalBestStreakKey)
            
            var legacySessionRecord: SessionRecord?
            if let sessionData = userDefaults.data(forKey: legacyLastSessionKey),
               let session = try? JSONDecoder().decode(LegacySessionSnapshot.self, from: sessionData) {
                
                // Convert LegacySessionSnapshot to SessionRecord
                // Assuming legacy was strictly strict mode or unknown, we'll default to strict
                legacySessionRecord = SessionRecord(
                    id: UUID(),
                    date: session.date,
                    constant: .pi, // Legacy only supported Pi
                    mode: .strict, // Default assumption
                    attempts: session.attempts,
                    errors: session.errors,
                    bestStreakInSession: session.bestStreak,
                    durationSeconds: session.elapsedTime,
                    digitsPerMinute: session.digitsPerMinute
                )
            }
            
            // Migrate to .pi
            var piStats = ConstantStats.empty
            piStats.bestStreak = legacyStreak
            if let rec = legacySessionRecord {
                piStats.lastSession = rec
                piStats.sessionHistory = [rec]
            }
            
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
