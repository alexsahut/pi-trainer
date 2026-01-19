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
    let sessionMode: SessionMode // Story 8.5: Accurate mode tracking
    let attempts: Int
    let errors: Int
    let bestStreakInSession: Int
    let durationSeconds: TimeInterval
    let digitsPerMinute: Double
    let revealsUsed: Int
    let minCPS: Double?
    let maxCPS: Double?
    
    // Story 8.6: Enhanced Learn Mode tracking
    let segmentStart: Int?
    let segmentEnd: Int?
    let loops: Int
    
    var cps: Double {
        digitsPerMinute / 60.0
    }
    
    // Custom decoder for backward compatibility (Story 6.2 & 8.5)
    enum CodingKeys: String, CodingKey {
        case id, date, constant, mode, sessionMode, attempts, errors, bestStreakInSession, durationSeconds, digitsPerMinute, revealsUsed, minCPS, maxCPS, segmentStart, segmentEnd, loops
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        constant = try container.decode(Constant.self, forKey: .constant)
        mode = try container.decode(PracticeEngine.Mode.self, forKey: .mode)
        
        // Story 8.5: If sessionMode is missing, infer it from legacy mode
        if let sMode = try container.decodeIfPresent(SessionMode.self, forKey: .sessionMode) {
            sessionMode = sMode
        } else {
            sessionMode = (mode == .strict) ? .test : .practice
        }
        
        attempts = try container.decode(Int.self, forKey: .attempts)
        errors = try container.decode(Int.self, forKey: .errors)
        bestStreakInSession = try container.decode(Int.self, forKey: .bestStreakInSession)
        durationSeconds = try container.decode(TimeInterval.self, forKey: .durationSeconds)
        digitsPerMinute = try container.decode(Double.self, forKey: .digitsPerMinute)
        // Default to 0 for records created before Epic 6
        revealsUsed = try container.decodeIfPresent(Int.self, forKey: .revealsUsed) ?? 0
        minCPS = try container.decodeIfPresent(Double.self, forKey: .minCPS)
        maxCPS = try container.decodeIfPresent(Double.self, forKey: .maxCPS)
        
        // Story 8.6: Default values for legacy records
        segmentStart = try container.decodeIfPresent(Int.self, forKey: .segmentStart)
        segmentEnd = try container.decodeIfPresent(Int.self, forKey: .segmentEnd)
        loops = try container.decodeIfPresent(Int.self, forKey: .loops) ?? 0
    }
    
    init(id: UUID, date: Date, constant: Constant, mode: PracticeEngine.Mode, sessionMode: SessionMode, attempts: Int, errors: Int, bestStreakInSession: Int, durationSeconds: TimeInterval, digitsPerMinute: Double, revealsUsed: Int = 0, minCPS: Double? = nil, maxCPS: Double? = nil, segmentStart: Int? = nil, segmentEnd: Int? = nil, loops: Int = 0) {
        self.id = id
        self.date = date
        self.constant = constant
        self.mode = mode
        self.sessionMode = sessionMode
        self.attempts = attempts
        self.errors = errors
        self.bestStreakInSession = bestStreakInSession
        self.durationSeconds = durationSeconds
        self.digitsPerMinute = digitsPerMinute
        self.revealsUsed = revealsUsed
        self.minCPS = minCPS
        self.maxCPS = maxCPS
        self.segmentStart = segmentStart
        self.segmentEnd = segmentEnd
        self.loops = loops
    }
}

/// Statistics specific to a single constant
struct ConstantStats: Codable, Equatable {
    var bestStreak: Int
    var bestSession: SessionRecord? // Added to track PR metadata (time, date, etc.)
    var lastSession: SessionRecord?
    // sessionHistory is now managed by SessionHistoryStore
    
    static let empty = ConstantStats(bestStreak: 0, bestSession: nil, lastSession: nil)
}

