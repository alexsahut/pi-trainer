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
    @Published private(set) var isShowingErrorReveal: Bool = false // Story 9.4 Fix: Stay visible until correction
    @Published private(set) var lastCorrectDigit: Int?
    @Published private(set) var expectedDigit: Int? // For learning mode feedback
    @Published private(set) var lastWrongInput: Int? // For visual feedback of wrong entry
    @Published private(set) var indulgentErrorIndices: Set<Int> = [] // Story 10.1: Track positions of indulged errors
    @Published var errorState: String? // Critical error preventing session start
    @Published var shouldDismiss: Bool = false // Signal to View to dismiss itself
    @Published var revealsUsed: Int = 0 // Track assistance used (Story 6.2)
    @Published var loops: Int = 0 // Story 8.6: Track segment completions
    @Published var ghostEngine: GhostEngine? // Story 9.1: Replay opponent
    private var isSessionSaved: Bool = false // Story 8.5: Prevent double saving
    private var isNewPR: Bool = false // Story 9.5 Patch: Accurate status feedback
    private var beatenPRTypes: Set<PRType> = []
    
    // Story 9.6: Practice Mode PR logic (validation before first error)
    private struct SessionSnapshot {
        let index: Int
        let time: TimeInterval
        let cumulativeTimes: [TimeInterval]
    }
    private var firstErrorSnapshot: SessionSnapshot?
    
    // UI selection state
    @Published var selectedMode: SessionMode = .learn
    @Published var selectedConstant: Constant = .pi
    @Published var keypadLayout: KeypadLayout = .phone
    @Published var selectedGhostType: PRType = .crown
    
    // Story 10.1: Auto-Advance Setting (Propagated from StatsStore)
    @Published var isAutoAdvanceEnabled: Bool = false {
        didSet {
            engine.isIndulgent = isAutoAdvanceEnabled
            print("debug: reactive sync - engine.isIndulgent updated to \(engine.isIndulgent)")
        }
    }

    // MARK: - Properties
    
    private let persistence: PracticePersistenceProtocol
    private let providerFactory: (Constant) -> any DigitsProvider
    
    // Story 8.1: Learning Store
    private var segmentStore: SegmentStore
    
    // Story 9.2: PB Provider for Ghost
    private let personalBestProvider: (Constant, PRType) -> PersonalBestRecord?
    
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
    
    /// Returns the current segment start offset (Story 8.3)
    /// Used by TerminalGridView to correctly number lines and fetch ghost digits
    var currentSegmentOffset: Int {
        return selectedMode == .learn ? segmentStore.segmentStart : 0
    }
    
    /// Returns the target length of the segment (Story 8.4)
    /// Used by TerminalGridView to show the full "Ghost" block
    var currentSegmentLength: Int {
        return selectedMode == .learn ? (segmentStore.segmentEnd - segmentStore.segmentStart) : 0
    }
    
    var showsPermanentOverlay: Bool {
        selectedMode.showsPermanentOverlay
    }
    
    var allowsReveal: Bool {
        selectedMode.allowsReveal
    }
    
    @Published var isDefeatedByGhost: Bool = false
    private var ghostMonitorTask: Task<Void, Never>?
    
    // Story 9.5: Dynamic End Session Status
    var sessionEndStatus: (title: String, color: Color) {
        if isDefeatedByGhost {
            return ("DEFEATED", DesignSystem.Colors.orangeElectric)
        }
        
        let isCertified = selectedMode != .learn && revealsUsed == 0 && (engine.errors == 0 || selectedMode == .game || selectedMode == .test) && !isDefeatedByGhost
        
        if !beatenPRTypes.isEmpty {
             if beatenPRTypes.contains(.crown) && beatenPRTypes.contains(.lightning) {
                 return ("DUAL RECORD!", DesignSystem.Colors.cyanElectric)
             } else if beatenPRTypes.contains(.lightning) {
                 return ("SPEED RECORD!", DesignSystem.Colors.cyanElectric)
             } else {
                 return ("NEW RECORD!", DesignSystem.Colors.cyanElectric)
             }
        } else if isCertified {
             return ("CERTIFIED", DesignSystem.Colors.cyanElectric)
        } else {
             // Not certified (too many errors or reveals)
             // Check if we are ahead of ghost?
             let delta = atmosphericDelta(at: Date())
             if delta > 0 {
                 return ("VICTORY", .green) // Won but with errors/reveals
             } else {
                 return (String(localized: "session.game_over"), .red)
             }
        }
    }
    
    // MARK: - Initialization
    
    init(persistence: PracticePersistenceProtocol? = nil,
         providerFactory: ((Constant) -> any DigitsProvider)? = nil,
         segmentStore: SegmentStore? = nil,
         personalBestProvider: ((Constant, PRType) -> PersonalBestRecord?)? = nil) {
        let actualPersistence = persistence ?? PracticePersistence()
        let actualFactory = providerFactory ?? { FileDigitsProvider(constant: $0) }
        
        self.persistence = actualPersistence
        self.providerFactory = actualFactory
        self.segmentStore = segmentStore ?? SegmentStore()
        self.personalBestProvider = personalBestProvider ?? { constant, type in
            let crown = PersonalBestStore.shared.getRecord(for: constant, type: .crown)
            let lightning = PersonalBestStore.shared.getRecord(for: constant, type: .lightning)
            
            if let crown = crown, type == .crown {
                print("debug: selecting CROWN Ghost for \(constant)")
                return crown
            }
            if let lightning = lightning, type == .lightning {
                print("debug: selecting LIGHTNING Ghost for \(constant)")
                return lightning
            }
            
            // Auto-fallback if requested type is missing
            if let crown = crown { 
                print("debug: fallback to CROWN Ghost for \(constant)")
                return crown 
            }
            if let lightning = lightning { 
                print("debug: fallback to LIGHTNING Ghost for \(constant)")
                return lightning 
            }
            return nil
        }
        
        // Initialize with default (pi) - will be updated before start
        let constant = Constant.pi
        let provider = actualFactory(constant)
        self.engine = PracticeEngine(constant: constant, provider: provider, persistence: actualPersistence)
    }
    
    // MARK: - Public Methods
    
    /// Synchronizes settings from the global stores
    func syncSettings(from store: StatsStore, segmentStore: SegmentStore) {
        self.keypadLayout = store.keypadLayout
        self.selectedConstant = store.selectedConstant

        self.selectedMode = store.selectedMode
        self.selectedGhostType = store.selectedGhostType
        self.isAutoAdvanceEnabled = store.isAutoAdvanceEnabled
        
        // Story 8.1 Fix: Use the segment store from HomeView
        self.segmentStore = segmentStore
    }
    
    /// Starts a new session with the selected mode
    func startSession() {
        // Clear previous error state and reset session-specific properties
        errorState = nil
        isDefeatedByGhost = false
        isNewPR = false
        beatenPRTypes = []
        isSessionSaved = false
        isShowingErrorReveal = false
        revealsUsed = 0
        loops = 0
        typedDigits = ""
        showErrorFlash = false
        lastCorrectDigit = nil
        expectedDigit = nil
        lastWrongInput = nil
        indulgentErrorIndices = []
        firstErrorSnapshot = nil
        
        ghostMonitorTask?.cancel()
        ghostMonitorTask = nil
        
        // Always refresh the engine with the configured constant
        let constant = selectedConstant
        var provider = providerFactory(constant)
        
        do {
            try provider.loadDigits()
            print("debug: provider loaded \(provider.totalDigits) digits")
            self.engine = PracticeEngine(constant: constant, provider: provider, persistence: persistence)
            
            // Story 8.1: Apply segment if in Learn mode
            if selectedMode == .learn {
                engine.start(mode: selectedMode.practiceEngineMode, startIndex: segmentStore.segmentStart, endIndex: segmentStore.segmentEnd)
                
                // Story 8.4: Training Mode Configuration
                // Fix Bug: Learn Mode is now non-blocking (allowErrors = true)
                // We handle UI Sync in processInput by checking indexAdvanced
                engine.allowErrors = true
                engine.autoRestart = true
            } else {
                engine.start(mode: selectedMode.practiceEngineMode)
            }
            
            // Story 10.1: Apply Indulgent Mode Setting
            engine.isIndulgent = isAutoAdvanceEnabled
            print("debug: engine initialized with isIndulgent = \(engine.isIndulgent)")
            
            // Pre-warm the haptic engine only on success
            HapticService.shared.prewarm()
            
            // Validate Engine State
            if !engine.isActive && engine.state == .finished {
                // Engine finished immediately? This means start failed (e.g. loaded digits 0)
                self.errorState = "Failed to initialize practice engine. No digits available."
                return
            }
            
            // Story 9.1: Initialize Ghost only for Game Mode
            if selectedMode.hasGhost {
                if let pb = personalBestProvider(constant, selectedGhostType) {
                    if !pb.cumulativeTimes.isEmpty {
                        self.ghostEngine = GhostEngine(personalBest: pb)
                        print("debug: ghost engine initialized with \(pb.digitCount) digits for \(constant)")
                    } else {
                        self.ghostEngine = nil
                        print("debug: ghost engine skipped - PB found but cumulativeTimes is EMPTY!")
                    }
                } else {
                    self.ghostEngine = nil // No PB yet
                    print("debug: ghost engine skipped - personalBestProvider returned nil for \(constant)")
                }
            } else {
                self.ghostEngine = nil
            }
            
            // Story 9.5: Monitor Ghost for Victory/Defeat
            if let ghost = self.ghostEngine {
                ghostMonitorTask = Task { [weak self] in
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms check
                        
                        guard let self = self else { break }
                        // Use MainActor for property access & state change
                        await self.checkGhostStatus(ghost: ghost)
                    }
                }
            }
            
            // Reset UI state
            typedDigits = ""
            showErrorFlash = false
            lastCorrectDigit = nil
            expectedDigit = nil
            shouldDismiss = false
            revealsUsed = 0
            loops = 0
            isSessionSaved = false
            isSessionSaved = false
            isNewPR = false
            print("debug: session started for \(constant) in \(selectedMode) mode")
            
        } catch {
            print("❌ CRITICAL: Failed to start engine: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            self.errorState = "Failed to load resources: \(error.localizedDescription)"
            // Do NOT start the engine. Session remains inactive.
            // The UI should verify 'errorState' and show an alert or placeholder.
        }
    }
    
    private func checkGhostStatus(ghost: GhostEngine) async {
        guard isActive else { return }
        
        let currentGhostPos = ghost.position(at: Date())
        // print("debug: checkGhostStatus - Ghost: \(currentGhostPos)/\(ghost.totalDigits), Player: \(engine.currentIndex)")
        
        if currentGhostPos >= Double(ghost.totalDigits) && engine.currentIndex <= ghost.totalDigits {
            print("💀 GHOST WON! Player at \(engine.currentIndex) <= Ghost Total \(ghost.totalDigits)")
            isDefeatedByGhost = true
            engine.finishSession()
            await endSession()
        }
    }

    /// Processes a digit input from the keypad
    /// - Parameter digit: The digit (0-9)
    func processInput(_ digit: Int) {
        objectWillChange.send()
        
        // Story 9.5 Refined: Removed Sudden Death (delta check)
        
        let result = engine.input(digit: digit)
        print("debug: input \(digit), isCorrect: \(result.isCorrect), engine.isActive: \(engine.isActive)")
        
        // Critical Fix for Story 8.4: Sync UI with Engine state
        // If the engine advanced (whether correct or allowed error), update the UI string
        if result.indexAdvanced {
             typedDigits.append(String(digit))
             
             // Story 10.1: Track Indulgent Errors
             // If we advanced BUT it wasn't correct, it's an indulged error.
             if !result.isCorrect {
                 // The engine has already incremented currentIndex.
                 // So the error position is at currentIndex - 1.
                 // We use the 0-based index relative to the session start (matching typedDigits)
                 // Engine index is absolute logic, but typedDigits.count corresponds to entries.
                 // The index of the just-added digit is typedDigits.count - 1.
                 let errorIndex = typedDigits.count - 1
                 indulgentErrorIndices.insert(errorIndex)
             }
             
             // Story 9.1: Start ghost on first successful input
              if typedDigits.count == 1 {
                  ghostEngine?.start()
              }
         }
         
        // Story 9.5 Patch: Immediate ghost defeat check on input
        if let ghost = ghostEngine, isActive {
            let currentGhostPos = ghost.position(at: Date())
            if currentGhostPos >= Double(ghost.totalDigits) && engine.currentIndex < ghost.totalDigits {
                print("💀 GHOST WON (Immediate)! Player at \(engine.currentIndex), Ghost at \(ghost.totalDigits)")
                isDefeatedByGhost = true
                engine.finishSession()
                Task { await endSession() }
                return
            }
        }
        
        if result.isCorrect {
            // Success feedback
            lastCorrectDigit = digit
            expectedDigit = nil
            isShowingErrorReveal = false
            
            // Light haptic for success (instant)
            HapticService.shared.playSuccess()
        } else {
            // Error feedback
            expectedDigit = result.expectedDigit
            lastWrongInput = digit
            isShowingErrorReveal = true
            HapticService.shared.playError()
            
            // Story 9.6: Capture snapshot before first error in Practice AND Game mode
            if (selectedMode == .practice || selectedMode == .game) && firstErrorSnapshot == nil && revealsUsed == 0 {
                firstErrorSnapshot = SessionSnapshot(
                    index: engine.currentIndex,
                    time: engine.elapsedTime,
                    cumulativeTimes: engine.cumulativeTimes
                )
                print("debug: captured first error snapshot at index \(engine.currentIndex)")
            }
            
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                showErrorFlash = true
            }
            
            // Reset flash after a short delay (using centralized constant)
            DispatchQueue.main.asyncAfter(deadline: .now() + DesignSystem.Animations.errorFlashDuration) {
                self.showErrorFlash = false
                self.lastWrongInput = nil
            }
            
            // Story 9.5 Refined / User Feedback:
            // "If I make an error while ahead of the ghost and I have exceeded its streak record, 
            // then the game stops and if I made no errors BEFORE, the session is certified."
            if selectedMode == .game {
                let ghostTotal = ghostEngine?.totalDigits ?? 0
                if engine.currentIndex > ghostTotal {
                    print("⚡️ VICTORY STOP: Error while ahead of ghost record (\(engine.currentIndex) > \(ghostTotal)). Ending session.")
                    engine.finishSession()
                    Task { await endSession() }
                    return
                }
            }
            
            // Story 9.5 Refined: "Sudden Death" if ahead of ghost in Game Mode
        }
        
        // Story 8.4: Handle Engine Events (Looping)
        if let event = result.event {
            switch event {
            case .looped:
                // Loop detected: Clear typed digits and play reinforcement
                typedDigits = ""
                loops += 1
                HapticService.shared.playSuccess() // Loop Feedback
                // Optional: Visual flash for loop?
                
            case .finished:
                 Task { await endSession() }
            }
        } else {
            // Legacy/Standard Check
            if !engine.isActive {
                Task { await endSession() }
            }
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
    
    /// Toggles the permanent reveal state (Story 8.2)
    func toggleReveal() {
        // No longer used as a toggle in standard modes as per user request
    }
    
    /// Resets the current loop (Story 10.2)
    func resetLoop() {
        guard selectedMode == .learn else { return }
        
        // Reset Engine
        engine.resetLoop()
        
        // Reset local UI State
        typedDigits = ""
        showErrorFlash = false
        isShowingErrorReveal = false
        lastWrongInput = nil
        indulgentErrorIndices.removeAll()
        
        // Feedback
        HapticService.shared.playSelection()
    }
    
    /// Ends the session and saves stats
    func endSession(shouldDismiss: Bool = false) async {
        print("debug: endSession called. attempts: \(engine.attempts), isSessionSaved: \(isSessionSaved), shouldDismiss: \(shouldDismiss)")
        
        ghostMonitorTask?.cancel()
        ghostMonitorTask = nil
        
        // We allow ending if there were attempts made, regardless of engine state
        // This ensures we save sessions that are manually quit.
        // Story 8.5: Protection against double saving
        if engine.attempts > 0 && !isSessionSaved {
            print("debug: creating SessionRecord for \(selectedConstant) (mode: \(selectedMode))")
            
            // Story 9.5 & 9.6: Certification & Dynamic PR Recording
            // Certification Rule: 
            // - Basic: !learn AND 0 reveals
            // - Success condition: (0 errors OR Sudden Death Victory OR Test Mode fail OR PRACTICE MODE with snapshot)
            // - Failure condition: NOT Defeated by ghost
            
            let isPracticePR = selectedMode == .practice && revealsUsed == 0 && (engine.errors == 0 || firstErrorSnapshot != nil)
            let isCertified = revealsUsed == 0 && !isDefeatedByGhost && (
                selectedMode == .test || 
                selectedMode == .game || 
                isPracticePR
            )
            
            if isCertified {
                print("✅ Session CERTIFIED for PR (Mode: \(selectedMode), PracticePR: \(isPracticePR)).")
                
                // Story 9.6: Determine evaluation data (current engine OR snapshot before error)
                let evalIndex: Int
                let evalTime: TimeInterval
                let evalCumulative: [TimeInterval]
                
                if (selectedMode == .practice || selectedMode == .game) && engine.errors > 0, let snapshot = firstErrorSnapshot {
                    evalIndex = snapshot.index
                    evalTime = snapshot.time
                    evalCumulative = snapshot.cumulativeTimes
                    print("debug: using snapshot for PR evaluation (Index: \(evalIndex))")
                } else {
                    evalIndex = engine.currentIndex
                    evalTime = engine.elapsedTime
                    evalCumulative = engine.cumulativeTimes
                }
                
                // 1. Check for Crown (Distance/Marathon)
                let currentCrown = PersonalBestStore.shared.getRecord(for: selectedConstant, type: .crown)
                let isBetterCrown = currentCrown == nil || evalIndex > currentCrown!.digitCount || (evalIndex == currentCrown!.digitCount && evalTime < currentCrown!.totalTime)
                
                if isBetterCrown && evalIndex > 0 {
                    isNewPR = true
                    beatenPRTypes.insert(.crown)
                    let newCrown = PersonalBestRecord(
                        constant: selectedConstant,
                        type: .crown,
                        digitCount: evalIndex,
                        totalTime: evalTime,
                        cumulativeTimes: evalCumulative
                    )
                    print("debug: saving new crown PR: \(evalIndex) digits")
                    await PersonalBestStore.shared.save(record: newCrown)
                }
                
                // 2. Check for Lightning (Speed/Sprint) - Min 10 digits (Story 9.6)
                if evalIndex >= 10 {
                    let currentLightning = PersonalBestStore.shared.getRecord(for: selectedConstant, type: .lightning)
                    
                    // Re-calculate DPM based on evaluation data
                    let evalDPM = evalTime > 0 ? (Double(evalIndex) / (evalTime / 60.0)) : 0
                    
                    let isBetterLightning = currentLightning == nil || evalDPM > (currentLightning?.digitsPerMinute ?? 0)
                    
                    if isBetterLightning {
                        isNewPR = true
                        beatenPRTypes.insert(.lightning)
                        let newLightning = PersonalBestRecord(
                            constant: selectedConstant,
                            type: .lightning,
                            digitCount: evalIndex,
                            totalTime: evalTime,
                            cumulativeTimes: evalCumulative
                        )
                        print("debug: saving new lightning PR: \(evalDPM) CPS")
                        await PersonalBestStore.shared.save(record: newLightning)
                    }
                }
            } else {
                print("ℹ️ Session NOT CERTIFIED (Errors: \(engine.errors), Reveals: \(revealsUsed), Mode: \(selectedMode)). PB will not be updated.")
            }

            // Result tracking for Game Mode (Story 9.5)
        var wasVictory: Bool? = nil
        if selectedMode == .game {
            if isDefeatedByGhost {
                wasVictory = false
            } else {
                // If not defeated, check if player is at the end
                let reachedEnd = engine.currentIndex >= (ghostEngine?.totalDigits ?? 0)
                wasVictory = reachedEnd && !isDefeatedByGhost
            }
        }
        
        let record = SessionRecord(
            id: UUID(),
            date: Date(),
            constant: selectedConstant,
            mode: selectedMode.practiceEngineMode,
            sessionMode: selectedMode,
            attempts: engine.attempts,
            errors: engine.errors,
            bestStreakInSession: engine.bestStreak,
            durationSeconds: engine.elapsedTime,
            digitsPerMinute: engine.digitsPerMinute,
            revealsUsed: revealsUsed,
            minCPS: engine.minCPS == .infinity ? nil : engine.minCPS,
            maxCPS: engine.maxCPS,
            segmentStart: selectedMode == .learn ? segmentStore.segmentStart : nil,
            segmentEnd: selectedMode == .learn ? segmentStore.segmentEnd : nil,
            loops: loops,
            isCertified: isCertified,
            wasVictory: wasVictory,
            beatenPRTypes: beatenPRTypes.isEmpty ? nil : beatenPRTypes
        )
            
            isSessionSaved = true
            if let onSaveSession = onSaveSession {
                print("debug: invoking onSaveSession closure with record")
                onSaveSession(record)
            } else {
                print("⚠️ WARNING: onSaveSession is NIL! Session record might not be persisted in history.")
            }
            
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
