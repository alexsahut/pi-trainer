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
            ZStack {
                DesignSystem.Colors.blackOLED.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 1. Epic 4 Record Dashboard (Global Overview)
                        RecordDashboardView(statsStore: statsStore)
                            .padding(.top, 20)
                        
                        // 2. Constant Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("stats.constant_picker")
                                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .black))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 20)
                            
                            ZenSegmentedControl(
                                title: "",
                                options: Constant.allCases,
                                selection: $selectedConstantForStats
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        let currentStats = statsStore.stats(for: selectedConstantForStats)
                        
                        // 3. Current Constant Detail (Zen Card)
                        VStack(spacing: 24) {
                            // Primary Stat: Best Streak
                            VStack(spacing: 4) {
                                Text("stats.best_streak")
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                Text("\(currentStats.bestStreak)")
                                    .font(DesignSystem.Fonts.monospaced(size: 64, weight: .black))
                                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                            }
                            
                            if let last = currentStats.lastSession {
                                // Last Session Quick Stats Row
                                HStack(spacing: 30) {
                                    QuickStat(label: "CPS", value: String(format: "%.1f", last.digitsPerMinute))
                                    QuickStat(label: "ERR", value: "\(last.errors)", color: last.errors > 0 ? .red : .white)
                                    QuickStat(label: "TIME", value: formatTime(last.durationSeconds))
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(30)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        
                        // 4. Session History (Professional List)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("stats.history")
                                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .black))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 20)
                            
                            let sessionHistory = statsStore.history(for: selectedConstantForStats)
                            
                            if statsStore.isHistoryLoading && sessionHistory.isEmpty {
                                ProgressView()
                                    .tint(DesignSystem.Colors.cyanElectric)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if !sessionHistory.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(sessionHistory.prefix(200)) { session in
                                        NavigationLink(destination: SessionDetailView(session: session)) {
                                            HistoryRow(session: session)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(Color.white.opacity(0.02))
                                        }
                                        Divider().background(Color.white.opacity(0.1))
                                    }
                                }
                                .cornerRadius(20)
                                .padding(.horizontal, 20)
                                
                                // History Actions
                                Button(role: .destructive) {
                                    showClearHistoryConfirmation = true
                                } label: {
                                    Text("stats.clear_history")
                                        .font(DesignSystem.Fonts.monospaced(size: 13, weight: .bold))
                                        .foregroundColor(.red.opacity(0.7))
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Text("stats.no_history")
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .regular))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // 5. Danger Zone
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            Text("stats.reset_all")
                                .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.vertical, 40)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("stats.title")
                        .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
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
            .onChange(of: selectedConstantForStats) { oldVal, newVal in
                Task {
                    await statsStore.loadHistory(for: newVal)
                }
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

struct QuickStat: View {
    let label: String
    let value: String
    var color: Color = .white
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            Text(value)
                .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    StatsView(statsStore: StatsStore())
}