/// Manages persistence of statistics and global records
@MainActor
class StatsStore: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var stats: [Constant: ConstantStats] = [:]
    
    /// Cached history to avoid repeated file reads. 
    /// Keyed by constant.
    @Published private(set) var historyCache: [Constant: [SessionRecord]] = [:]
    
    /// Indicates if history is currently being loaded for the selected constant
    @Published private(set) var isHistoryLoading: Bool = false
    
    @Published var keypadLayout: KeypadLayout = .phone {
        didSet {
            persistence.saveKeypadLayout(keypadLayout.rawValue)
        }
    }
    
    func hello() { print("DEBUG: StatsStore hello") }
    
    
    @Published var selectedConstant: Constant = .pi {
        didSet {
            persistence.saveSelectedConstant(selectedConstant.rawValue)
            // Proactive load to avoid UI flashing
            loadHistoryEagerly(for: selectedConstant)
        }
    }
    

    
    @Published var selectedMode: SessionMode = .learn {
        didSet {
            // persistence.saveSelectedMode(selectedMode.rawValue)
            UserDefaults.standard.set(selectedMode.rawValue, forKey: "selectedMode")
        }
    }
    
    // MARK: - Private Properties
    
    private let persistence: PracticePersistenceProtocol
    private let historyStore: SessionHistoryStore
    let streakStore: StreakStore
    
    // MARK: - Initialization
    
    init(persistence: PracticePersistenceProtocol = PracticePersistence(), 
         historyStore: SessionHistoryStore? = nil) {
        self.persistence = persistence
        
        // Handle throwing initializer of SessionHistoryStore
        if let providedStore = historyStore {
            self.historyStore = providedStore
        } else {
            do {
                self.historyStore = try SessionHistoryStore()
            } catch {
                // FALLBACK: Log error but do NOT crash. 
                print("⚠️ CRITICAL: Failed to initialize SessionHistoryStore: \(error)")
                // Create a temporary store as fallback without try!
                let fallbackURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try? FileManager.default.createDirectory(at: fallbackURL, withIntermediateDirectories: true)
                self.historyStore = (try? SessionHistoryStore(customDirectory: fallbackURL)) ?? (try! SessionHistoryStore(customDirectory: fallbackURL)) 
            }
        }
        
        self.streakStore = StreakStore()
        
        loadStats()
        loadHistoryEagerly(for: selectedConstant)
        
        // Story 8.5: Recovery check - Ensure stats are in sync with history
        Task { @MainActor in
            await repairStatsFromHistory()
        }
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
    
    /// Returns the history for a specific constant, most recent first.
    /// This returns the cache immediately. Use loadHistory(for:) to refresh.
    func history(for constant: Constant) -> [SessionRecord] {
        return historyCache[constant] ?? []
    }

    /// Explicitly loads or refreszes history for a constant.
    @MainActor
    func loadHistory(for constant: Constant) async {
        isHistoryLoading = true
        defer { isHistoryLoading = false }
        
        do {
            let records = try await historyStore.loadHistory(for: constant)
            self.historyCache[constant] = records
            print("debug: loaded \(records.count) records for \(constant)")
        } catch {
            print("❌ Error loading history for \(constant): \(error)")
        }
    }
    
    private func loadHistoryEagerly(for constant: Constant) {
        Task { @MainActor in
            await loadHistory(for: constant)
        }
    }

    /// Updates the best streak for a constant if the new value is higher
    func updateBestStreakIfNeeded(_ streak: Int, for constant: Constant) {
        var currentStats = stats(for: constant)
        if streak > currentStats.bestStreak {
            currentStats.bestStreak = streak
            stats[constant] = currentStats
            persistStats()
        }
    }
    
    /// Adds a new session record to history and updates stats
    func addSessionRecord(_ record: SessionRecord) {
        print("debug: StatsStore adding record for \(record.constant) - streak: \(record.bestStreakInSession), loops: \(record.loops), segment: \(record.segmentStart ?? -1)-\(record.segmentEnd ?? -1)")
        var currentStats = stats(for: record.constant)
        
        // Update last session
        currentStats.lastSession = record
        
        // Update best streak and BEST session if needed
        // Fix for Story 8.5: Exclude Learn Mode from Best Streak calculation
        if record.sessionMode != .learn {
            if record.bestStreakInSession > currentStats.bestStreak {
                print("debug: new record streak! \(record.bestStreakInSession) > \(currentStats.bestStreak)")
                currentStats.bestStreak = record.bestStreakInSession
                currentStats.bestSession = record
            } else if record.bestStreakInSession == currentStats.bestStreak {
                // Optional: If same streak, keep the faster one or the most recent?
                // Let's keep the most recent for now to update metadata.
                currentStats.bestSession = record
            }
        }

        
        stats[record.constant] = currentStats
        persistStats()
        
        // Update history (Async & Atomic)
        Task { @MainActor in
            do {
                let updatedHistory = try await historyStore.appendRecord(record, for: record.constant)
                self.historyCache[record.constant] = updatedHistory
                print("debug: history updated, new count for \(record.constant): \(updatedHistory.count)")
                
                // Story 5.1: Update Daily Streak
                streakStore.recordSession()
                
                // Story 5.3: Update Daily Reminder
                NotificationService.shared.scheduleDailyReminder(streak: streakStore.currentStreak)
            } catch {
                // Log error or handle
                print("Failed to append record: \(error)")
            }
        }
    }
    
    /// Clears the history for a specific constant (but keeps best streak)
    func clearHistory(for constant: Constant) {
        var currentStats = stats(for: constant)
        currentStats.lastSession = nil
        stats[constant] = currentStats
        persistStats()
        
        // Clear history file and cache
        historyCache[constant] = []
        Task { @MainActor in
            try? await historyStore.saveHistory([], for: constant)
        }
    }
    
    /// Resets all statistics (for debugging or user request)
    func reset() {
        stats = [:]
        persistence.saveStats([:])
        
        // Clear all history files
        Task { @MainActor in
            try? await historyStore.clearAllHistory()
            self.historyCache = [:]
            streakStore.reset()
            NotificationService.shared.cancelPendingReminders()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadStats() {
        // 1. Load basic preferences
        if let layoutString = persistence.loadKeypadLayout(),
           let layout = KeypadLayout(rawValue: layoutString) {
            keypadLayout = layout
        } else {
            keypadLayout = .phone
        }
        
        if let constantString = persistence.loadSelectedConstant(),
           let constant = Constant(rawValue: constantString) {
            selectedConstant = constant
        } else {
            selectedConstant = .pi
        }
        

        
        if let modeString = persistence.loadSelectedMode(),
           let mode = SessionMode(rawValue: modeString) {
            selectedMode = mode
        } else {
            // New V2 default is .learn
            selectedMode = .learn
        }
        
        // 2. Load Stats
        if let decodedStats = persistence.loadStats() {
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
        
        // Check if legacy keys exist in UserDefaults directly (one last time)
        // Check if legacy keys exist in UserDefaults directly (one last time)
        let legacyUserDefaults = UserDefaults.standard
        let hasLegacyData = legacyUserDefaults.object(forKey: "com.alexandre.pitrainer.globalBestStreak") != nil ||
                           legacyUserDefaults.object(forKey: "com.alexandre.pitrainer.lastSession") != nil
        
        if hasLegacyData {
            let legacyStreak = legacyUserDefaults.integer(forKey: "com.alexandre.pitrainer.globalBestStreak")
            
            var legacySessionRecord: SessionRecord?
            if let sessionData = legacyUserDefaults.data(forKey: "com.alexandre.pitrainer.lastSession"),
               let session = try? JSONDecoder().decode(LegacySessionSnapshot.self, from: sessionData) {
                
                    legacySessionRecord = SessionRecord(
                        id: UUID(),
                        date: session.date,
                        constant: .pi,
                        mode: .strict, // Map .test back to .strict for legacy engine
                        sessionMode: .test,
                        attempts: session.attempts,
                        errors: session.errors,
                        bestStreakInSession: session.bestStreak,
                        durationSeconds: session.elapsedTime,
                        digitsPerMinute: session.digitsPerMinute,
                        revealsUsed: 0
                    )
            }
            
            var piStats = ConstantStats.empty
            piStats.bestStreak = legacyStreak
            if let rec = legacySessionRecord {
                piStats.lastSession = rec
                Task { @MainActor in
                    try? await historyStore.saveHistory([rec], for: .pi)
                    self.historyCache[.pi] = [rec]
                }
            }
            
            stats[.pi] = piStats
            persistStats()
            
            // Cleanup legacy keys
            legacyUserDefaults.removeObject(forKey: "com.alexandre.pitrainer.globalBestStreak")
            legacyUserDefaults.removeObject(forKey: "com.alexandre.pitrainer.lastSession")
        }
    }
    
    /// Story 8.5: Rebuilds best streaks and session records from the history files
    /// This is a safety mechanism in case UserDefaults stats are lost or corrupted.
    @MainActor
    func repairStatsFromHistory() async {
        print("debug: StatsStore starting stats repair from history...")
        var needsUpdate = false
        
        for constant in Constant.allCases {
            let records: [SessionRecord]
            if let cached = historyCache[constant] {
                records = cached
            } else {
                records = (try? await historyStore.loadHistory(for: constant)) ?? []
            }
            
            if !records.isEmpty {
                var currentStats = stats[constant] ?? .empty
                
                // 1. Repair Best Streak & Best Session
                // 1. Repair Best Streak & Best Session
                // Treat History as the Source of Truth.
                // If the history file shows a best streak of X, then the stats must show X.
                // This fixes issues where a phantom high score persists after history corruption/deletion.
                //
                // Fix for Story 8.5: Exclude Learn Mode from Best Streak calculation
                // Learn Mode defines 'streak' as loops or segment completions, which is not comparable to Practice/Test/Game.
                let eligibleRecords = records.filter { $0.sessionMode != .learn }
                let bestInHistory = eligibleRecords.max(by: { $0.bestStreakInSession < $1.bestStreakInSession })
                
                if let best = bestInHistory {
                    // Update if there is a mismatch (either higher OR lower)
                    if currentStats.bestStreak != best.bestStreakInSession || currentStats.bestSession?.id != best.id {
                         print("debug: syncing best streak for \(constant). Old: \(currentStats.bestStreak), New: \(best.bestStreakInSession)")
                         currentStats.bestStreak = best.bestStreakInSession
                         currentStats.bestSession = best
                         needsUpdate = true
                    }
                } else {
                    // If no eligible history (or all learn mode), result should be 0.
                    if currentStats.bestStreak > 0 {
                        print("debug: no eligible history for \(constant) (maybe all learn mode?), resetting best streak to 0.")
                        currentStats.bestStreak = 0
                        currentStats.bestSession = nil
                        needsUpdate = true
                    }
                }
                
                // 2. Repair Last Session
                if currentStats.lastSession == nil, let last = records.first {
                    print("debug: repairing last session for \(constant)")
                    currentStats.lastSession = last
                    needsUpdate = true
                }
                
                if needsUpdate {
                    stats[constant] = currentStats
                }
            }
        }
        
        if needsUpdate {
            persistStats()
            print("debug: stats repair completed and persisted.")
        } else {
            print("debug: no stats repair needed.")
        }
    }
    
    private func persistStats() {
        persistence.saveStats(stats)
    }
}
// MARK: - Learning Store (Consolidated)



// LearningStore removed: Moved to SegmentStore.swift

