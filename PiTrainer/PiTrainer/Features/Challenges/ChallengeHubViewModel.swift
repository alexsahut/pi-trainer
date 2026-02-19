import Foundation
import SwiftUI

@Observable
class ChallengeHubViewModel {
    var dailyChallenge: Challenge?
    var presentedChallenge: Challenge?
    var isPresentedChallengeDaily: Bool = false
    var isDailyCompleted: Bool = false
    var errorText: String?
    
    private let service: ChallengeServiceProtocol
    private let statsStore: StatsStore
    
    init(service: ChallengeServiceProtocol,
         statsStore: StatsStore = .shared) {
        self.service = service
        self.statsStore = statsStore
    }
    
    func loadDailyChallenge() async {
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
