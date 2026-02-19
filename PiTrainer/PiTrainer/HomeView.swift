//
//  HomeView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct HomeView: View {
    private var statsStore = StatsStore.shared

    @StateObject private var sessionViewModel = SessionViewModel(persistence: PracticePersistence())
    
    // Story 8.1: Learning Store for segment management
    @StateObject private var segmentStore = SegmentStore()
    
    @Environment(NavigationCoordinator.self) private var coordinator
    @State private var showingStats = false
    @State private var showingSettings = false
    
    var body: some View {
        @Bindable var statsStore = statsStore
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            
            VStack(spacing: 10) { // Reduced from 40 to 10 to fix top clipping
                // Header Massif avec GradeBadge et XPProgressBar
                VStack(spacing: 15) { // Reduced from 20
                    GradeBadge(grade: statsStore.currentGrade, xp: statsStore.totalCorrectDigits)
                        .scaleEffect(1.0) // Reduced scale from 1.2 to save space
                        .padding(.top, 5) // Reduced from 10
                    
                    XPProgressBar(xp: statsStore.totalCorrectDigits, grade: statsStore.currentGrade)
                        .frame(width: 200)
                        .padding(.top, 2) // Reduced from 5
                }
                .padding(.top, 5) // Reduced from 10
                
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
                // Responsive Spacing: Use a flexible Spacer instead of fixed spacing in parent VStack
                // We keep efficient internal spacing here
                VStack(spacing: 16) { // Reduced from 20 to 16 for better compact layout
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
                
                if statsStore.selectedMode != .learn {
                    Spacer().frame(height: 20) // Fixed spacing for compact layout
                } else {
                    Spacer().frame(height: 10) // Fixed minimal spacing in Learn mode to keep Start button visible
                }
                
                // Start Button (Action Pivot)
                ZenPrimaryButton(
                    title: "START SESSION",
                    style: .compact, // Story 12.1: Compact Pill
                    accessibilityIdentifier: "home.start_button"
                ) {
                    // Configure ViewModel with latest settings
                    configureSession()
                    coordinator.push(.session(mode: sessionViewModel.selectedMode.practiceEngineMode))
                }
                .padding(.horizontal, 40) // Increased horizontal padding for pill look
                
                // Footer Dashboard Access (Zen-Athlete 2.0 Patch)
                HStack(spacing: 20) { // Reduced spacing to fit 3 items
                    Button(action: { coordinator.push(.challengeHub) }) {
                        VStack(spacing: 8) {
                            Image(systemName: "trophy")
                                .font(.system(size: 20))
                            Text("DÉFIS")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: { showingStats = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                            Text("STATS")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: { showingSettings = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                            Text("RÉGLAGES")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 12)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: NavigationCoordinator.Destination.self) { destination in
            switch destination {
            case .session(let mode):
                // Note: mode is preserved in NavigationPath, but viewModel is already configured.
                SessionView(viewModel: sessionViewModel)
                    .navigationBarBackButtonHidden(true)
            case .stats:
                StatsView()
            case .challengeHub:
                ChallengeHubView()
                    .environment(coordinator) // Explicitly inject coordinator to ensure availability
                    .environmentObject(sessionViewModel) // Pass ViewModel for session start
            case .challengeSession(let challenge, let isDaily):
                ChallengeSessionView(challenge: challenge) { date in
                    // Instantiate service explicitly to mark completion
                    let persistence = PracticePersistence()
                    let service = ChallengeService(persistence: persistence, digitsProviderFactory: { FileDigitsProvider(constant: $0) })
                    
                    if isDaily {
                        service.markChallengeAsCompleted(for: date)
                    }
                }
                .environment(coordinator)
            }
        }
        .sheet(isPresented: $showingStats) {
            StatsView()
        }
        .sheet(isPresented: $showingSettings) {
             SettingsView(sessionViewModel: sessionViewModel)
        }
        .onAppear {
            // Initial sync
            configureSession()
        }
    }
    
    private func configureSession() {
        sessionViewModel.syncSettings(segmentStore: segmentStore)
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
