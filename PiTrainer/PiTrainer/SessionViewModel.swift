//
//  SessionViewModel.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation
import SwiftUI
import Combine

/// Manages the state and logic for a Pi practice session
@MainActor
class SessionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var engine: PracticeEngine
    @Published private(set) var typedDigits: String = ""
    @Published private(set) var showErrorFlash: Bool = false
    @Published private(set) var lastCorrectDigit: Int?
    @Published private(set) var expectedDigit: Int? // For learning mode feedback
    @Published var errorState: String? // Critical error preventing session start
    @Published var shouldDismiss: Bool = false // Signal to View to dismiss itself
    @Published var revealsUsed: Int = 0 // Track assistance used (Story 6.2)
    
    // UI selection state
    @Published var selectedMode: PracticeEngine.Mode = .strict
    @Published var selectedConstant: Constant = .pi
    @Published var keypadLayout: KeypadLayout = .phone
    @Published var isGhostModeEnabled: Bool = true
    
    // MARK: - Properties
    
    private let persistence: PracticePersistenceProtocol
    private let providerFactory: (Constant) -> any DigitsProvider
    
    // Configuration for the current session
    var onSaveSession: ((SessionRecord) -> Void)?

    
    // MARK: - Derived Properties
    
    /// True if the session is currently running (timer active) - Trigger for Zen Mode
    var isActive: Bool { engine.isActive }
    
    /// True if the session is ready to accept input or running
    var isInputAllowed: Bool { engine.isReadyOrRunning }
    
    var currentIndex: Int { engine.currentIndex }
    var attempts: Int { engine.attempts }
    var errors: Int { engine.errors }
    var bestStreak: Int { engine.bestStreak }
    
    var integerPart: String {
        selectedConstant.integerPart
    }
    
    var displayString: String {
        return selectedConstant.integerPart + "." + typedDigits
    }
    
    var constantSymbol: String {
        return selectedConstant.symbol
    }
    
    var fullDigitsString: String {
        return engine.allDigitsString
    }
    
    // MARK: - Initialization
    
    init(persistence: PracticePersistenceProtocol = PracticePersistence(),
         providerFactory: @escaping (Constant) -> any DigitsProvider = { FileDigitsProvider(constant: $0) }) {
        self.persistence = persistence
        self.providerFactory = providerFactory
        
        // Initialize with default (pi) - will be updated before start
        let constant = Constant.pi
        let provider = providerFactory(constant)
        self.engine = PracticeEngine(constant: constant, provider: provider, persistence: persistence)
    }
    
    // MARK: - Public Methods
    
    /// Synchronizes settings from the global store
    func syncSettings(from store: StatsStore) {
        self.keypadLayout = store.keypadLayout
        self.selectedConstant = store.selectedConstant
        self.isGhostModeEnabled = store.isGhostModeEnabled
        self.selectedMode = store.selectedMode
    }
    
    /// Starts a new session with the selected mode
    func startSession() {
        // Clear previous error state
        errorState = nil
        
        // Always refresh the engine with the configured constant
        let constant = selectedConstant
        var provider = providerFactory(constant)
        
        do {
            try provider.loadDigits()
            print("debug: provider loaded \(provider.totalDigits) digits")
            self.engine = PracticeEngine(constant: constant, provider: provider, persistence: persistence)
            engine.start(mode: selectedMode)
            
            // Pre-warm the haptic engine only on success
            HapticService.shared.prewarm()
            
            // Reset UI state
            typedDigits = ""
            showErrorFlash = false
            lastCorrectDigit = nil
            expectedDigit = nil
            shouldDismiss = false
            revealsUsed = 0
            print("debug: session started for \(constant) in \(selectedMode) mode")
            
        } catch {
            print("❌ CRITICAL: Failed to start engine: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            self.errorState = "Failed to load resources: \(error.localizedDescription)"
            // Do NOT start the engine. Session remains inactive.
            // The UI should verify 'errorState' and show an alert or placeholder.
        }
    }
    
    /// Processes a digit input from the keypad
    /// - Parameter digit: The digit (0-9)
    func processInput(_ digit: Int) {
        objectWillChange.send()
        let result = engine.input(digit: digit)
        print("debug: input \(digit), isCorrect: \(result.isCorrect), engine.isActive: \(engine.isActive)")
        
        if result.isCorrect {
            // Success feedback
            lastCorrectDigit = digit
            expectedDigit = nil
            
            // Update displayed digits
            typedDigits.append(String(digit))
            
            // Light haptic for success (instant)
            HapticService.shared.playSuccess()
        } else {
            // Error feedback
            expectedDigit = result.expectedDigit
            HapticService.shared.playError()
            
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                showErrorFlash = true
            }
            
            // Reset flash after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showErrorFlash = false
            }
            
            if engine.mode == .learning {
                // In learning mode, we still advance
                typedDigits.append(String(result.expectedDigit))
            }
        }
        
        // Critical Fix: Check if engine finished (e.g. Strict Mode failure)
        // If engine finished internally, we MUST trigger persistence and cleanup
        if !engine.isActive {
            endSession()
        }
    }
    
    /// Goes back one digit
    func backspace() {
        objectWillChange.send()
        engine.backspace()
        if !typedDigits.isEmpty {
            typedDigits.removeLast()
        }
    }
    
    /// Resets the current session
    func reset() {
        // Reuse startSession logic to ensure proper loading and error handling
        startSession()
    }
    
    /// Reveals a specific number of digits (increments help counter)
    func reveal(count: Int) {
        revealsUsed += count
        HapticService.shared.playSuccess() // Light feedback
    }
    
    /// Ends the session and saves stats
    func endSession(shouldDismiss: Bool = false) {
        // We allow ending if active OR if it just finished (to capture the last record)
        if engine.isActive || engine.state == .finished {
            let record = SessionRecord(
                id: UUID(),
                date: Date(),
                constant: selectedConstant,
                mode: selectedMode,
                attempts: engine.attempts,
                errors: engine.errors,
                bestStreakInSession: engine.bestStreak,
                durationSeconds: engine.elapsedTime,
                digitsPerMinute: engine.digitsPerMinute,
                revealsUsed: revealsUsed,
                minCPS: engine.minCPS == .infinity ? nil : engine.minCPS,
                maxCPS: engine.maxCPS
            )
            
            onSaveSession?(record)
            
            // Note: We don't call engine.reset() here anymore because the UI 
            // needs the engine data (attempts, bestStreak) to show the summary.
            // A new engine will be created in startSession() for the next run.
            HapticService.shared.stop()
            
            // Story 5.2: Request notification consent after the first "meaningful" session
            if record.attempts >= 5 {
                NotificationService.shared.requestAuthorization()
            }
        }
        
        // Story 5.2 Patch: Stop and dismiss only if explicitly requested
        // Moved outside the if condition to allow exiting even if session hasn't started (Bug Fix)
        if shouldDismiss {
            engine.reset()
            self.shouldDismiss = true
        }
    }
}
