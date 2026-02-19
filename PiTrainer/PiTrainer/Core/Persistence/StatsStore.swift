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
    let isCertified: Bool // Story 9.5: PB eligibility
    let wasVictory: Bool? // Story 9.5: Game Mode result
    let beatenPRTypes: Set<PRType>? // Story 9.6: Track specific records beaten
    
    var cps: Double {
        digitsPerMinute / 60.0
    }
    
    // Custom decoder for backward compatibility (Story 6.2 & 8.5)
    enum CodingKeys: String, CodingKey {
        case id, date, constant, mode, sessionMode, attempts, errors, bestStreakInSession, durationSeconds, digitsPerMinute, revealsUsed, minCPS, maxCPS, segmentStart, segmentEnd, loops, isCertified, wasVictory, beatenPRTypes
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
        isCertified = try container.decodeIfPresent(Bool.self, forKey: .isCertified) ?? false
        wasVictory = try container.decodeIfPresent(Bool.self, forKey: .wasVictory)
        beatenPRTypes = try container.decodeIfPresent(Set<PRType>.self, forKey: .beatenPRTypes)
    }
    
    // Explicit init for SessionViewModel
    init(id: UUID = UUID(), date: Date = Date(), constant: Constant, mode: PracticeEngine.Mode, sessionMode: SessionMode, attempts: Int, errors: Int, bestStreakInSession: Int, durationSeconds: TimeInterval, digitsPerMinute: Double, revealsUsed: Int = 0, minCPS: Double? = nil, maxCPS: Double? = nil, segmentStart: Int? = nil, segmentEnd: Int? = nil, loops: Int = 0, isCertified: Bool = false, wasVictory: Bool? = nil, beatenPRTypes: Set<PRType>? = nil) {
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
        self.isCertified = isCertified
        self.wasVictory = wasVictory
        self.beatenPRTypes = beatenPRTypes
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
@Observable
class StatsStore {
    
    // MARK: - Singleton
    static let shared = StatsStore(persistence: PracticePersistence())

    // MARK: - Properties
    
    private(set) var stats: [Constant: ConstantStats] = [:]
    
    // Story 11.2: Zero-Code XP System
    private(set) var totalCorrectDigits: Int = 0
    
    var currentGrade: Grade {
        Grade.from(xp: totalCorrectDigits)
    }

    /// Cached history to avoid repeated file reads. 
    /// Keyed by constant.
    private(set) var historyCache: [Constant: [SessionRecord]] = [:]
    
    /// Indicates if history is currently being loaded for the selected constant
    private(set) var isHistoryLoading: Bool = false
    
    var keypadLayout: KeypadLayout = .phone {
        didSet {
            persistence.saveKeypadLayout(keypadLayout.rawValue)
        }
    }
    
    var selectedConstant: Constant = .pi {
        didSet {
            persistence.saveSelectedConstant(selectedConstant.rawValue)
            // Proactive load to avoid UI flashing
            loadHistoryEagerly(for: selectedConstant)
        }
    }
    
    var selectedMode: SessionMode = .learn {
        didSet {
            UserDefaults.standard.set(selectedMode.rawValue, forKey: "selectedMode")
        }
    }
    
    var selectedGhostType: PRType = .crown {
        didSet {
            persistence.saveSelectedGhostType(selectedGhostType.rawValue)
        }
    }
    
    // Story 10.1: Auto-Advance Setting
    var isAutoAdvanceEnabled: Bool = false {
        didSet {
            persistence.saveAutoAdvance(isAutoAdvanceEnabled)
        }
    }
    
    // MARK: - Private Properties
    
    private let persistence: PracticePersistenceProtocol
    private let historyStore: SessionHistoryStore
    let streakStore: StreakStore
    
    // MARK: - Initialization
    
    init(persistence: PracticePersistenceProtocol, 
         historyStore: SessionHistoryStore? = nil) {
        self.persistence = persistence
        
        // Handle throwing initializer of SessionHistoryStore
        if let providedStore = historyStore {
            self.historyStore = providedStore
        } else {
            do {
                self.historyStore = try SessionHistoryStore()
            } catch {
                print("⚠️ CRITICAL: Failed to initialize SessionHistoryStore: \(error)")
                // Fallback: Create a store in a guaranteed-writable temporary directory
                let fallbackURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("PiTrainer_fallback_\(UUID().uuidString)")
                try? FileManager.default.createDirectory(at: fallbackURL, withIntermediateDirectories: true)
                // Use nil-coalescing with do/catch to avoid any crash path
                if let fallbackStore = try? SessionHistoryStore(customDirectory: fallbackURL) {
                    self.historyStore = fallbackStore
                } else {
                    // Last resort: use /tmp directly — this should never fail on iOS
                    let lastResortURL = URL(fileURLWithPath: NSTemporaryDirectory())
                        .appendingPathComponent("PiTrainer_emergency")
                    try? FileManager.default.createDirectory(at: lastResortURL, withIntermediateDirectories: true)
                    self.historyStore = (try? SessionHistoryStore(customDirectory: lastResortURL))!
                    // Note: If even /tmp fails, the app has bigger problems than history storage
                }
            }
        }
        
        self.streakStore = StreakStore()
        
        loadStats()
        loadHistoryEagerly(for: selectedConstant)
        
        Task { @MainActor in
            await repairStatsFromHistory()
        }
    }
    
    // MARK: - Public Methods
    
    func stats(for constant: Constant) -> ConstantStats {
        return stats[constant] ?? .empty
    }
    
    func bestStreak(for constant: Constant) -> Int {
        return stats(for: constant).bestStreak
    }
    
    func lastSession(for constant: Constant) -> SessionRecord? {
        return stats(for: constant).lastSession
    }
    
    func history(for constant: Constant) -> [SessionRecord] {
        return historyCache[constant] ?? []
    }

    @MainActor
    func loadHistory(for constant: Constant) async {
        isHistoryLoading = true
        defer { isHistoryLoading = false }
        
        do {
            let records = try await historyStore.loadHistory(for: constant)
            self.historyCache[constant] = records
        } catch {
            print("❌ Error loading history for \(constant): \(error)")
        }
    }
    
    private func loadHistoryEagerly(for constant: Constant) {
        Task { @MainActor in
            await loadHistory(for: constant)
        }
    }

    func updateBestStreakIfNeeded(_ streak: Int, for constant: Constant) {
        var currentStats = stats(for: constant)
        if streak > currentStats.bestStreak {
            currentStats.bestStreak = streak
            stats[constant] = currentStats
            persistStats()
        }
    }
    
    func addSessionRecord(_ record: SessionRecord) {
        let previousGrade = currentGrade
        var currentStats = stats(for: record.constant)
        let previousBestStreak = currentStats.bestStreak
        
        currentStats.lastSession = record
        
        var isNewPB = false
        if record.isCertified {
            if record.bestStreakInSession > currentStats.bestStreak {
                currentStats.bestStreak = record.bestStreakInSession
                currentStats.bestSession = record
                isNewPB = previousBestStreak > 0 // Only count as "beating" if there was a previous record
            } else if record.bestStreakInSession == currentStats.bestStreak {
                currentStats.bestSession = record
            }
        }

        stats[record.constant] = currentStats
        persistStats()
        
        // Story 11.2: Update XP (Total Correct Digits) - Immediate update for UI responsiveness
        let xpGained = max(0, record.attempts - record.errors)
        self.totalCorrectDigits += xpGained
        persistence.saveTotalCorrectDigits(self.totalCorrectDigits)
        
        // Story 11.3: Prepare Double Bang Detection (Triggered only after safe persistence)
        let newGrade = currentGrade
        let shouldTriggerDoubleBang = isNewPB && 
                                      newGrade != previousGrade && 
                                      (Grade.allCases.firstIndex(of: newGrade) ?? 0 > Grade.allCases.firstIndex(of: previousGrade) ?? 0)
        
        Task { @MainActor in
            do {
                let updatedHistory = try await historyStore.appendRecord(record, for: record.constant)
                self.historyCache[record.constant] = updatedHistory
                
                streakStore.recordSession()
                NotificationService.shared.scheduleDailyReminder(streak: streakStore.currentStreak)
                
                // Story 11.3: Trigger Reward only if persistence succeeded
                if shouldTriggerDoubleBang {
                    RewardManager.shared.triggerDoubleBang()
                }
            } catch {
                print("Failed to append record: \(error)")
            }
        }
    }
    
    // Story 13.2: Allow external components (like Challenge) to credit XP
    func creditXP(amount: Int) {
        self.totalCorrectDigits += amount
        persistence.saveTotalCorrectDigits(self.totalCorrectDigits)
    }

    func clearHistory(for constant: Constant) {
        var currentStats = stats(for: constant)
        currentStats.lastSession = nil
        stats[constant] = currentStats
        persistStats()
        
        historyCache[constant] = []
        Task { @MainActor in
            try? await historyStore.saveHistory([], for: constant)
        }
    }
    
    func reset() {
        stats = [:]
        persistence.saveStats([:])
        
        Task { @MainActor in
            try? await historyStore.clearAllHistory()
            self.historyCache = [:]
            streakStore.reset()
            NotificationService.shared.cancelPendingReminders()
            await PersonalBestStore.shared.reset()
            SegmentStore.shared.reset()
            self.totalCorrectDigits = 0
            persistence.saveTotalCorrectDigits(0)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadStats() {
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
            selectedMode = .learn
        }
        
        if let ghostTypeString = persistence.loadSelectedGhostType(),
           let type = PRType(rawValue: ghostTypeString) {
            selectedGhostType = type
        } else {
            selectedGhostType = .crown
        }
        
        if let autoAdvance = persistence.loadAutoAdvance() {
            isAutoAdvanceEnabled = autoAdvance
        } else {
            isAutoAdvanceEnabled = false
        }
        
        if let decodedStats = persistence.loadStats() {
            stats = decodedStats
        }
        
        // Story 11.2: Load XP
        totalCorrectDigits = persistence.loadTotalCorrectDigits()
    }
    
    @MainActor
    func repairStatsFromHistory() async {
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
                let eligibleRecords = records.filter { 
                    $0.sessionMode != .learn && ($0.isCertified || ($0.sessionMode == .test && $0.revealsUsed == 0 && $0.errors <= 1))
                }
                let bestInHistory = eligibleRecords.max(by: { $0.bestStreakInSession < $1.bestStreakInSession })
                
                if let best = bestInHistory {
                    if currentStats.bestStreak != best.bestStreakInSession || currentStats.bestSession?.id != best.id {
                         currentStats.bestStreak = best.bestStreakInSession
                         currentStats.bestSession = best
                         needsUpdate = true
                    }
                } else {
                    if currentStats.bestStreak > 0 {
                        currentStats.bestStreak = 0
                        currentStats.bestSession = nil
                        needsUpdate = true
                    }
                }
                
                if currentStats.lastSession == nil, let last = records.first {
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
        }
    }
    
    private func persistStats() {
        persistence.saveStats(stats)
    }
    
    func recalculateTotalXP() async {
        var total = 0
        for constant in Constant.allCases {
            let records = (try? await historyStore.loadHistory(for: constant)) ?? []
            for record in records {
                total += max(0, record.attempts - record.errors)
            }
        }
        
        await MainActor.run {
            self.totalCorrectDigits = total
            persistence.saveTotalCorrectDigits(total)
        }
    }
}
// MARK: - Learning Store (Consolidated)



// LearningStore removed: Moved to SegmentStore.swift

