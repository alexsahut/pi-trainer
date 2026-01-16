//
//  StatsView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var statsStore: StatsStore
    @StateObject private var learningStore = LearningStore() // Internal store for learning stats
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedConstantForStats: Constant
    
    init(statsStore: StatsStore) {
        self.statsStore = statsStore
        // Initialize with the currently global selected constant, or default to Pi
        _selectedConstantForStats = State(initialValue: statsStore.selectedConstant)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("stats.constant_picker", selection: $selectedConstantForStats) {
                        ForEach(Constant.allCases) { constant in
                            Text(constant.symbol).tag(constant)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .listRowSeparator(.hidden)
                
                let currentStats = statsStore.stats(for: selectedConstantForStats)
                let learningState = learningStore.state(for: selectedConstantForStats)
                
                // NEW: Learning Section
                Section(header: Text("home.learn_module")) {
                     HStack {
                         VStack(alignment: .leading) {
                             Text("learning.mastered_count")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                             Text("\(learningState.masteredCount)")
                                 .font(.title2)
                                 .fontWeight(.bold)
                         }
                         Spacer()
                         VStack(alignment: .center) {
                             Text("learning.in_learning_count")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                             Text("\(learningState.inLearningCount)")
                                 .font(.title2)
                                 .fontWeight(.bold)
                         }
                         Spacer()
                         VStack(alignment: .trailing) {
                             Text("Due")
                                 .font(.caption)
                                 .foregroundColor(.secondary)
                             Text("\(learningStore.dueChunks(for: selectedConstantForStats).count)")
                                 .font(.title2)
                                 .fontWeight(.bold)
                                 .foregroundColor(.orange)
                         }
                     }
                }
                
                Section(header: Text("stats.global_records")) {
                    HStack {
                        Text("stats.best_streak")
                        Spacer()
                        Text("\(currentStats.bestStreak)")
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                    }
                }
                
                if let last = currentStats.lastSession {
                    Section(header: Text("stats.last_session")) {
                        StatRow(label: String(localized: "stats.attempts"), value: String(localized: "stats.attempts_count \(last.attempts)"))
                        StatRow(label: String(localized: "stats.errors"), value: String(localized: "session.errors_count \(last.errors)"), color: .red)
                        StatRow(label: String(localized: "stats.best_streak"), value: "\(last.bestStreakInSession)", color: .green)
                        
                        let speedValue = last.digitsPerMinute.formatted(.number.precision(.fractionLength(...1)))
                        let speedFormat = String(localized: "stats.speed.value")
                        let speedText = String(format: speedFormat, speedValue)
                        StatRow(label: String(localized: "stats.speed.title"), value: speedText)
                        
                        StatRow(label: String(localized: "stats.time"), value: formatTime(last.durationSeconds))
                        StatRow(label: String(localized: "stats.date"), value: formatDate(last.date))
                    }
                } else {
                    Section {
                        Text("stats.no_sessions")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !currentStats.sessionHistory.isEmpty {
                    Section(header: Text("stats.history")) {
                        ForEach(currentStats.sessionHistory.prefix(20)) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(session.date, style: .date)
                                        Text(formatMode(session.mode))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(session.bestStreakInSession)")
                                            .foregroundColor(.green)
                                            .fontWeight(.bold)
                                        Text(String(format: String(localized: "stats.errors_short %@"), "\(session.errors)"))
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showClearHistoryConfirmation = true
                        } label: {
                            Text("stats.clear_history")
                        }
                    }
                } else {
                    Section(header: Text("stats.history")) {
                         Text("stats.no_history")
                             .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
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
            .alert("stats.reset_confirmation.title", isPresented: $showResetConfirmation) {
                Button("stats.cancel", role: .cancel) { }
                Button("stats.reset_all", role: .destructive) {
                    statsStore.reset()
                    learningStore.reset()
                }
            } message: {
                Text("stats.reset_confirmation.message")
            }
            .alert("stats.clear_history.title", isPresented: $showClearHistoryConfirmation) {
                Button("stats.cancel", role: .cancel) { }
                Button("stats.clear", role: .destructive) {
                    statsStore.clearHistory(for: selectedConstantForStats)
                }
            } message: {
                Text("stats.clear_history.message")
            }
        }
    }
    
    @State private var showResetConfirmation = false
    @State private var showClearHistoryConfirmation = false
    
    private func formatMode(_ mode: PracticeEngine.Mode) -> String {
        switch mode {
        case .strict: return String(localized: "mode.strict")
        case .learning: return String(localized: "mode.learning")
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
