import Foundation
import SwiftUI

@Observable
@MainActor
class ChallengeHubViewModel {
    var dailyChallenge: Challenge?
    var presentedChallenge: Challenge?
    var isPresentedChallengeDaily: Bool = false
    var isDailyCompleted: Bool = false
    var errorText: String?
    
    /// Minimum number of digits the user must have practiced before challenges unlock
    static let minimumDigitsForChallenge = 50
    
    /// Whether the user has practiced enough digits to access challenges
    var isChallengeEligible: Bool {
        persistence.getHighestIndex(for: statsStore.selectedConstant.id) >= Self.minimumDigitsForChallenge
    }
    
    /// How many more digits the user needs to unlock challenges
    var digitsRemainingToUnlock: Int {
        let current = persistence.getHighestIndex(for: statsStore.selectedConstant.id)
        return max(0, Self.minimumDigitsForChallenge - current)
    }
    
    private let service: ChallengeServiceProtocol
    private let statsStore: StatsStore
    private let persistence: PracticePersistenceProtocol
    
    init(service: ChallengeServiceProtocol,
         statsStore: StatsStore = .shared,
         persistence: PracticePersistenceProtocol? = nil) {
        self.service = service
        self.statsStore = statsStore
        self.persistence = persistence ?? PracticePersistence()
    }
    
    func loadDailyChallenge() async {
        guard isChallengeEligible else {
            self.errorText = nil  // Not an error — it's a pre-requisite
            self.dailyChallenge = nil
            return
        }
        
        let today = Date()
        let constant = statsStore.selectedConstant
        let grade = statsStore.currentGrade
        
        if let generated = await service.generateDailyChallenge(for: constant, date: today, grade: grade) {
            self.dailyChallenge = generated
            self.isDailyCompleted = service.isChallengeCompleted(for: today)
            self.errorText = nil
        } else {
            self.errorText = "No challenge available for today."
        }
    }
    
    func trainNow() async {
        guard isChallengeEligible else {
            self.errorText = nil
            return
        }
        
        let constant = statsStore.selectedConstant
        let grade = statsStore.currentGrade
        
        if let generated = await service.generateRandomChallenge(for: constant, grade: grade) {
            self.presentedChallenge = generated
            self.isPresentedChallengeDaily = false
            self.errorText = nil
        } else {
            self.errorText = "Failed to generate training challenge."
        }
    }
    
    func startDailyChallenge() {
        guard let challenge = dailyChallenge else { return }
        self.presentedChallenge = challenge
        self.isPresentedChallengeDaily = true
    }
}
