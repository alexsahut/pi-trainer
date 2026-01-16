//
//  HapticServiceTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 16/01/2026.
//

import XCTest
@testable import PiTrainer

final class HapticServiceTests: XCTestCase {
    
    func testSingleton_IsUnique() {
        let instance1 = HapticService.shared
        let instance2 = HapticService.shared
        
        // Use identity operator === to check they reference the exact same object
        XCTAssertTrue(instance1 === instance2, "HapticService should be a singleton")
    }
    
    func testPrewarm_DoesNotCrash() {
        // We can't easily assert engine running state without exposing internals,
        // but we can ensure calling it doesn't crash on any device/sim.
        HapticService.shared.prewarm()
    }
    
    func testPatterns_DoNotCrash() {
        // Fire and forget methods should be safe to call
        HapticService.shared.playSuccess()
        HapticService.shared.playError()
    }
    
    func testStop_DoesNotCrash() {
        HapticService.shared.stop()
    }
}
