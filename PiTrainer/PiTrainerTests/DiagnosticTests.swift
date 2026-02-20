import XCTest
@testable import PiTrainer

/// Minimal tests to isolate SIGABRT crash source in SessionViewModel
/// Fix: All mock classes must be @unchecked Sendable for iOS 26 runtime enforcement
@MainActor
final class DiagnosticTests: XCTestCase {
    
    func testStep1_CreateMockPersistence() {
        let persistence = HorizonMockPersistence()
        XCTAssertNotNil(persistence)
    }
    
    func testStep2_CreateMockProvider() {
        let provider = HorizonMockDigitsProvider()
        XCTAssertEqual(provider.totalDigits, 10)
    }
    
    func testStep3_CreatePracticeEngine() {
        let persistence = HorizonMockPersistence()
        let provider = HorizonMockDigitsProvider()
        let engine = PracticeEngine(constant: .pi, provider: provider, persistence: persistence)
        XCTAssertNotNil(engine)
    }
    
    func testStep4_CreateSessionViewModel() {
        let persistence = HorizonMockPersistence()
        let vm = SessionViewModel(
            persistence: persistence,
            providerFactory: { _ in HorizonMockDigitsProvider() }
        )
        XCTAssertNotNil(vm)
    }
    
    func testStep5_SetModeAndStartSession() {
        let persistence = HorizonMockPersistence()
        let vm = SessionViewModel(
            persistence: persistence,
            providerFactory: { _ in HorizonMockDigitsProvider() }
        )
        vm.selectedMode = .test
        vm.startSession()
        XCTAssertTrue(vm.engine.isActive || vm.engine.state == .ready)
    }
    
    func testStep6_ProcessInput() {
        let persistence = HorizonMockPersistence()
        let vm = SessionViewModel(
            persistence: persistence,
            providerFactory: { _ in HorizonMockDigitsProvider() }
        )
        vm.selectedMode = .test
        vm.startSession()
        vm.processInput(1) // Correct (first digit)
        XCTAssertEqual(vm.engine.currentIndex, 1)
    }
}
