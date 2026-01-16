//
//  LearningSchedulerTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import XCTest
@testable import PiTrainer

final class LearningSchedulerTests: XCTestCase {

    func testScheduleNewChunk() {
        // Given new chunk (interval 0)
        let now = Date()
        
        // When rated
        let again = LearningScheduler.schedule(currentInterval: 0, rating: .again, now: now)
        let hard = LearningScheduler.schedule(currentInterval: 0, rating: .hard, now: now)
        let good = LearningScheduler.schedule(currentInterval: 0, rating: .good, now: now)
        let easy = LearningScheduler.schedule(currentInterval: 0, rating: .easy, now: now)
        
        // Then
        // Again: 0 interval, due +10 min
        XCTAssertEqual(again.interval, 0)
        XCTAssertEqual(again.nextReviewDate.timeIntervalSince(now), 600, accuracy: 1) // 10 min
        
        // Hard: New -> 1 day
        XCTAssertEqual(hard.interval, 1)
        
        // Good: New -> 2 days (v1 simplification logic says max(2, ...))
        XCTAssertEqual(good.interval, 2)
        
        // Easy: New -> 4 days
        XCTAssertEqual(easy.interval, 4)
    }

    func testScheduleReviewLowInterval() {
        let now = Date()
        let currentInterval: Double = 1
        
        // When
        let again = LearningScheduler.schedule(currentInterval: currentInterval, rating: .again, now: now)
        let hard = LearningScheduler.schedule(currentInterval: currentInterval, rating: .hard, now: now)
        let good = LearningScheduler.schedule(currentInterval: currentInterval, rating: .good, now: now)
        let easy = LearningScheduler.schedule(currentInterval: currentInterval, rating: .easy, now: now)
        
        // Then
        // Again -> reset to 0, due in 10m
        XCTAssertEqual(again.interval, 0)
        
        // Hard -> max(1, 1 * 1.2) = 1.2 -> round(1.2)=1 -> max(1,1)=1
        XCTAssertEqual(hard.interval, 1) // No progress effectively on hard
        
        // Good -> max(2, 1 * 2.0) = 2
        XCTAssertEqual(good.interval, 2)
        
        // Easy -> max(4, 1 * 2.7) = 2.7 -> round 3 -> max 4 -> 4
        XCTAssertEqual(easy.interval, 4)
    }
    
    func testScheduleReviewHighInterval() {
         let now = Date()
         let currentInterval: Double = 10
         
         // When
         let hard = LearningScheduler.schedule(currentInterval: currentInterval, rating: .hard, now: now)
         let good = LearningScheduler.schedule(currentInterval: currentInterval, rating: .good, now: now)
         let easy = LearningScheduler.schedule(currentInterval: currentInterval, rating: .easy, now: now)
         
         // Then
         // Hard -> 10 * 1.2 = 12
         XCTAssertEqual(hard.interval, 12)
         
         // Good -> 10 * 2.0 = 20
         XCTAssertEqual(good.interval, 20)
         
         // Easy -> 10 * 2.7 = 27
         XCTAssertEqual(easy.interval, 27)
     }
}
