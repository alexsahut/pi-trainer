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
                DetailRow(label: "stats.best_streak", value: "\(session.bestStreakInSession)", color: .green)
                
                let speedValue = session.digitsPerMinute.formatted(.number.precision(.fractionLength(...1)))
                let speedText = String(format: String(localized: "stats.speed.value"), speedValue)
                DetailRow(label: "stats.speed.title", value: speedText)
            }
        }
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
        switch mode {
        case .strict: return String(localized: "mode.strict")
        case .learning: return String(localized: "mode.learning")
        }
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
