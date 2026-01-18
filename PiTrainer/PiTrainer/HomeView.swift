//
//  HomeView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var statsStore = StatsStore()
    @StateObject private var sessionViewModel = SessionViewModel()
    
    // Story 8.1: Learning Store for segment management
    @StateObject private var segmentStore = SegmentStore()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    @State private var showingStats = false
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header Massif
                VStack(spacing: 0) {
                    Text(statsStore.selectedConstant.symbol)
                        .font(.system(size: 120, weight: .ultraLight))
                        .foregroundColor(DesignSystem.Colors.cyanElectric)
                        .shadow(color: DesignSystem.Colors.cyanElectric.opacity(0.3), radius: 20)
                    
                    Text(constantTitle)
                        .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .tracking(4)
                }
                .padding(.top, 40)
                
                // Stats Highlights (PR & Streak)
                HStack(spacing: 12) {
                    // PR Pill
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 10))
                        Text("PR: \(statsStore.stats(for: statsStore.selectedConstant).bestStreak)")
                            .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                    }
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(DesignSystem.Colors.cyanElectric.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DesignSystem.Colors.cyanElectric.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Daily Streak Pill (Story 5.1)
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                        Text("\(statsStore.streakStore.currentStreak) DAYS")
                            .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                    }
                    .foregroundColor(statsStore.streakStore.currentStreak > 0 ? .orange : DesignSystem.Colors.textSecondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background((statsStore.streakStore.currentStreak > 0 ? Color.orange : Color.gray).opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke((statsStore.streakStore.currentStreak > 0 ? Color.orange : Color.gray).opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Selectors Stack
                VStack(spacing: 32) {
                    ZenSegmentedControl(
                        title: "CONSTANTE",
                        options: Constant.allCases,
                        selection: $statsStore.selectedConstant
                    )
                    
                    // Story 7.1: Mode Selector
                    ModeSelector(selectedMode: Binding(
                        get: { statsStore.selectedMode },
                        set: { newValue in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                statsStore.selectedMode = newValue
                            }
                        }
                    ))
                    
                    // Story 8.1: Segment Selection (Only for LEARN mode)
                    if statsStore.selectedMode == .learn {
                        SegmentSlider(
                            start: $segmentStore.segmentStart,
                            end: $segmentStore.segmentEnd,
                            range: 0...1000 // Reasonable default for learn mode focus
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button (Action Pivot)
                ZenPrimaryButton(title: "START SESSION", accessibilityIdentifier: "home.start_button") {
                    // Configure ViewModel with latest settings
                    configureSession()
                    coordinator.push(.session(mode: sessionViewModel.selectedMode))
                }
                .padding(.horizontal, 20)
                
                // Footer Dashboard Access (Zen-Athlete 2.0 Patch)
                HStack(spacing: 40) {
                    Button(action: { showingStats = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                            Text("RECORDS")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Button(action: { showingSettings = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                            Text("RÉGLAGES")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: NavigationCoordinator.Destination.self) { destination in
            switch destination {
            case .session(_):
                SessionView(viewModel: sessionViewModel, statsStore: statsStore)
                    .navigationBarBackButtonHidden(true)
            case .learning:
                LearningHomeView()
            case .stats:
                StatsView(statsStore: statsStore)
            }
        }
        .sheet(isPresented: $showingStats) {
            StatsView(statsStore: statsStore)
        }
        .sheet(isPresented: $showingSettings) {
             SettingsView(statsStore: statsStore)
        }
        .onAppear {
            // Initial sync
            configureSession()
        }
    }
    
    private func configureSession() {
        sessionViewModel.syncSettings(from: statsStore, segmentStore: segmentStore)
        sessionViewModel.onSaveSession = { record in
            statsStore.addSessionRecord(record)
        }
    }
    
    private var constantTitle: String {
        switch statsStore.selectedConstant {
        case .pi: return "PI TRAINER"
        case .e: return "E TRAINER"
        case .sqrt2: return "SQRT2 TRAINER"
        case .phi: return "PHI TRAINER"
        }
    }
}

#Preview {
    HomeView()
        .environment(NavigationCoordinator())
}
