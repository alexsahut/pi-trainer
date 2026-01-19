//
//  SessionDetailView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import SwiftUI

struct SessionDetailView: View {
    let session: SessionRecord
    
    var body: some View {
        Form {
            Section(header: Text("stats.session_details")) {
                DetailRow(label: "stats.date", value: formatDate(session.date))
                DetailRow(label: "stats.mode", value: session.sessionMode.displayName)
                
                if let start = session.segmentStart, let end = session.segmentEnd {
                    DetailRow(label: "stats.segment", value: "\(start) - \(end)")
                }
                
                DetailRow(label: "stats.duration", value: formatTime(session.durationSeconds))
            }
            
            Section(header: Text("stats.performance")) {
                DetailRow(label: "stats.decimals", value: "\(session.attempts)")
                DetailRow(label: "stats.errors", value: "\(session.errors)", color: session.errors > 0 ? .red : .primary)
                DetailRow(label: "stats.best_streak", value: "\(session.bestStreakInSession)", color: DesignSystem.Colors.cyanElectric)
                
                if session.sessionMode == .learn {
                     DetailRow(label: "stats.loops", value: "\(session.loops)", color: DesignSystem.Colors.cyanElectric)
                }
                
                if session.revealsUsed > 0 {
                    DetailRow(label: "session.summary.reveals", value: "\(session.revealsUsed)", color: DesignSystem.Colors.cyanElectric)
                }
            }
            
            Section(header: Text("stats.speed.per_second")) {
                DetailRow(label: "AVG", value: String(format: "%.1f", session.cps))
                if let min = session.minCPS, min > 0 {
                    DetailRow(label: "MIN", value: String(format: "%.1f", min))
                }
                if let max = session.maxCPS, max > 0 {
                    DetailRow(label: "MAX", value: String(format: "%.1f", max))
                }
            }
            
            Section(header: Text("stats.speed.per_minute")) {
                DetailRow(label: "AVG", value: String(format: "%.1f", session.digitsPerMinute))
                if let min = session.minCPS, min > 0 {
                    DetailRow(label: "MIN", value: String(format: "%.1f", min * 60.0))
                }
                if let max = session.maxCPS, max > 0 {
                    DetailRow(label: "MAX", value: String(format: "%.1f", max * 60.0))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.blackOLED)
        .navigationTitle(Text(session.date, style: .date))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatMode(_ mode: PracticeEngine.Mode) -> String {
        mode.description
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: seconds) ?? "0m 0s"
    }
}

struct DetailRow: View {
    let label: LocalizedStringKey
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(color)
        }
    }
}
