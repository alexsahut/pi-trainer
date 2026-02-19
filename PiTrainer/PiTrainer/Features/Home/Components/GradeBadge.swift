//
//  GradeBadge.swift
//  PiTrainer
//
//  Created by Antigravity on 24/01/2026.
//

import SwiftUI

struct GradeBadge: View {
    let grade: Grade
    let xp: Int
    var showXP: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            // Badge Icon with Glow
            ZStack {
                Circle()
                    .fill(grade.color.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: grade.iconName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(grade.color)
                    .shadow(color: grade.color.opacity(0.6), radius: 15)
            }
            .padding(.bottom, 4)
            
            // Grade Name
            Text(grade.displayName.uppercased())
                .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                .foregroundColor(.white)
                .tracking(2)
            
            if showXP {
                // XP Text
                HStack(spacing: 4) {
                    Text("\(xp)")
                        .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                    Text("grade.xp")
                        .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .foregroundColor(DesignSystem.Colors.cyanElectric)
            }
        }
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 40) {
                GradeBadge(grade: .novice, xp: 150)
                GradeBadge(grade: .apprentice, xp: 1200)
                GradeBadge(grade: .athlete, xp: 7500)
                GradeBadge(grade: .expert, xp: 25000)
                GradeBadge(grade: .grandmaster, xp: 120000)
            }
            .padding()
        }
    }
}
