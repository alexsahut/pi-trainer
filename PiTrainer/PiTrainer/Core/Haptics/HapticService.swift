//
//  HapticService.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 16/01/2026.
//

import Foundation
import CoreHaptics
import UIKit

/// Service responsible for managing Core Haptics engine and playing custom patterns.
/// Provides low-latency feedback for user interactions.
class HapticService {
    
    // MARK: - Singleton
    
    static let shared = HapticService()
    
    // MARK: - Properties
    
    private var engine: CHHapticEngine?
    private var isEngineRunning = false
    
    public var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "haptics_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "haptics_enabled") }
    }
    
    // MARK: - Initialization
    
    private init() {
         // Default to true if not set
        if UserDefaults.standard.object(forKey: "haptics_enabled") == nil {
            UserDefaults.standard.set(true, forKey: "haptics_enabled")
        }
        createEngine()
    }
    
    // MARK: - Engine Management
    
    /// Creates and configures the Haptic Engine
    private func createEngine() {
        // Prevent engine creation during unit tests to avoid CI hangs
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            print("Haptic Engine creation skipped (Unit Testing environment)")
            return
        }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            
            // Handle reset handler
            engine?.resetHandler = { [weak self] in
                print("Haptic Engine Reset")
                // Try restarting the engine
                do {
                    try self?.engine?.start()
                    self?.isEngineRunning = true
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
            // Handle stopped handler
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic Engine Stopped: \(reason)")
                self?.isEngineRunning = false
            }
            
        } catch {
            print("Haptic Engine Creation Error: \(error)")
        }
    }
    
    /// Pre-warms the engine to minimize latency before first use.
    /// Should be called when the practice session view appears.
    func prewarm() {
        guard let engine = engine, !isEngineRunning else { return }
        
        do {
            try engine.start()
            isEngineRunning = true
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    /// Legacy alias for prewarm
    func prepare() {
        prewarm()
    }
    
    /// Stops the engine to save power when not needed.
    func stop() {
        guard let engine = engine, isEngineRunning else { return }
        engine.stop(completionHandler: { error in
            if let error = error {
                print("Error stopping haptic engine: \(error)")
            } else {
                self.isEngineRunning = false
            }
        })
    }
    
    // MARK: - Patterns
    
    /// Plays a crisp, transient "Success" haptic pattern.
    /// Designed for <16ms latency perception.
    func playSuccess() {
        guard isEnabled else { return }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Fallback for devices without Core Haptics support
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }
        
        // Ensure engine is running
        if !isEngineRunning {
            try? engine?.start()
            isEngineRunning = true
        }
        
        // Fire and forget pattern
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play success haptic: \(error)")
        }
    }
    
    /// Plays a crisp, immediate "tap" feel for validating input
    func playTap() {
        guard isEnabled else { return }

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else {
            // Fallback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            return
        }
        
        // Ensure engine is running
        if !isEngineRunning {
            try? engine.start()
            isEngineRunning = true
        }
        
        // Fire and forget pattern
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play tap haptic: \(error)")
        }
    }
    
    /// Plays a distinct "Error" haptic pattern (double vibration).
    func playError() {
        guard isEnabled else { return }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Fallback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        if !isEngineRunning {
            try? engine?.start()
            isEngineRunning = true
        }
        
        // Complex pattern: Two bumps
        let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity1, sharpness1], relativeTime: 0)
        
        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.1) // 100ms delay
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play error haptic: \(error)")
        }
    }
    
    /// Plays a light selection specific haptic feedback
    func playSelection() {
        guard isEnabled else { return }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            return
        }
        
        if !isEngineRunning {
            try? engine?.start()
            isEngineRunning = true
        }
        
        // Very light transient
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play selection haptic: \(error)")
        }
    }
    
    /// Plays a composite "Double Bang" haptic pattern (Reward celebration).
    /// Combines success transient with heavy impact and rumble.
    func playDoubleBang() {
        guard isEnabled else { return }
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            // Reinforced fallback for older devices
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let heavy = UIImpactFeedbackGenerator(style: .heavy)
                heavy.impactOccurred()
            }
            return
        }
        
        if !isEngineRunning {
            try? engine?.start()
            isEngineRunning = true
        }
        
        // Pattern: Success Transient -> Heavy Impact -> Rumble
        // 0.0s: Success
        let intensityS = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpnessS = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let success = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityS, sharpnessS], relativeTime: 0)
        
        // 0.1s: Impact
        let intensityI = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpnessI = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let impact = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityI, sharpnessI], relativeTime: 0.1)
        
        // 0.2s - 0.5s: Rumble
        let intensityR = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpnessR = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let transientR = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityR, sharpnessR], relativeTime: 0.2, duration: 0.3)
        
        do {
            let pattern = try CHHapticPattern(events: [success, impact, transientR], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play Double Bang haptic: \(error)")
        }
    }
}
