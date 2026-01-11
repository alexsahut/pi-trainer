//
//  StatsStore.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation
import Combine

/// Simple statistics for a practice session
struct SessionSnapshot: Codable {
    let attempts: Int
    let errors: Int
    let bestStreak: Int
    let elapsedTime: TimeInterval
    let digitsPerMinute: Double
    let date: Date
}

/// Manages persistence of statistics and global records
class StatsStore: ObservableObject {
    
    // MARK: - Constants
    
    private let globalBestStreakKey = "com.alexandre.pitrainer.globalBestStreak"
    private let lastSessionKey = "com.alexandre.pitrainer.lastSession"
    private let keypadLayoutKey = "com.alexandre.pitrainer.keypadLayout"
    
    // MARK: - Published Properties
    
    @Published private(set) var globalBestStreak: Int = 0
    @Published private(set) var lastSession: SessionSnapshot?
    @Published var keypadLayout: KeypadLayout = .phone {
        didSet {
            UserDefaults.standard.set(keypadLayout.rawValue, forKey: keypadLayoutKey)
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadStats()
    }
    
    // MARK: - Public Methods
    
    /// Updates the global best streak if the new value is higher
    /// - Parameter streak: The streak to compare
    func updateBestStreakIfNeeded(_ streak: Int) {
        if streak > globalBestStreak {
            globalBestStreak = streak
            UserDefaults.standard.set(globalBestStreak, forKey: globalBestStreakKey)
        }
    }
    
    /// Saves the last session statistics
    /// - Parameter snapshot: The session snapshot to save
    func saveSession(_ snapshot: SessionSnapshot) {
        lastSession = snapshot
        
        if let encoded = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(encoded, forKey: lastSessionKey)
        }
        
        updateBestStreakIfNeeded(snapshot.bestStreak)
    }
    
    /// Resets all statistics (for debugging or user request)
    func reset() {
        globalBestStreak = 0
        lastSession = nil
        UserDefaults.standard.removeObject(forKey: globalBestStreakKey)
        UserDefaults.standard.removeObject(forKey: lastSessionKey)
    }
    
    // MARK: - Private Methods
    
    private func loadStats() {
        globalBestStreak = UserDefaults.standard.integer(forKey: globalBestStreakKey)
        
        if let data = UserDefaults.standard.data(forKey: lastSessionKey),
           let snapshot = try? JSONDecoder().decode(SessionSnapshot.self, from: data) {
            lastSession = snapshot
        }
        
        if let layoutString = UserDefaults.standard.string(forKey: keypadLayoutKey),
           let layout = KeypadLayout(rawValue: layoutString) {
            keypadLayout = layout
        } else {
            keypadLayout = .phone
        }
    }
}
