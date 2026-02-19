//
//  DailyChallengeCard.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 25/01/2026.
//

import SwiftUI

struct DailyChallengeCard: View {
    let challenge: Challenge
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header: Icon + Title
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(DesignSystem.Colors.orangeElectric)
                    Text("DAILY CHALLENGE")
                        .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                Spacer()
                
                // Constant Badge (e.g. π)
                Text(challenge.constant.symbol)
                    .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                    .padding(6)
                    .background(DesignSystem.Colors.cyanElectric.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(challengeDescription)
                    .font(DesignSystem.Fonts.primary(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if isCompleted {
                    Text("COMPLETE!")
                        .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Button
            ZenPrimaryButton(
                title: isCompleted ? "REPLAY" : "START",
                style: isCompleted ? .secondary : .zen,
                accessibilityIdentifier: "challenge.start_button",
                action: action
            )
        }
        .padding(20)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.green.opacity(0.5) : DesignSystem.Colors.orangeElectric.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var challengeDescription: String {
        String(localized: "challenge.card_description", defaultValue: "Continue the sequence and test your memory")
    }
}
