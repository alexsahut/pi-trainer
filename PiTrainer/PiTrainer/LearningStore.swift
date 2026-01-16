//
//  LearningStore.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import Foundation
import Combine

/// Represents the learning state for a chunk
enum ChunkState: String, Codable {
    case new
    case learning
    case review
    case mastered
}

/// Detailed progress record for a single chunk
struct ChunkProgress: Codable, Equatable {
    let chunkIndex: Int
    var state: ChunkState
    var nextReviewDate: Date?
    var interval: Double // Days
    var ease: Double // Reserved for future SM-2
    var history: [ChunkReview]
    
    struct ChunkReview: Codable, Equatable {
        let date: Date
        let rating: RecallRating
    }
    
    // Helper to check if due
    func isDue(at date: Date = Date()) -> Bool {
        guard let nextReviewDate = nextReviewDate else { return true }
        return date >= nextReviewDate
    }
    
    static func new(index: Int) -> ChunkProgress {
        return ChunkProgress(
            chunkIndex: index,
            state: .new,
            nextReviewDate: nil,
            interval: 0,
            ease: 2.5,
            history: []
        )
    }
}

/// Learning configuration and progress for a single constant
struct ConstantLearningState: Codable {
    var chunkSize: Int = 20
    var dailyNewChunks: Int = 2
    var dailyReviewLimit: Int = 10
    
    // Daily Limit Tracking
    var lastDailyActivityDate: Date?
    var dailyNewChunksCount: Int = 0
    
    // Progress keyed by chunk index (0, 1, 2...)
    // Only created chunks are stored here.
    var progress: [Int: ChunkProgress] = [:]
    
    /// Returns sorted list of all chunks currently tracked
    var allTrackedChunks: [ChunkProgress] {
        progress.values.sorted { $0.chunkIndex < $1.chunkIndex }
    }
    
    var masteredCount: Int {
        progress.values.filter { $0.state == .mastered }.count
    }
    
    var inLearningCount: Int {
        progress.values.filter { $0.state == .learning || $0.state == .review }.count
    }
}

class LearningStore: ObservableObject {
    
    // MARK: - Constants
    private let storageKey = "com.alexandre.pitrainer.learning"
    
    // MARK: - Published Properties
    @Published private(set) var states: [Constant: ConstantLearningState] = [:]
    
    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }
    
    // MARK: - Public API
    
    /// Get the state for a specific constant
    func state(for constant: Constant) -> ConstantLearningState {
        var state = states[constant] ?? ConstantLearningState()
        
        // Check for daily reset
        if let lastDate = state.lastDailyActivityDate, !Calendar.current.isDateInToday(lastDate) {
            state.dailyNewChunksCount = 0
            state.lastDailyActivityDate = Date()
            // We should save this reset, but `state` is a value type here.
            // It will be saved when `saveReview` or `newChunksToLearn` writes back.
            // For `newChunksToLearn`, we'll handle the check there.
        }
        
        return state
    }
    
    /// Get progress for a specific chunk, creating default if new
    func progress(for constant: Constant, chunkIndex: Int) -> ChunkProgress {
        return states[constant]?.progress[chunkIndex] ?? ChunkProgress.new(index: chunkIndex)
    }
    
    /// Returns chunks due for review today (or overdue)
    func dueChunks(for constant: Constant, limit: Int? = nil, now: Date = Date()) -> [ChunkProgress] {
        let all = state(for: constant).allTrackedChunks
        let due = all.filter { $0.isDue(at: now) && $0.state != .new } // New are handled separately
        
        // Secondary sort: Overdue first (nextReviewDate asc), then difficult ones
        let sortedDue = due.sorted {
            ($0.nextReviewDate ?? Date.distantPast) < ($1.nextReviewDate ?? Date.distantPast)
        }
        
        if let limit = limit {
            return Array(sortedDue.prefix(limit))
        }
        return sortedDue
    }
    
    /// Returns new chunks available to learn, respecting daily limit
    func newChunksToLearn(for constant: Constant, count: Int) -> [ChunkProgress] {
        var currentState = states[constant] ?? ConstantLearningState()
        
        // Reset if needed
        if let lastDate = currentState.lastDailyActivityDate, !Calendar.current.isDateInToday(lastDate) {
            currentState.dailyNewChunksCount = 0
        }
        currentState.lastDailyActivityDate = Date()
        
        var newChunks: [ChunkProgress] = []
        
        // Calculate remaining quota
        let remainingQuota = max(0, currentState.dailyNewChunks - currentState.dailyNewChunksCount)
        let actualCount = min(count, remainingQuota)
        
        if actualCount <= 0 {
             // Save state to update date/reset if needed
             states[constant] = currentState
             return []
        }
        
        let currentProgress = currentState.progress
        
        // Find next available index
        let maxIndex = currentProgress.keys.max() ?? -1
        var nextIndex = maxIndex + 1
        
        for _ in 0..<actualCount {
            newChunks.append(ChunkProgress.new(index: nextIndex))
            nextIndex += 1
        }
        
        // Update daily count - effectively "reserving" them for this session
        currentState.dailyNewChunksCount += newChunks.count
        states[constant] = currentState
        persist() // Persist immediately to lock them in
        
        return newChunks
    }
    
    /// Saves a review result for a chunk
    func saveReview(for constant: Constant, chunkIndex: Int, rating: RecallRating, now: Date = Date()) {
        var currentState = states[constant] ?? ConstantLearningState()
        var chunk = currentState.progress[chunkIndex] ?? ChunkProgress.new(index: chunkIndex)
        
        // Schedule next review
        let result = LearningScheduler.schedule(
            currentInterval: chunk.interval,
            rating: rating,
            now: now
        )
        
        // Update chunk
        chunk.interval = result.interval
        chunk.nextReviewDate = result.nextReviewDate
        chunk.history.append(ChunkProgress.ChunkReview(date: now, rating: rating))
        
        // Update state based on interval
        if chunk.state == .new {
            chunk.state = .learning
        }
        
        // Simple logic for state transition:
        // interval > 21 days -> Mastered? (Optional, kept simple for now)
        if chunk.interval > 30 {
            chunk.state = .mastered
        } else if chunk.interval > 1 {
            chunk.state = .review
        } else {
            chunk.state = .learning
        }
        
        // Save back
        currentState.progress[chunkIndex] = chunk
        states[constant] = currentState
        persist()
    }
    
    // MARK: - Persistence
    
    func reset() {
        states = [:]
        userDefaults.removeObject(forKey: storageKey)
    }
    
    private func load() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Constant: ConstantLearningState].self, from: data) {
            states = decoded
        }
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(states) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }
}
