import SwiftUI

@Observable
final class ProPadViewModel {
    
    var opacity: Double = 0.2
    var inactivityThreshold: TimeInterval = 3.0 // Configurable for testing
    private var isGhostModeEnabled: Bool = true
    private var currentStreak: Int = 0
    private var lastInputTime: Date = Date()
    private var inactivityTimer: Timer?
    
    private let haptics = HapticService.shared
    
    // Actions to be handled by the parent view
    var onDigit: ((Int) -> Void)?
    var onAction: ((KeypadAction) -> Void)?
    
    enum KeypadAction {
        case backspace
        case options
    }
    
    /// Computed property to determine target opacity based on streak and activity
    private var targetOpacity: Double {
        guard isGhostModeEnabled else { return 1.0 }
        guard currentStreak >= 20 else { return 0.2 }
        
        // Check if inactive for threshold seconds
        let timeSinceLastInput = Date().timeIntervalSince(lastInputTime)
        return timeSinceLastInput >= inactivityThreshold ? 0.2 : 0.05
    }
    
    func triggerHaptics() {
        if haptics.isEnabled {
            haptics.playTap()
        }
    }
    
    func onPrepare() {
        haptics.prepare()
    }
    
    func updateGhostMode(_ enabled: Bool) {
        isGhostModeEnabled = enabled
        updateOpacity(animated: true, fastTransition: true)
    }
    
    /// Update current streak and adjust opacity accordingly
    func updateStreak(_ streak: Int) {
        currentStreak = streak
        updateOpacity(animated: true, fastTransition: streak < 20)
    }
    
    func digitPressed(_ digit: Int) {
        lastInputTime = Date()
        resetInactivityTimer()
        haptics.playTap()
        onDigit?(digit)
        updateOpacity(animated: true, fastTransition: false)
    }
    
    func actionPressed(_ action: KeypadAction) {
        lastInputTime = Date()
        resetInactivityTimer()
        haptics.playTap() // Feedback for all keys
        onAction?(action)
        // No opacity update for action buttons
    }
    
    /// Update opacity with animation
    private func updateOpacity(animated: Bool, fastTransition: Bool) {
        let target = targetOpacity
        
        // Avoid redundant animation restarts if opacity hasn't changed
        guard target != opacity else { return }
        
        let duration = fastTransition ? 0.5 : 1.0
        let animation = fastTransition ? Animation.easeOut(duration: duration) : Animation.easeInOut(duration: duration)
        
        // Respect Reduced Motion settings
        let shouldAnimate = animated && !UIAccessibility.isReduceMotionEnabled
        
        if shouldAnimate {
            withAnimation(animation) {
                opacity = target
            }
        } else {
            opacity = target
        }
    }
    
    /// Reset inactivity timer - called on each digit press
    private func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        
        // Only start timer if we're in ghost mode (streak >= 20)
        guard currentStreak >= 20 else { return }
        
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityThreshold, repeats: false) { [weak self] _ in
            self?.updateOpacity(animated: true, fastTransition: false)
        }
    }
    
    deinit {
        inactivityTimer?.invalidate()
    }
}
