//
//  RewardManager.swift
//  PiTrainer
//
//  Created by Antigravity on 25/01/2026.
//

import Foundation
import Observation

/// Manages celebration states and special rewards like the "Double Bang".
@Observable
final class RewardManager {
    
    // MARK: - Singleton
    static let shared = RewardManager()
    
    // MARK: - Properties
    
    /// Indicates if the "Double Bang" celebration is currently active.
    var isDoubleBangActive: Bool = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Triggers the "Double Bang" celebration.
    func triggerDoubleBang() {
        isDoubleBangActive = true
        HapticService.shared.playDoubleBang()
    }
    
    /// Resets the celebration state.
    func resetDoubleBang() {
        isDoubleBangActive = false
    }
}
