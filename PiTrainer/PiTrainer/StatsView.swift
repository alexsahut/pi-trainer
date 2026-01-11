//
//  StatsView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("stats.global_records")) {
                    HStack {
                        Text("stats.best_streak")
                        Spacer()
                        Text("\(statsStore.globalBestStreak)")
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                    }
                }
                
                if let last = statsStore.lastSession {
                    Section(header: Text("stats.last_session")) {
                        StatRow(label: String(localized: "stats.attempts"), value: String(localized: "stats.attempts_count \(last.attempts)"))
                        StatRow(label: String(localized: "stats.errors"), value: String(localized: "session.errors_count \(last.errors)"), color: .red)
                        StatRow(label: String(localized: "stats.best_streak"), value: "\(last.bestStreak)", color: .green)
                        
                        let speedValue = last.digitsPerMinute.formatted(.number.precision(.fractionLength(...1)))
                        let speedFormat = String(localized: "stats.speed.value")
                        let speedText = String(format: speedFormat, speedValue)
                        StatRow(label: String(localized: "stats.speed.title"), value: speedText)
                        
                        StatRow(label: String(localized: "stats.time"), value: formatTime(last.elapsedTime))
                        StatRow(label: String(localized: "stats.date"), value: formatDate(last.date))
                    }
                } else {
                    Section {
                        Text("stats.no_sessions")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        statsStore.reset()
                    } label: {
                        Text("stats.reset_all")
                    }
                }
            }
            .navigationTitle("stats.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("stats.done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "0:00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(verbatim: label)
            Spacer()
            Text(verbatim: value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

#Preview {
    StatsView(statsStore: StatsStore())
}
