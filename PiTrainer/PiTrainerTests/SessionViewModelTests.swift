//
//  SessionViewModelTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import XCTest
@testable import PiTrainer

final class SessionViewModelTests: XCTestCase {
    
    var statsStore: StatsStore!
    var viewModel: SessionViewModel!
    
    override func setUp() {
        super.setUp()
        statsStore = StatsStore()
        viewModel = SessionViewModel(statsStore: statsStore)
    }
    
    override func tearDown() {
        viewModel = nil
        statsStore = nil
        super.tearDown()
    }
    
    func testStartSession_UsesSelectedConstant() {
        // Given: Store is initially Pi (default)
        statsStore.selectedConstant = .pi
        
        // When: We change selection to 'e'
        statsStore.selectedConstant = .e
        
        // And: Start session
        viewModel.startSession()
        
        // Then: The engine should expect the first digit of 'e' (7), not Pi (1)
        
        // 2 + 7 + 1 + 8 + ...
        // e = 2.718...
        // Pi = 3.141...
        
        // Try entering 7 (Correct for e)
        viewModel.processInput(7)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 7, "VM should register 7 as correct when e is selected")
        XCTAssertEqual(viewModel.typedDigits, "7", "Typed digits should include 7")
        XCTAssertEqual(viewModel.expectedDigit, nil, "Should not show error for 7")
    }
    
    func testStartSession_SwitchesBackToPi() {
        // Given: Started with e
        statsStore.selectedConstant = .e
        viewModel.startSession()
        
        // When: Switch back to Pi
        statsStore.selectedConstant = .pi
        viewModel.startSession()
        
        // Then: Engine should expect 1 (first digit of Pi)
        viewModel.processInput(1)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct when Pi is selected")
        XCTAssertEqual(viewModel.typedDigits, "1", "Typed digits should include 1")
    }
}
