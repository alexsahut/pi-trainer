import Foundation
import Combine
import SwiftUI

/// Manages the consecutive days of practice (Daily Streak)
@MainActor
class StreakStore: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var lastPracticeDate: Date?
    
    // MARK: - Constants
    
    private let streakKey = "zen_athlete_daily_streak"
    private let lastDateKey = "zen_athlete_last_practice_date"
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    init() {
        loadData()
        refreshStreak()
        setupForegroundObserver()
    }
    
    // MARK: - Private Setup
    
    private func setupForegroundObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshStreak()
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the streak after a successful practice session
    func recordSession() {
        let now = Date()
        
        guard let last = lastPracticeDate else {
            // First time ever
            setStreak(1, date: now)
            return
        }
        
        if calendar.isDateInToday(last) {
            // Already practiced today, keep streak as is but update time (optional)
            saveData()
            return
        }
        
        if calendar.isDateInYesterday(last) {
            // Practiced yesterday, increment streak
            setStreak(currentStreak + 1, date: now)
        } else {
            // Missed a day (or more), reset to 1
            setStreak(1, date: now)
        }
    }
    
    /// Checks if the streak has expired and resets if necessary
    func refreshStreak() {
        guard let last = lastPracticeDate else { return }
        
        // If it's not today AND not yesterday, the streak is broken
        if !calendar.isDateInToday(last) && !calendar.isDateInYesterday(last) {
            setStreak(0, date: last) // Reset but keep the last date to avoid confusion
        }
    }
    
    /// Resets all streak data
    func reset() {
        setStreak(0, date: nil)
    }
    
    // MARK: - Private Methods
    
    private func setStreak(_ value: Int, date: Date?) {
        currentStreak = value
        lastPracticeDate = date
        saveData()
    }
    
    private func loadData() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        if let timestamp = UserDefaults.standard.object(forKey: lastDateKey) as? TimeInterval {
            lastPracticeDate = Date(timeIntervalSince1970: timestamp)
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        if let date = lastPracticeDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastDateKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastDateKey)
        }
    }
    
    #if DEBUG
    /// Internal helper only for unit tests
    func setTestLastDate(_ date: Date) {
        lastPracticeDate = date
        saveData()
    }
    #endif
}
