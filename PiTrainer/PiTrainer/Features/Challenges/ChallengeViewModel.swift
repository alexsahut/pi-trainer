import Foundation
import SwiftUI

@Observable
class ChallengeViewModel {
    let challenge: Challenge
    
    var currentInput: String = ""
    var isCompleted: Bool = false
    var isErrorShakeActive: Bool = false
    
    // Derived properties
    var isShowingRecovery: Bool = false
    var shouldNavigateToPractice: Bool = false
    
    // Dependencies
    private let hapticService: HapticService
    private let statsStore: StatsStore
    private let segmentStore: SegmentStore
    
    // Derived properties
    var prompt: String {
        challenge.referenceSequence
    }
    
    var targetLength: Int {
        challenge.expectedNextDigits.count
    }
    
    var targetDigits: String {
        challenge.expectedNextDigits
    }
    
    var displayTarget: String {
        var result = ""
        let inputCount = currentInput.count
        
        for i in 0..<targetLength {
            if i < inputCount {
                let index = currentInput.index(currentInput.startIndex, offsetBy: i)
                result += String(currentInput[index])
            } else if isErrorShakeActive && i == inputCount {
                // REVEAL LOGIC: If error input occurred, show what WAS expected at this index
                let expectedIndex = targetDigits.index(targetDigits.startIndex, offsetBy: i)
                result += String(targetDigits[expectedIndex])
            } else {
                result += "_"
            }
            
            if i < targetLength - 1 {
                result += " "
            }
        }
        return result
    }
    
    // Story 13.2: Dependency Injection for better testability
    init(challenge: Challenge, 
         hapticService: HapticService = .shared,
         statsStore: StatsStore = .shared,
         segmentStore: SegmentStore = .shared) {
        self.challenge = challenge
        self.hapticService = hapticService
        self.statsStore = statsStore
        self.segmentStore = segmentStore
    }
    
    func handleInput(_ digit: Int) {
        guard !isCompleted else { return }
        let input = String(digit)
        
        // Reset error state on new input
        if isErrorShakeActive {
            isErrorShakeActive = false
        }
        
        // Check if input matches expected digit at current position
        let currentIndex = currentInput.count
        guard currentIndex < targetLength else { return }
        
        let expectedIndex = targetDigits.index(targetDigits.startIndex, offsetBy: currentIndex)
        let expectedDigit = String(targetDigits[expectedIndex])
        
        if input == expectedDigit {
            currentInput += input
            hapticService.playSuccess() // Immediate feedback per digit
            
            if currentInput.count == targetLength {
                isCompleted = true
                hapticService.playDoubleBang() // Reward!
                statsStore.creditXP(amount: targetLength) // Task 13.2: Credit XP
            }
        } else {
            // Error!
            triggerError()
        }
    }
    
    func handleBackspace() {
        guard !isCompleted, !currentInput.isEmpty else { return }
        currentInput.removeLast()
        isErrorShakeActive = false
        isShowingRecovery = false // Hide recovery if user corrects (or tries to)
    }
    
    func reset() {
        guard !isCompleted else { return }
        currentInput = ""
        isErrorShakeActive = false
        isShowingRecovery = false
    }
    
    /// Story 14.1: Recovery Bridge - Transitions to Learn mode for the failed pattern context
    func triggerRecovery() {
        // Calculate the absolute index where the user is currently (next expected digit)
        // or where they failed (currentInput.count represents the index of the character they are trying to type)
        let localFailIndex = currentInput.count
        let absoluteIndex = challenge.startIndex + challenge.referenceSequence.count + localFailIndex
        
        // Align to chunk
        let segmentStart = (absoluteIndex / DesignSystem.Constants.chunkSize) * DesignSystem.Constants.chunkSize
        let segmentEnd = segmentStart + DesignSystem.Constants.chunkSize
        
        print("debug: Recovery Bridge triggered. Absolute Error Index: \(absoluteIndex). Setting Segment: \(segmentStart)-\(segmentEnd)")
        
        // Update Stores
        segmentStore.segmentStart = segmentStart
        segmentStore.segmentEnd = segmentEnd
        statsStore.selectedMode = .learn
        
        // Trigger Navigation
        withAnimation {
            shouldNavigateToPractice = true
        }
    }
    
    private func triggerError() {
        hapticService.playError()
        withAnimation {
            isErrorShakeActive = true
            isShowingRecovery = true // Reveal the bridge
        }
    }
}
