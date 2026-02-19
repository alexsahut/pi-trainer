//
//  Grade.swift
//  PiTrainer
//
//  Created by Antigravity on 24/01/2026.
//

import SwiftUI

/// Represents the rank of a memory athlete based on their total XP (correct digits).
enum Grade: String, CaseIterable, Codable {
    case novice
    case apprentice
    case athlete
    case expert
    case grandmaster
    
    /// XP Thresholds
    static func from(xp: Int) -> Grade {
        switch xp {
        case 0..<1000:
            return .novice
        case 1000..<5000:
            return .apprentice
        case 5000..<20000:
            return .athlete
        case 20000..<100000:
            return .expert
        default:
            return .grandmaster
        }
    }
    
    /// Display name for the grade
    var displayName: String {
        switch self {
        case .novice: return "Novice"
        case .apprentice: return "Apprentice"
        case .athlete: return "Athlete"
        case .expert: return "Expert"
        case .grandmaster: return "Grandmaster"
        }
    }
    
    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .novice: return "leaf.fill"
        case .apprentice: return "medal.fill"
        case .athlete: return "figure.run"
        case .expert: return "brain.head.profile"
        case .grandmaster: return "crown.fill"
        }
    }
    
    /// Color associated with the grade
    var color: Color {
        switch self {
        case .novice: return .green
        case .apprentice: return .blue
        case .athlete: return DesignSystem.Colors.cyanElectric
        case .expert: return .purple
        case .grandmaster: return .yellow
        }
    }
    
    /// XP Range description
    var rangeDescription: String {
        switch self {
        case .novice: return "0 - 999"
        case .apprentice: return "1,000 - 4,999"
        case .athlete: return "5,000 - 19,999"
        case .expert: return "20,000 - 99,999"
        case .grandmaster: return "100,000+"
        }
    }
    /// Number of digits to guess in Daily Challenge
    var challengeLength: Int {
        switch self {
        case .novice: return 3
        case .apprentice: return 5
        case .athlete: return 8
        case .expert: return 12
        case .grandmaster: return 15
        }
    }
}
