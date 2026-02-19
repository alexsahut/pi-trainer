import SwiftUI

struct ChallengeSessionView: View {
    @Environment(NavigationCoordinator.self) private var coordinator
    @State private var viewModel: ChallengeViewModel
    @State private var showCelebration: Bool = false
    
    // Callback for completion, similar to SessionViewModel
    var onComplete: ((Date) -> Void)?
    
    init(challenge: Challenge, onComplete: ((Date) -> Void)? = nil) {
        self._viewModel = State(initialValue: ChallengeViewModel(challenge: challenge))
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            
            VStack {
                // Header
                header
                
                Spacer()
                
                // Prompt Area
                promptSection
                
                // Target Area
                targetSection
                
                Spacer()
                
                // Keypad
                KeypadView(
                    layout: StatsStore.shared.keypadLayout, // Use global setting
                    onDigit: { digit in
                        viewModel.handleInput(digit)
                    },
                    onBackspace: {
                        viewModel.handleBackspace()
                    },
                    onReset: {
                        viewModel.reset()
                    },
                    onQuit: {
                        coordinator.pop()
                    }
                )
                .padding(.bottom, 20)
            }
        }

        .navigationBarHidden(true)
        .overlay {
            if showCelebration {
                DoubleBangView()
                    .allowsHitTesting(false) // Let taps pass through if needed, though usually celebration blocks
            }
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                // Trigger success flow
                triggerCelebration()
                
                // For now, just call back and pop
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // Delay for animation
                    onComplete?(Date())
                    coordinator.pop()
                }
            }
        }
        .onChange(of: viewModel.shouldNavigateToPractice) { _, shouldNavigate in
            if shouldNavigate {
                // Navigate to standard session (configured by VM via shared stores)
                coordinator.pop() // Exit Challenge
                // We rely on Home View appearing and user manually tapping start?
                // OR we want DYNAMIC navigation?
                // The coordinator has `push(.session(mode: .learn))`?
                // Coordinator stack is: Home -> ChallengeHub -> ChallengeSession.
                // We want to go to Practice. 
                // Best flow: Switch "tab" or push Practice session.
                
                // Since this is a modal/overlay flow, we might need to be careful.
                // Assuming Coordinator can handle pushing a session from here or replacing.
                // Ideally: Pop to Root, then Push Session.
                coordinator.popToRoot()
                
                // Small delay to allow pop animation? 
                // Or Coordinator handles it.
                // Using a slight delay to ensure state settles.
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                     coordinator.push(.session(mode: .learning)) // Use mapped enum
                 }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { coordinator.pop() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Distinct Header for Challenge
            Text(String(localized: "challenge.title", defaultValue: "FOLLOW THE SEQUENCE"))
                .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                .foregroundColor(DesignSystem.Colors.cyanElectric)
                
            Spacer()
            
            // Recovery Button (Top Right) or just keep clear
            if viewModel.isShowingRecovery {
                Button(action: { viewModel.triggerRecovery() }) {
                    Text(String(localized: "challenge.practice_action", defaultValue: "PRACTICE THIS SEQUENCE"))
                        .font(DesignSystem.Fonts.primary(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignSystem.Colors.orangeElectric, lineWidth: 1)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Color.clear.frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    private var promptSection: some View {
        VStack(spacing: 8) {
            Text(String(localized: "challenge.prompt", defaultValue: "STARTING PATTERN"))
                .font(DesignSystem.Fonts.primary(size: 12))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text(viewModel.prompt)
                .font(DesignSystem.Fonts.monospaced(size: 32, weight: .regular))
                .foregroundColor(DesignSystem.Colors.textSecondary) // Read-only look
                .multilineTextAlignment(.center)
                .accessibilityLabel(String(localized: "challenge.accessibility_prompt", defaultValue: "Starting Pattern"))
                .accessibilityValue(viewModel.prompt)
        }
    }
    
    private var targetSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.displayTarget)
                .font(DesignSystem.Fonts.monospaced(size: 40, weight: .bold))
                .foregroundColor(viewModel.isErrorShakeActive ? .red : DesignSystem.Colors.textPrimary)
                .modifier(ShakeEffect(animatableData: viewModel.isErrorShakeActive ? 1 : 0))
                .accessibilityLabel("Target Sequence")
                .accessibilityValue(viewModel.displayTarget.replacingOccurrences(of: "_", with: "Blank"))
        }
        .padding(.top, 20)
    }
    
    private func triggerCelebration() {
        showCelebration = true
    }
}


