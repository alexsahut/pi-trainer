
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
                
                // Selectors Stack
                VStack(spacing: 32) {
                    ZenSegmentedControl(
                        title: "CONSTANTE",
                        options: Constant.allCases,
                        selection: $statsStore.selectedConstant
                    )
                    
                    ZenSegmentedControl(
                        title: "MODE",
                        options: [PracticeEngine.Mode.strict, PracticeEngine.Mode.learning],
                        selection: $sessionViewModel.selectedMode
                    )
                    
                    ZenSegmentedControl(
                        title: "CLAVIER",
                        options: KeypadLayout.allCases,
                        selection: $statsStore.keypadLayout
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
                
                // Footer Stats
                Button(action: { showingStats = true }) {
                    VStack(spacing: 4) {
                        Text("RECORDS PERSONNELS >")
                            .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05))
                }
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
