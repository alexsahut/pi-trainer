import SwiftUI

struct HorizonLineView: View {
    /// Ratio de progression du joueur (0.0 à 1.0)
    let playerProgress: Double
    
    /// Engine du ghost pour l'interpolation temps réel
    let ghostEngine: GhostEngine?
    
    /// Total de décimales pour le mapping
    let totalDigits: Int
    
    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Ligne d'horizon (1px)
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 1)
                        .accessibilityHidden(true)
                    
                    // Position du Ghost (Point Gris)
                    if let ghostEngine = ghostEngine {
                        let ghostPos = ghostEngine.position(at: timeline.date)
                        let ghostRatio = ghostPos / Double(max(1, totalDigits))
                        
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 4, height: 4)
                            .offset(x: position(for: ghostRatio, in: geometry.size.width) - 2)
                    }
                    
                    // Position du Joueur (Point Blanc)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .offset(x: position(for: playerProgress, in: geometry.size.width) - 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: playerProgress)
                        .shadow(color: .white.opacity(0.3), radius: 2)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 4)
        .accessibilityHidden(true)
    }
    
    private func position(for ratio: Double, in width: CGFloat) -> CGFloat {
        let clampedRatio = max(0, min(ratio, 1.0))
        return CGFloat(clampedRatio) * width
    }
}

#Preview {
    ZStack {
        Color.black
        HorizonLineView(playerProgress: 0.3, ghostEngine: nil, totalDigits: 100)
            .padding()
    }
}
