//
//  XPProgressBar.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 24/01/2026.
//

import SwiftUI

struct XPProgressBar: View {
    let xp: Int
    let grade: Grade
    
    private static let xpRanges: [Grade: ClosedRange<Double>] = [
        .novice: 0...1000,
        .apprentice: 1000...5000,
        .athlete: 5000...20000,
        .expert: 20000...100000,
        .grandmaster: 100000...1000000 // Arbitrary high limit
    ]

    // Calculate progress towards next grade
    var progress: Double {
        let currentXP = Double(xp)
        guard let range = XPProgressBar.xpRanges[grade] else { return 0 }
        let min = range.lowerBound
        let max = range.upperBound

        if xp >= Int(max) { return 1.0 }
        return (currentXP - min) / (max - min)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("PROGRESSION")
                    .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(DesignSystem.Fonts.monospaced(size: 10, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.cyanElectric.opacity(0.8), DesignSystem.Colors.cyanElectric],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .shadow(color: DesignSystem.Colors.cyanElectric.opacity(0.4), radius: 5)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        VStack(spacing: 30) {
            XPProgressBar(xp: 450, grade: .novice)
            XPProgressBar(xp: 2500, grade: .apprentice)
            XPProgressBar(xp: 15000, grade: .athlete)
        }
        .padding()
    }
}
