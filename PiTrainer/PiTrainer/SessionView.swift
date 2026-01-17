//
//  SessionView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header showing stats
            HStack {
                VStack(alignment: .leading) {
                    let modeName = viewModel.selectedMode == .strict ? 
                        String(localized: "home.strict") : 
                        String(localized: "home.learning")
                    
                    (Text(modeName) + Text("   ") + Text(viewModel.constantSymbol).font(.body).fontWeight(.black))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(localized: "session.streak \(viewModel.engine.currentStreak)"))
                        .font(.headline)
                    
                    // Position Tracker - displays current digit index (1-based for UX)
                    Text(String(localized: "session.decimal_position \(viewModel.engine.currentIndex + 1)"))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                        .accessibilityLabel(String(localized: "session.decimal_position.accessibility \(viewModel.engine.currentIndex + 1)"))
                        .accessibilityAddTraits(.updatesFrequently)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(localized: "session.errors_count \(viewModel.errors)"))
                        .font(.headline)
                        .foregroundColor(viewModel.errors > 0 ? .red : .primary)
                    
                    Text(String(localized: "session.best_streak \(viewModel.bestStreak)"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            
            // Terminal-Grid Display Area (blocks of 10 digits)
            ZStack {
                TerminalGridView(
                    typedDigits: viewModel.typedDigits,
                    integerPart: viewModel.integerPart,
                    showError: viewModel.showErrorFlash
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 200)
                .modifier(StreakFlowEffect(streak: viewModel.engine.currentStreak))
                .modifier(ShakeEffect(animatableData: viewModel.showErrorFlash ? 1 : 0))
                
                // Retry / Quit Overlay when session ends
                if !viewModel.isActive && viewModel.engine.attempts > 0 {
                    ZStack {
                        Color.black.opacity(0.8)
                        
                        VStack(spacing: 24) {
                            Text(viewModel.engine.errors > 0 ? String(localized: "session.game_over") : String(localized: "session.complete"))
                                .font(DesignSystem.Fonts.monospaced(size: 32, weight: .black))
                                .foregroundColor(viewModel.engine.errors > 0 ? .red : DesignSystem.Colors.cyanElectric)
                                .foregroundColor(viewModel.engine.errors > 0 ? .red : DesignSystem.Colors.cyanElectric)
                                .textCase(.uppercase)
                            
                            HStack(spacing: 40) {
                                VStack(spacing: 4) {
                                    Text(String(localized: "stats.best_streak"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(viewModel.engine.currentStreak)")
                                        .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(String(localized: "stats.speed.title"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.1f", viewModel.engine.digitsPerMinute))
                                        .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 10)
                            
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
            
            Spacer()

            
            // ProPad (Numeric Keypad)
            ProPadView(
                layout: viewModel.keypadLayout,
                currentStreak: viewModel.engine.currentStreak,
                isActive: viewModel.isInputAllowed, // Allow input when Ready or Running
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
        }

        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(viewModel.isActive) // Story 3.2: Zen Mode (only when running)
        .onAppear {
            viewModel.startSession()
        }
        .animation(.default, value: viewModel.isActive)
        .sheet(isPresented: $showOptions) {
            NavigationStack {
                List {
                    Section {
                        Toggle(String(localized: "settings.haptics"), isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { newValue in
                                HapticService.shared.isEnabled = newValue
                            }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            showOptions = false
                            viewModel.reset()
                        } label: {
                            Label(String(localized: "keypad.reset"), systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(role: .destructive) {
                            showOptions = false
                            viewModel.endSession()
                            dismiss()
                        } label: {
                            Label(String(localized: "keypad.quit"), systemImage: "xmark.circle")
                        }
                    }
                }
                .navigationTitle(String(localized: "session.options"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "common.close")) {
                            showOptions = false
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    @State private var showOptions = false
    @State private var hapticsEnabled = HapticService.shared.isEnabled
}

#Preview {
    NavigationStack {
        SessionView(viewModel: SessionViewModel())
    }
}
