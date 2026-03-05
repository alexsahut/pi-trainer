import SwiftUI

struct ChallengeSessionView: View {
    @Environment(NavigationCoordinator.self) private var coordinator
    @State private var viewModel: ChallengeViewModel
    @State private var showCelebration: Bool = false
    @State private var showResult: Bool = false
    @State private var showOptions: Bool = false
    @State private var navigationTask: Task<Void, Never>?
    var statsStore = StatsStore.shared

    var onComplete: ((Date) -> Void)?

    init(challenge: Challenge, onComplete: ((Date) -> Void)? = nil) {
        self._viewModel = State(initialValue: ChallengeViewModel(challenge: challenge))
        self.onComplete = onComplete
    }

    // Story 17.2: fullDigits indexed from 0 (relative to block start).
    // Layout: "0"×musOffsetInBlock + MUS + revealPool
    // Ghost indexing uses fullDigitsOffset=0, so fullDigits[8] = revealPool[0] when musOffset=3, musLen=5.
    private var gridFullDigits: String {
        let padding = String(repeating: "0", count: viewModel.challenge.musOffsetInBlock)
        return padding + viewModel.challenge.referenceSequence + viewModel.challenge.revealPool
    }

    // Story 17.3: typedDigits grows in guessing mode to include revealed + guessed digits.
    // In reveal phase: MUS only (fixed). In guessing phase: MUS + revealed (solid) + guessing input.
    // Transitioning to guessing mode with .id() reset clears revealedDigitsPerRow in TerminalGridView,
    // so the formerly-ghost revealed digits naturally become solid via typedDigits.
    private var gridTypedDigits: String {
        if viewModel.isInGuessingMode {
            let revealed = String(viewModel.challenge.revealPool.prefix(viewModel.revealedCount))
            return viewModel.challenge.referenceSequence + revealed + viewModel.guessingInput
        }
        return viewModel.challenge.referenceSequence
    }

