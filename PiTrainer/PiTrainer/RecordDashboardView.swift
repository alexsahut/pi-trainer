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
    
    // Fetch records from PersonalBestStore
    private var crownRecord: PersonalBestRecord? {
        PersonalBestStore.shared.getRecord(for: constant, type: .crown)
    }
    
    private var lightningRecord: PersonalBestRecord? {
        PersonalBestStore.shared.getRecord(for: constant, type: .lightning)
    }
    
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
            
            VStack(alignment: .leading, spacing: 8) {
                // Crown Record (Distance)
                RecordRow(
                    icon: "crown.fill",
                    iconColor: .yellow,
                    value: "\(crownRecord?.digitCount ?? 0)",
                    subValue: formatTime(crownRecord?.totalTime ?? 0),
                    isPlaceholder: crownRecord == nil
                )
                
                // Lightning Record (Speed)
                RecordRow(
                    icon: "bolt.fill",
                    iconColor: .orange,
                    value: String(format: "%.1f", lightningRecord?.digitsPerMinute ?? 0),
                    unit: "DPM",
                    isPlaceholder: lightningRecord == nil
                )
            }
        }
        .padding(16)
        .frame(width: 160) // Slightly wider to accommodate dual records
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.cyanElectric.opacity(0.1), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(constant.rawValue) records")
        .accessibilityIdentifier("stats.dashboard.card.\(constant.rawValue)")
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds > 0 else { return "--:--" }
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%01d:%02d", minutes, remainingSeconds)
    }
}

struct RecordRow: View {
    let icon: String
    let iconColor: Color
    let value: String
    var unit: String? = nil
    var subValue: String? = nil
    let isPlaceholder: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isPlaceholder ? .white.opacity(0.1) : iconColor)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                        .foregroundColor(isPlaceholder ? .white.opacity(0.1) : .white)
                    
                    if let unit = unit {
                        Text(unit)
                            .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                            .foregroundColor(isPlaceholder ? .white.opacity(0.1) : DesignSystem.Colors.textSecondary)
                    }
                }
                
                if let subValue = subValue {
                    Text(subValue)
                        .font(DesignSystem.Fonts.monospaced(size: 10, weight: .bold))
                        .foregroundColor(isPlaceholder ? .white.opacity(0.1) : DesignSystem.Colors.cyanElectric)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        RecordDashboardView(statsStore: StatsStore())
    }
}
