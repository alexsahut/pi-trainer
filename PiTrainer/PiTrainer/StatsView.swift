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
                        
                        // 1. Constant Selector (Moved to top)
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
                        .padding(.top, 20)
                        
                        // 3. Current Constant Detail (Zen Card)
                        VStack(spacing: 24) {
                            HStack(spacing: 40) {
                                // Crown Record
                                VStack(spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                        Text("stats.best_streak")
                                    }
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    
                                    Text("\(bestCrownStreak)")
                                        .font(DesignSystem.Fonts.monospaced(size: 48, weight: .black))
                                        .foregroundColor(bestCrownStreak > 0 ? DesignSystem.Colors.cyanElectric : .white.opacity(0.1))
                                }
                                
                                // Lightning Record
                                VStack(spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.orange)
                                        Text("CPS")
                                    }
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    
                                    Text(bestLightningCPS > 0 ? String(format: "%.2f", bestLightningCPS) : "0.00")
                                        .font(DesignSystem.Fonts.monospaced(size: 48, weight: .black))
                                        .foregroundColor(bestLightningCPS > 0 ? DesignSystem.Colors.cyanElectric : .white.opacity(0.1))
                                    
                                }
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingRulesSheet = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.cyanElectric)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingRulesSheet) {
                GameModeRulesView()
            }
            .alert("stats.reset_confirmation.title", isPresented: $showResetConfirmation) {
                Button("stats.cancel", role: .cancel) { }
                Button("stats.reset_all", role: .destructive) {
                    statsStore.reset()

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
            .task {
                // Ensure history is loaded for the initially selected constant
                await statsStore.loadHistory(for: selectedConstantForStats)
            }
        }
    }
    
    @State private var showResetConfirmation = false
    @State private var showClearHistoryConfirmation = false
    @State private var showingRulesSheet = false
    
    private var bestCrownStreak: Int {
        statsStore.history(for: selectedConstantForStats)
            .filter { $0.isCertified || ($0.sessionMode == .test && $0.revealsUsed == 0 && $0.errors <= 1) }
            .max(by: { $0.bestStreakInSession < $1.bestStreakInSession })?
            .bestStreakInSession ?? 0
    }
    
    private var bestLightningCPS: Double {
        let dpm = PersonalBestStore.shared.getRecord(for: selectedConstantForStats, type: .lightning)?.digitsPerMinute ?? 0
        return dpm / 60.0
    }
    
    private func formatMode(_ mode: PracticeEngine.Mode) -> String {
        switch mode {
        case .strict: return String(localized: "mode.strict")
        case .learning: return String(localized: "mode.learning")
        case .game: return String(localized: "mode.game")
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
