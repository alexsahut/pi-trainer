//
//  RecordDashboardView.swift
//  PiTrainer
//
//  Created by Antigravity on 17/01/2026.
//

import SwiftUI

struct RecordDashboardView: View {
    @ObservedObject var statsStore: StatsStore
    
    private let constants: [Constant] = [.pi, .e, .phi, .sqrt2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("stats.dashboard.title")
                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .black))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .tracking(2)
                .accessibilityIdentifier("stats.dashboard.title")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(constants, id: \.self) { constant in
                        RecordCard(
                            constant: constant,
                            stats: statsStore.stats(for: constant)
                        )
                    }
                }
            }
            .accessibilityIdentifier("stats.dashboard.scroll_view")
        }
        .padding(.vertical, 8)
    }
}

struct RecordCard: View {
    let constant: Constant
    let stats: ConstantStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(constant.symbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                
                Spacer()
                
                Text(constant.rawValue.uppercased())
                    .font(DesignSystem.Fonts.monospaced(size: 10, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(stats.bestStreak)")
                    .font(DesignSystem.Fonts.monospaced(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("stats.dashboard.digits_count \(stats.bestStreak)")
                    .font(DesignSystem.Fonts.monospaced(size: 10, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            if let lastSession = stats.lastSession {
                Text(lastSession.date.formatted(.dateTime.day().month().year()).uppercased())
                    .font(DesignSystem.Fonts.monospaced(size: 9, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.7))
            } else {
                Text("stats.dashboard.no_session")
                    .font(DesignSystem.Fonts.monospaced(size: 9, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.5))
            }
        }
        .padding(16)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.cyanElectric.opacity(0.1), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(constant.rawValue): \(stats.bestStreak) digits")
        .accessibilityIdentifier("stats.dashboard.card.\(constant.rawValue)")
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        RecordDashboardView(statsStore: StatsStore())
    }
}
