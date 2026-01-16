//
//  StreakFlowEffect.swift
//  PiTrainer
//
//  A ViewModifier that provides progressive visual glow effects based on
//  success streaks. Creates a multi-layer shadow effect that intensifies
//  as the streak increases, providing visual feedback for the "Flow" state.
//
//  Performance: Uses GPU-accelerated shadow rendering via SwiftUI's Metal pipeline.
//  The effect is designed to maintain 60 FPS even during continuous animations.
//

import SwiftUI

/// A ViewModifier that adds a progressive glow effect based on the current streak.
///
/// Glow Tiers:
/// - **Inactive** (0-9): No glow
/// - **Subtle** (10-19): Cyan aura with 0.3 intensity, radius 8
/// - **Intense** (20+): Cyan aura with 0.6 intensity, radius 16
///
/// The effect uses 3 shadow layers with varying intensities to create
/// a natural, diffused glow effect that doesn't look harsh or artificial.
struct StreakFlowEffect: ViewModifier {
    /// The current streak count
    let streak: Int
    
    // MARK: - Glow Properties
    
    /// Calculated glow intensity based on streak tier
    /// - Returns: 0.0 for inactive, 0.3 for subtle, 0.6 for intense
    @inlinable
    var glowIntensity: Double {
        switch streak {
        case ..<0:
            return 0.0  // Invalid - negative streaks have no glow
        case 0..<10:
            return 0.0  // Inactive - no glow
        case 10..<20:
            return 0.3  // Subtle - first milestone
        default:
            return 0.6  // Intense - flow state
        }
    }
    
    /// Calculated glow radius based on streak tier
    /// - Returns: 0 for inactive, 8 for subtle, 16 for intense
    @inlinable
    var glowRadius: CGFloat {
        switch streak {
        case ..<0:
            return 0    // Invalid - negative streaks have no glow
        case 0..<10:
            return 0    // Inactive - no glow
        case 10..<20:
            return 8    // Subtle - small aura
        default:
            return 16   // Intense - larger aura
        }
    }
    
    // MARK: - ViewModifier Body
    
    func body(content: Content) -> some View {
        content
            // Layer 1: Inner glow (softest, closest to content)
            .shadow(
                color: DesignSystem.Colors.cyanElectric.opacity(glowIntensity * 0.3),
                radius: glowRadius * 0.5
            )
            // Layer 2: Middle glow (medium spread)
            .shadow(
                color: DesignSystem.Colors.cyanElectric.opacity(glowIntensity * 0.5),
                radius: glowRadius
            )
            // Layer 3: Outer glow (most diffused, creates halo)
            .shadow(
                color: DesignSystem.Colors.cyanElectric.opacity(glowIntensity * 0.7),
                radius: glowRadius * 1.5
            )
            // Animate changes to the streak value with 0.8s easing
            // Note: All transitions use same duration (deviation from UX spec)
            // Original spec: 0.8s activate, 1.0s intensify, 0.3s deactivate
            .animation(.easeInOut(duration: 0.8), value: streak)
            // Hide from VoiceOver (purely visual effect)
            .accessibilityHidden(true)
    }
}


