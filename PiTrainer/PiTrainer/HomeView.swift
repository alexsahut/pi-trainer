
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
    
    @Environment(NavigationCoordinator.self) private var coordinator
    @State private var showingStats = false
    @State private var showingSettings = false
    
    // No explicit init needed anymore!
    
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
                
                // PB Pill (Zen-Athlete 2.0)
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                    Text("PB: \(statsStore.stats(for: statsStore.selectedConstant).bestStreak)")
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
                
                // Selectors Stack
                VStack(spacing: 32) {
                    ZenSegmentedControl(
                        title: "CONSTANTE",
                        options: Constant.allCases,
                        selection: $statsStore.selectedConstant
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button (Action Pivot)
                ZenPrimaryButton(title: "START SESSION", accessibilityIdentifier: "home.start_button") {
                    // Configure ViewModel with latest settings
                    sessionViewModel.keypadLayout = statsStore.keypadLayout
                    sessionViewModel.selectedConstant = statsStore.selectedConstant
                    sessionViewModel.onSaveSession = { record in
                        statsStore.addSessionRecord(record)
                    }
                    
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
            case .session(let mode):
                SessionView(viewModel: sessionViewModel)
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
             SettingsView(sessionViewModel: sessionViewModel, statsStore: statsStore)
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

// Extensions for CustomStringConvertible to make ZenSegmentedControl happy
extension Constant: CustomStringConvertible {
    var description: String { symbol }
}

extension PracticeEngine.Mode: CustomStringConvertible {
    var description: String {
        switch self {
        case .strict: return "STRICT"
        case .learning: return "LEARN"
        }
    }
}

extension KeypadLayout: CustomStringConvertible {
    var description: String {
        switch self {
        case .phone: return "PHONE"
        case .pc: return "PC"
        }
    }
}

#Preview {
    HomeView()
        .environment(NavigationCoordinator())
}
