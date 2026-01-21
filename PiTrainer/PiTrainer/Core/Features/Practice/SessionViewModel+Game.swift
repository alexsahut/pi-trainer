import Foundation
import SwiftUI

extension SessionViewModel {
    /// Position effective du joueur (correctCount - errorCount)
    /// Story 9.2: Mapping pour la ligne d'horizon
    var playerEffectivePosition: Int {
        // En mode Learn,StartIndex peut être > 0
        // En mode Game, StartIndex est 0
        let currentProgress = engine.currentIndex - engine.startIndex
        return max(0, currentProgress - engine.errors)
    }
    
    /// Position du ghost (interpolée)
    var ghostPosition: Double {
        ghostEngine?.ghostPosition ?? 0
    }
    
    /// Target total pour le mapping (PB si Game mode, Segment si Learn mode)
    var totalDigitsForMapping: Int {
        if selectedMode == .learn {
            // Story 8.3/8.4 added currentSegmentLength
            return max(1, currentSegmentLength)
        } else if let ghostEngine = ghostEngine {
            return max(1, ghostEngine.totalDigits)
        } else {
            return 100 // Fallback constant pour Game Mode sans PB
        }
    }
    
    /// Ratio de progression du joueur (0.0 à 1.0)
    var playerProgressRatio: Double {
        let total = Double(max(1, totalDigitsForMapping))
        return Double(playerEffectivePosition) / total
    }
    
    /// Ratio de progression du ghost (0.0 à 1.0)
    var ghostProgressRatio: Double {
        let total = Double(max(1, totalDigitsForMapping))
        return Double(ghostPosition) / total
    }
    
    /// Détermine si la ligne d'horizon doit être affichée (Uniquement en mode Game)
    var showsHorizonLine: Bool {
        selectedMode.hasGhost
    }
    
    // MARK: - Story 9.3: Atmospheric Feedback
    
    /// Seuil de saturation pour l'effet d'opacité (en nombre de chiffres)
    private var maxAtmosphericDelta: Double { 5.0 }
    
    /// Calcule le delta entre le joueur et le ghost à un instant T
    /// Positif = Joueur en avance, Négatif = Joueur en retard
    func atmosphericDelta(at date: Date) -> Double {
        guard let ghost = ghostEngine else { return 0 }
        let currentGhostPos = ghost.position(at: date)
        return Double(playerEffectivePosition) - currentGhostPos
    }
    
    /// Couleur atmosphérique basée sur le delta
    func atmosphericColor(at date: Date) -> Color {
        guard selectedMode == .game else { return .clear }
        
        let delta = atmosphericDelta(at: date)
        if delta > 0 {
            return DesignSystem.Colors.cyanElectric
        } else if delta < 0 {
            return DesignSystem.Colors.orangeElectric
        } else {
            return .clear
        }
    }
    
    /// Opacité atmosphérique (5% à 20%)
    func atmosphericOpacity(at date: Date) -> Double {
        guard selectedMode == .game else { return 0 }
        
        let delta = abs(atmosphericDelta(at: date))
        if delta < 0.001 { return 0 }
        
        // Saturation de l'effet
        let ratio = min(1.0, delta / maxAtmosphericDelta)
        return 0.05 + (ratio * 0.15) // Échelle de 0.05 (5%) à 0.20 (20%)
    }
}
