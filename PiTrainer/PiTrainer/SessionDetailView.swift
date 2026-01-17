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
                DetailRow(label: "stats.mode", value: formatMode(session.mode))
                DetailRow(label: "stats.duration", value: formatTime(session.durationSeconds))
            }
            
            Section(header: Text("stats.performance")) {
                DetailRow(label: "stats.attempts", value: "\(session.attempts)")
                DetailRow(label: "stats.errors", value: "\(session.errors)", color: session.errors > 0 ? .red : .primary)
                DetailRow(label: "stats.best_streak", value: "\(session.bestStreakInSession)", color: DesignSystem.Colors.cyanElectric)
                
                if session.revealsUsed > 0 {
                    DetailRow(label: "session.summary.reveals", value: "\(session.revealsUsed)", color: DesignSystem.Colors.cyanElectric)
                }
            }
            
            Section(header: Text("session.summary.speed")) {
                // CPS Group
                DetailRow(label: "CPS AVG", value: String(format: "%.1f", session.cps))
                if let min = session.minCPS {
                    DetailRow(label: "CPS MIN", value: String(format: "%.1f", min))
                }
                if let max = session.maxCPS {
                    DetailRow(label: "CPS MAX", value: String(format: "%.1f", max))
                }
                
                Divider()
                
                // CPM Group
                DetailRow(label: "CPM AVG", value: String(format: "%.1f", session.digitsPerMinute))
                if let min = session.minCPS {
                    DetailRow(label: "CPM MIN", value: String(format: "%.1f", min * 60.0))
                }
                if let max = session.maxCPS {
                    DetailRow(label: "CPM MAX", value: String(format: "%.1f", max * 60.0))
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
