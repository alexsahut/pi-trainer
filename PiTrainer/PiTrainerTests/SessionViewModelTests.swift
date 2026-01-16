//
//  SessionViewModelTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import XCTest
@testable import PiTrainer

@MainActor
final class SessionViewModelTests: XCTestCase {
    
    class MockDigitsProvider: DigitsProvider {
        var digits = [1, 4, 1, 5, 9]
        var totalDigits: Int { digits.count }
        
        func getDigit(at index: Int) -> Int? { 
            guard index < digits.count else { return nil }
            return digits[index] 
        }
        func loadDigits() throws {}
    }
    
    class MockPracticePersistence: PracticePersistenceProtocol {
        func saveHighestIndex(_ index: Int, for constantKey: String) {}
        func getHighestIndex(for constantKey: String) -> Int { return 0 }
    }
    
    var statsStore: StatsStore!
    var viewModel: SessionViewModel!
    var testDefaults: UserDefaults!
    var persistence: MockPracticePersistence!
    
    override func setUp() {
        super.setUp()
        let suiteName = "SessionViewModelTests-\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: suiteName)
        statsStore = StatsStore(userDefaults: testDefaults)
        persistence = MockPracticePersistence()
        
        viewModel = SessionViewModel(
            statsStore: statsStore, 
            persistence: persistence,
            providerFactory: { _ in MockDigitsProvider() }
        )
    }
    
    override func tearDown() {
        viewModel = nil
        statsStore = nil
        testDefaults = nil
        super.tearDown()
    }
    
    func testStartSession_UsesSelectedConstant() {
        // Given: Selection 'e'
        statsStore.selectedConstant = .e
        
        // When: Start session
        viewModel.startSession()
        
        // Then: Engine should be active and expect 1 (Mock provider uses 1, 4, 1...)
        XCTAssertTrue(viewModel.isActive, "Session should be active after startSession")
        
        viewModel.processInput(1)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct from mock provider")
        XCTAssertEqual(viewModel.typedDigits, "1")
        XCTAssertNil(viewModel.expectedDigit)
    }
    
    func testStartSession_SwitchesBackToPi() {
        // Given: Started with e
        statsStore.selectedConstant = .e
        viewModel.startSession()
        XCTAssertTrue(viewModel.isActive)
        
        // When: Switch back to Pi
        statsStore.selectedConstant = .pi
        viewModel.startSession()
        
        // Then: Engine should be active and expect 1
        XCTAssertTrue(viewModel.isActive, "Session should be active after switching back to Pi")
        viewModel.processInput(1)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct when Pi is selected")
        XCTAssertEqual(viewModel.typedDigits, "1")
    }
}