    // Story 17.3: Row count grows with guessing input in addition to reveals.
    private var gridRowCount: Int {
        let guessCount = viewModel.isInGuessingMode ? viewModel.guessingInput.count : 0
        let totalPositions = viewModel.challenge.musOffsetInBlock
            + viewModel.challenge.referenceSequence.count
            + viewModel.revealedCount
            + guessCount
        return (totalPositions / 10) + 1
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                // Hint counter (hidden in guessing mode — hints are locked in)
                if !viewModel.isInGuessingMode {
                    hintCounter
                        .padding(.top, 8)
                }

                // Story 17.3: .id() forces TerminalGridView recreation on mode transition,
                // resetting revealedDigitsPerRow so formerly-ghost digits become solid in typedDigits.
                TerminalGridView(
                    typedDigits: gridTypedDigits,
                    integerPart: viewModel.challenge.constant.integerPart,
                    fullDigits: gridFullDigits,
                    isLearnMode: false,
                    allowsReveal: viewModel.canReveal && !viewModel.isInGuessingMode,
                    startOffset: viewModel.challenge.blockStartIndex,
                    onReveal: { count in
                        viewModel.revealDigits(count: count)
                    },
                    typedDigitsColumnOffset: viewModel.challenge.musOffsetInBlock,
                    fullDigitsOffset: 0,
                    forcedRowCount: gridRowCount
                )
                .id(viewModel.isInGuessingMode ? "guessing" : "revealing")

                Spacer()

                // Story 17.3: Bottom area — "Je sais !" button OR ProPad depending on phase
                if viewModel.isInGuessingMode {
                    ProPadView(
                        layout: statsStore.keypadLayout,
                        onDigit: { digit in viewModel.handleInput(digit) },
                        onBackspace: { viewModel.handleBackspace() },
                        onOptions: { showOptions = true }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                } else {
                    iKnowButton
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay {
            if showCelebration {
                DoubleBangView()
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                if viewModel.isSuccessfulCompletion {
                    // Success: celebrate then show result after DoubleBang animation
                    triggerCelebration()
                    navigationTask = Task {
                        try? await Task.sleep(for: .seconds(2.5))
                        guard !Task.isCancelled else { return }
                        showResult = true
                    }
                } else {
                    // Error: wait for shake animation, then show result
                    navigationTask = Task {
                        try? await Task.sleep(for: .seconds(0.5))
                        guard !Task.isCancelled else { return }
                        showResult = true
                    }
                }
            }
        }
        // Story 17.4: Result screen via fullScreenCover
        .fullScreenCover(isPresented: $showResult) {
            ChallengeResultView(
                score: viewModel.computedScore,
                correctGuessCount: viewModel.correctGuessCount,
                revealedCount: viewModel.revealedCount,
                isSuccess: viewModel.isSuccessfulCompletion,
                constant: viewModel.challenge.constant,
                previousBest: ChallengeScoreStore.shared.bestScore(for: viewModel.challenge.constant),
                onDismiss: {
                    ChallengeScoreStore.shared.saveBestScore(
                        viewModel.computedScore,
                        for: viewModel.challenge.constant
                    )
                    showResult = false
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(100))
                        onComplete?(Date())
                        coordinator.pop()
                    }
                },
                onTrain: {
                    showResult = false
                    viewModel.triggerRecovery()
                }
            )
        }
        .onChange(of: viewModel.shouldNavigateToPractice) { _, shouldNavigate in
            if shouldNavigate {
                coordinator.popToRoot()

                navigationTask = Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    guard !Task.isCancelled else { return }
                    coordinator.push(.session(mode: .learning))
                }
            }
        }
        .onDisappear {
            navigationTask?.cancel()
            navigationTask = nil
        }
        .sheet(isPresented: $showOptions) {
            ChallengeOptionsSheet(statsStore: statsStore)
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

            Text(String(localized: "challenge.title", defaultValue: "FOLLOW THE SEQUENCE"))
                .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                .foregroundColor(DesignSystem.Colors.cyanElectric)

            Spacer()

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

    private var hintCounter: some View {
        HStack {
            Spacer()
            Text("challenge.hints \(viewModel.hintCount)")
                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                .foregroundColor(viewModel.hintCount > 0 ? DesignSystem.Colors.orangeElectric : DesignSystem.Colors.textSecondary)
            Spacer()
        }
    }

    // Story 17.3: "Je sais !" button activates guessing mode.
    // Disabled when pool is fully revealed — matches activateGuessingMode() guard.
    private var iKnowButton: some View {
        Button(action: {
            viewModel.activateGuessingMode()
        }) {
            Text(String(localized: "challenge.i_know", defaultValue: "JE SAIS !"))
                .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                .foregroundColor(DesignSystem.Colors.blackOLED)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(DesignSystem.Colors.cyanElectric)
                .cornerRadius(16)
        }
        .disabled(!viewModel.canReveal)
        .opacity(viewModel.canReveal ? 1.0 : 0.5)
    }

    private func triggerCelebration() {
        showCelebration = true
    }
}

struct ChallengeOptionsSheet: View {
    var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    @State private var hapticsEnabled = HapticService.shared.isEnabled

    var body: some View {
        @Bindable var statsStore = statsStore
        NavigationStack {
            ZStack {
                DesignSystem.Colors.blackOLED.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        ZenSegmentedControl(
                            title: String(localized: "DISPOSITION CLAVIER"),
                            options: KeypadLayout.allCases,
                            selection: $statsStore.keypadLayout
                        )

                        Toggle(isOn: $hapticsEnabled) {
                            Text(String(localized: "RETOUR HAPTIQUE"))
                                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .tint(DesignSystem.Colors.cyanElectric)
                        .padding()
                        .background(DesignSystem.Colors.blackOLED.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .onChange(of: hapticsEnabled) { _, newValue in
                            HapticService.shared.isEnabled = newValue
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(String(localized: "OPTIONS DE SESSION"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "FERMER")) {
                        dismiss()
                    }
                    .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
