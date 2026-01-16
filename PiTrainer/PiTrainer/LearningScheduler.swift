//
//  LearningScheduler.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import Foundation

/// Defines the user's subjective rating of their recall performance
enum RecallRating: String, Codable, CaseIterable {
    case again  // Complete blackout, need to review immediately
    case hard   // Remembered with difficulty / hesitation / hint
    case good   // Correct retrieval with some effort
    case easy   // Perfect recall, effortless
}

/// A simple Spaced Repetition scheduler inspired by SM-2 / Leitner
struct LearningScheduler {
    
    /// Result of a scheduling operation
    struct SchedulingResult {
        let interval: Double // in days
        let nextReviewDate: Date
        // ease could be added here if we implement full SM-2 later
    }
    
    /// Calculates the next review schedule based on the rating
    /// - Parameters:
    ///   - currentInterval: The previous interval in days (0 if new)
    ///   - rating: The user's rating
    ///   - now: The base date for calculation (default is Date())
    /// - Returns: A SchedulingResult containing the new interval and due date
    static func schedule(currentInterval: Double, rating: RecallRating, now: Date = Date()) -> SchedulingResult {
        var nextInterval: Double = 0
        var nextDate: Date = now
        
        switch rating {
        case .again:
            // "Again" resets interval or keeps it very short for immediate re-learning
            // Requirement: "interval = 0 (revoir aujourd’hui, dueDate = now + 10 min)"
            nextInterval = 0
            nextDate = now.addingTimeInterval(10 * 60) // 10 minutes
            
        case .hard:
            // Requirement: "interval = max(1, round(interval*1.2))"
            if currentInterval == 0 {
                nextInterval = 1
            } else {
                nextInterval = max(1, round(currentInterval * 1.2))
            }
            nextDate = now.addingTimeInterval(nextInterval * 86400)
            
        case .good:
            // Requirement: "interval = max(2, round(interval*2.0))"
            if currentInterval == 0 {
                nextInterval = 2 // First successful graduation
            } else {
                nextInterval = max(2, round(currentInterval * 2.0))
            }
            nextDate = now.addingTimeInterval(nextInterval * 86400)
            
        case .easy:
            // Requirement: "interval = max(4, round(interval*2.7))"
            if currentInterval == 0 {
                nextInterval = 4 // Leap forward
            } else {
                nextInterval = max(4, round(currentInterval * 2.7))
            }
            nextDate = now.addingTimeInterval(nextInterval * 86400)
        }
        
        return SchedulingResult(interval: nextInterval, nextReviewDate: nextDate)
    }
}
