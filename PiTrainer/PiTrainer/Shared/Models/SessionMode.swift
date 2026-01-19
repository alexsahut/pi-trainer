//
//  SessionMode.swift
//  PiTrainer
//
//  Created by Story 7.1 Implementation
//  V2 Session Mode system for dual selector pattern
//

import Foundation

/// Session modes available in PiTrainer V2
/// - Important: Order matters! Learn MUST be first (`allCases[0]`) as it's the default mode
enum SessionMode: String, CaseIterable, Codable, CustomStringConvertible {
    case learn    // Errors allowed, overlay visible, educational focus
    case practice // Errors allowed, no overlay, free practice
    case test     // Sudden death - any error ends session (formerly strict)
    case game     // Race against ghost, errors penalize position
    
    // MARK: - CustomStringConvertible
    
    var description: String { displayName }
    
    // MARK: - Display
    
    /// Display name for UI (UPPERCASE)
    var displayName: String {
        switch self {
        case .learn: return "LEARN"
        case .practice: return "PRACTICE"
        case .test: return "TEST"
        case .game: return "GAME"
        }
    }
    
    // MARK: - Computed Properties
    
    /// Whether errors are allowed (don't end session immediately)
    /// - Returns: `true` for learn, practice, game. `false` for strict.
    var allowsErrors: Bool {
        switch self {
        case .test: return false
        default: return true
        }
    }
    
    /// Whether the overlay (next digits) is shown permanently (Ghost Mode visibility)
    var showsPermanentOverlay: Bool {
        self == .learn
    }
    
    /// Whether the reveal mechanism (Eye icon) is allowed in this mode
    var allowsReveal: Bool {
        self == .learn || self == .practice
    }
    
    /// Whether the ghost (PR replay) is active
    /// - Returns: `true` only for game mode
    var hasGhost: Bool {
        self == .game
    }
    
    /// Whether errors penalize the player's effective position
    /// - Returns: `true` only for game mode
    var penalizesErrors: Bool {
        self == .game
    }
    
    // MARK: - Bridging to PracticeEngine.Mode
    
    /// Converts SessionMode to the legacy PracticeEngine.Mode
    /// - Note: This is a bridge for backward compatibility during V2 migration
    var practiceEngineMode: PracticeEngine.Mode {
        switch self {
        case .learn, .practice, .game:
            // All non-test modes map to learning (errors allowed)
            return .learning
        case .test:
            return .strict
        }
    }
    
    // MARK: - Migration (Story 8.5)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Handle legacy "strict" name
        if rawValue == "strict" {
            self = .test
        } else {
            self = SessionMode(rawValue: rawValue) ?? .learn
        }
    }
}
