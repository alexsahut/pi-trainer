import Foundation
import Observation

@Observable
final class GhostEngine {
    private let timestamps: [TimeInterval]
    private var startTime: Date?
    
    /// Position interpolée du Ghost (en nombre de décimales)
    var ghostPosition: Double {
        position(at: Date())
    }
    
    /// Calcule la position à un instant T précis (pour TimelineView)
    func position(at date: Date) -> Double {
        guard let startTime = startTime else { return 0 }
        let elapsed = date.timeIntervalSince(startTime)
        return calculateInterpolatedPosition(at: elapsed)
    }
    
    /// Nombre total de décimales dans le record du Ghost
    var totalDigits: Int {
        timestamps.count
    }
    
    func calculateInterpolatedPosition(at elapsed: TimeInterval) -> Double {
        guard !timestamps.isEmpty else { return 0 }
        if elapsed <= 0 { return 0 }
        
        // Recherche du segment
        for i in 0..<timestamps.count {
            let endTime = timestamps[i]
            let startTime = i > 0 ? timestamps[i-1] : 0
            
            if elapsed <= endTime {
                let segmentDuration = endTime - startTime
                let progressInSegment = segmentDuration > 0 ? (elapsed - startTime) / segmentDuration : 1.0
                return Double(i) + progressInSegment
            }
        }
        
        return Double(timestamps.count)
    }
    
    /// Démarrage officiel du fantôme (au premier input utilisateur)
    func start() {
        guard startTime == nil else { return }
        self.startTime = Date()
    }
    
    init(personalBest: PersonalBestRecord) {
        self.timestamps = personalBest.cumulativeTimes
        self.startTime = nil
    }
}
