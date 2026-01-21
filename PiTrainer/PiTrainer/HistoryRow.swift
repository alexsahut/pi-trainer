//
//  HistoryRow.swift
//  PiTrainer
//
//  Created by Antigravity on 17/01/2026.
//

import SwiftUI

struct HistoryRow: View {
    let session: SessionRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Date & Mode
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date.formatted(.dateTime.day().month().year()).uppercased())
                    .font(DesignSystem.Fonts.monospaced(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: iconForMode(session.sessionMode))
                        .font(.system(size: 8))
                    
                    Text(session.sessionMode.displayName)
                        .font(DesignSystem.Fonts.monospaced(size: 9, weight: .bold))
                    
                    if session.sessionMode == .game {
                        if session.wasVictory == true {
                             Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                        } else if session.wasVictory == false {
                             Image(systemName: "xmark.seal.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if session.isCertified {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 8))
                            .foregroundColor(DesignSystem.Colors.cyanElectric)
                    }
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Middle: Streak or Loops
            VStack(alignment: .trailing, spacing: 2) {
                if session.sessionMode == .learn {
                    Text("\(session.loops)")
                        .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.cyanElectric)
                    
                    Text("stats.history.loops_label")
                        .font(DesignSystem.Fonts.monospaced(size: 8, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                } else {
                    Text("\(session.bestStreakInSession)")
                        .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.cyanElectric)
                    
                    Text("stats.history.record_label")
                        .font(DesignSystem.Fonts.monospaced(size: 8, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .frame(width: 60)
            
            // Right: Speed & Errors
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", session.cps))
                    .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                let errorLabel = String(localized: "stats.history.error_label")
                let cpsLabel = String(localized: "stats.history.cps")
                Text(session.errors > 0 ? "\(session.errors) \(errorLabel)" : cpsLabel)
                    .font(DesignSystem.Fonts.monospaced(size: 8, weight: .bold))
                    .foregroundColor(session.errors > 0 ? .red : DesignSystem.Colors.textSecondary)
            }
            .frame(width: 50)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.02))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.date.formatted(.dateTime.day().month())): \(session.bestStreakInSession) streak, \(session.errors) errors, \(String(format: "%.1f", session.cps)) cps")
        .accessibilityIdentifier("stats.history.row.\(session.id.uuidString)")
    }
    
    private func formatMode(_ mode: PracticeEngine.Mode) -> String {
        mode.description
    }
    
    private func iconForMode(_ mode: SessionMode) -> String {
        switch mode {
        case .learn: return "book.fill"
        case .practice: return "hammer.fill"
        case .test: return "bolt.fill"
        case .game: return "flag.checkered.2.crossed"
        }
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        VStack {
            HistoryRow(session: SessionRecord(
                id: UUID(),
                date: Date(),
                constant: .pi,
                mode: .strict,
                sessionMode: .practice,
                attempts: 100,
                errors: 0,
                bestStreakInSession: 85,
                durationSeconds: 120,
                digitsPerMinute: 42,
                revealsUsed: 0
            ))
            
            HistoryRow(session: SessionRecord(
                id: UUID(),
                date: Date().addingTimeInterval(-86400),
                constant: .pi,
                mode: .learning,
                sessionMode: .learn,
                attempts: 50,
                errors: 3,
                bestStreakInSession: 12,
                durationSeconds: 60,
                digitsPerMinute: 25,
                revealsUsed: 3
            ))
        }
    }
}
