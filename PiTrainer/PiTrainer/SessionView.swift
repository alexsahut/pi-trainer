//
//  SessionView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject var viewModel: SessionViewModel
    @ObservedObject var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var showOptions = false
    @State private var hapticsEnabled = HapticService.shared.isEnabled
    
    var body: some View {
        ZStack {
            if viewModel.selectedMode == .game {
                // Story 9.3: Atmospheric Feedback Background
                TimelineView(.animation) { timeline in
                    DesignSystem.Colors.blackOLED
                        .overlay(
                            viewModel.atmosphericColor(at: timeline.date)
                                .opacity(viewModel.atmosphericOpacity(at: timeline.date))
                        )
                        .ignoresSafeArea()
                }
            } else {
                DesignSystem.Colors.blackOLED
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Header showing stats (Zen-Athlete 3.0 - Symmetrical Edition)
            HStack(alignment: .center) {
                // LEFT COLUMN
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(viewModel.engine.currentStreak)")
                            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                        Text(String(localized: "session.header.streak"))
                            .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(viewModel.bestStreak)")
                            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                            .foregroundColor(.white.opacity(0.3))
                        Text("PR")
                            .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // CENTER COLUMN
                VStack(alignment: .center, spacing: 4) {
                    Text(viewModel.constantSymbol)
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(DesignSystem.Colors.cyanElectric)
                        .shadow(color: DesignSystem.Colors.cyanElectric.opacity(0.3), radius: 10)
                    
                    Text(viewModel.selectedMode.description)
                        .font(DesignSystem.Fonts.monospaced(size: 9, weight: .black))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // RIGHT COLUMN
                VStack(alignment: .trailing, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(String(localized: "session.header.decimal"))
                            .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text("\(viewModel.engine.currentIndex)")
                            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                            .contentTransition(.numericText())
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(String(localized: "session.header.errors"))
                            .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text("\(viewModel.errors)")
                            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                            .foregroundColor(viewModel.errors > 0 ? .red : .white.opacity(0.1))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(DesignSystem.Colors.blackOLED)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.white.opacity(0.05)),
                alignment: .bottom
            )
            
            // Terminal-Grid Display Area (blocks of 10 digits)
            VStack(spacing: 8) {
                if viewModel.showsHorizonLine {
                    HorizonLineView(
                        playerProgress: viewModel.playerProgressRatio,
                        ghostEngine: viewModel.ghostEngine,
                        totalDigits: viewModel.totalDigitsForMapping
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                ZStack {
                    TerminalGridView(
                        typedDigits: viewModel.typedDigits,
                        integerPart: viewModel.integerPart,
                        fullDigits: viewModel.fullDigitsString,
                        isLearnMode: viewModel.selectedMode == .learn,
                        allowsReveal: viewModel.selectedMode.allowsReveal,
                        startOffset: viewModel.currentSegmentOffset,
                        segmentLength: viewModel.currentSegmentLength,
                        onReveal: { count in
                            viewModel.reveal(count: count)
                        },
                        showError: viewModel.showErrorFlash,
                        wrongInputDigit: viewModel.lastWrongInput
                    )
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 200)
                    .modifier(ShakeEffect(animatableData: viewModel.showErrorFlash ? 1 : 0))
                    .focusable(false)
                    
                    // Retry / Quit Overlay when session ends
                    if !viewModel.isActive && viewModel.engine.attempts > 0 {
                        ZStack {
                            Color.black.opacity(0.8)
                            
                            VStack(spacing: 24) {
                                let status = viewModel.sessionEndStatus
                                Text(status.title)
                                    .font(DesignSystem.Fonts.monospaced(size: 32, weight: .black))
                                    .foregroundColor(status.color)
                                    .textCase(.uppercase)
                                
                                HStack(spacing: 40) {
                                    VStack(spacing: 4) {
                                        Text(String(localized: "stats.best_streak"))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.engine.bestStreak)")
                                            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    if viewModel.revealsUsed > 0 {
                                        VStack(spacing: 4) {
                                            Text(String(localized: "session.summary.reveals"))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(viewModel.revealsUsed)")
                                                .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                                                .foregroundColor(DesignSystem.Colors.cyanElectric)
                                        }
                                    }
                                }
                                
                                // Advanced Speed Stats (CPS & CPM)
                                VStack(spacing: 12) {
                                    Text(String(localized: "session.summary.speed").uppercased())
                                        .font(DesignSystem.Fonts.monospaced(size: 14, weight: .black))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    HStack(spacing: 32) {
                                        // CPS Column
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("CPS")
                                                .font(.caption2.bold())
                                                .foregroundColor(DesignSystem.Colors.cyanElectric)
                                            
                                            SpeedMetricRow(label: "MIN", value: viewModel.engine.minCPS == .infinity ? 0 : viewModel.engine.minCPS)
                                            SpeedMetricRow(label: "MAX", value: viewModel.engine.maxCPS)
                                            SpeedMetricRow(label: "AVG", value: viewModel.engine.digitsPerMinute / 60.0)
                                        }
                                        
                                        // CPM Column
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("CPM")
                                                .font(.caption2.bold())
                                                .foregroundColor(DesignSystem.Colors.cyanElectric)
                                            
                                            SpeedMetricRow(label: "MIN", value: (viewModel.engine.minCPS == .infinity ? 0 : viewModel.engine.minCPS) * 60.0)
                                            SpeedMetricRow(label: "MAX", value: viewModel.engine.maxCPS * 60.0)
                                            SpeedMetricRow(label: "AVG", value: viewModel.engine.digitsPerMinute)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                                
                                VStack(spacing: 12) {
                                    Button {
                                        viewModel.startSession()
                                    } label: {
                                        Text(String(localized: "session.retry"))
                                            .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(DesignSystem.Colors.cyanElectric)
                                            .cornerRadius(20)
                                    }
                                    
                                    Button {
                                        viewModel.endSession()
                                        dismiss()
                                    } label: {
                                        Text(String(localized: "session.quit"))
                                            .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            }
            
            Spacer()

            // ProPad (Numeric Keypad)
            ProPadView(
                layout: statsStore.keypadLayout,
                currentStreak: viewModel.engine.currentStreak,
                isActive: viewModel.isInputAllowed,
                isGhostModeEnabled: statsStore.selectedMode.hasGhost,
                onDigit: { digit in
                    if viewModel.isInputAllowed {
                        viewModel.processInput(digit)
                    }
                },
                onBackspace: {
                    if viewModel.isInputAllowed {
                        viewModel.backspace()
                    }
                },
                onOptions: {
                    showOptions = true
                }
            )
            .focusable(false)
        }
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(viewModel.isActive)
        .onAppear {
            viewModel.startSession()
        }
        .animation(.default, value: viewModel.isActive)
        .sheet(isPresented: $showOptions) {
            SessionSettingsView(viewModel: viewModel, statsStore: statsStore)
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
}

struct SpeedMetricRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(DesignSystem.Fonts.monospaced(size: 8, weight: .black))
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 25, alignment: .leading)
            
            Text(String(format: "%.1f", value))
                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
