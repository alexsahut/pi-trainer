//
//  ChallengeHubView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 25/01/2026.
//

import SwiftUI

struct ChallengeHubView: View {
    @Environment(NavigationCoordinator.self) private var coordinator
    
    @State private var viewModel = ChallengeHubViewModel(
        service: ChallengeService(
            persistence: PracticePersistence(),
            digitsProviderFactory: { FileDigitsProvider(constant: $0) }
        )
    )
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { coordinator.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    Spacer()
                    Text("challenge.hub.title")
                        .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date Display
                        Text(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none).uppercased())
                            .font(DesignSystem.Fonts.monospaced(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        if !viewModel.isChallengeEligible {
                            // LOCKED STATE — User needs more practice
                            VStack(spacing: 16) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text("challenge_locked_title")
                                    .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("challenge_locked_body \(viewModel.digitsRemainingToUnlock)")
                                    .font(DesignSystem.Fonts.primary(size: 14))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 40)
                        } else {
                            // UNLOCKED STATE — Normal challenge flow
                            if let error = viewModel.errorText {
                                Text(error)
                                    .font(DesignSystem.Fonts.primary(size: 14))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            
                            // Daily Challenge
                            if let challenge = viewModel.dailyChallenge {
                                DailyChallengeCard(
                                    challenge: challenge,
                                    isCompleted: viewModel.isDailyCompleted,
                                    action: {
                                        viewModel.startDailyChallenge()
                                    }
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            } else if viewModel.errorText == nil {
                                ProgressView()
                                    .tint(DesignSystem.Colors.cyanElectric)
                            }
                            
                            // "Train Now" Button (Story 13.3)
                            VStack(spacing: 8) {
                                Button(action: {
                                    Task {
                                        await viewModel.trainNow()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "bolt.fill")
                                        Text("challenge.hub.train_now")
                                    }
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DesignSystem.Colors.cyanElectric, lineWidth: 1)
                                    )
                                }
                                
                                Text("challenge.hub.unlimited_practice")
                                    .font(DesignSystem.Fonts.primary(size: 10))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.dailyChallenge != nil)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadDailyChallenge()
            }
            // Story 17.5: Request notification permission and schedule challenge reminder
            NotificationService.shared.requestAuthorization { granted in
                if granted {
                    NotificationService.shared.scheduleDailyChallengeReminder()
                }
            }
        }
        .onChange(of: viewModel.presentedChallenge) { _, challenge in
            if let challenge = challenge {
                coordinator.push(.challengeSession(challenge, isDaily: viewModel.isPresentedChallengeDaily))
                // Reset to allow re-triggering navigation later
                Task { @MainActor in
                    viewModel.presentedChallenge = nil
                }
            }
        }
    }
}
