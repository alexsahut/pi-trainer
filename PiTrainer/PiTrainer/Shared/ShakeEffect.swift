//
//  ShakeEffect.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 16/01/2026.
//

import SwiftUI

/// A geometry effect that shakes the view.
/// Useful for error feedback.
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        // Simple sine wave shake
        // 10 shakes per unit of animatableData
        let translation = 10 * sin(animatableData * .pi * 3)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
