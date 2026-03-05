import SwiftUI

/// Story 17.4: Full-screen result screen displayed after a challenge session ends.
/// Shows score breakdown (bonus/malus), personal best, new record badge, and navigation actions.
struct ChallengeResultView: View {
    let score: Int
    let correctGuessCount: Int
    let revealedCount: Int
    let isSuccess: Bool
    let constant: Constant
    let previousBest: Int?
    let onDismiss: () -> Void
    let onTrain: () -> Void

    @State private var showBadge: Bool = false

    private var isNewRecord: Bool {
        ChallengeScoreStore.isNewRecord(score: score, previousBest: previousBest)
    }

    private var bonus: Int { correctGuessCount * 10 }
    private var malus: Int { revealedCount * 5 }

    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // 1. Title
                titleSection

                // 2. Score breakdown
                scoreSection

                // 3. Record personnel + new record badge
                recordSection

                Spacer()

                // 4. Action buttons
                actionButtons
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            if isNewRecord {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showBadge = true
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(isSuccess
                 ? String(localized: "challenge.result.title_success", defaultValue: "WELL DONE!")
                 : String(localized: "challenge.result.title_failure", defaultValue: "GOOD TRY!"))
                .font(DesignSystem.Fonts.monospaced(size: 32, weight: .bold))
                .foregroundColor(isSuccess
                                 ? DesignSystem.Colors.cyanElectric
                                 : DesignSystem.Colors.orangeElectric)
        }
    }

    private var scoreSection: some View {
        VStack(spacing: 12) {
            // Bonus line
            HStack {
                Text(String(localized: "challenge.result.correct_guesses", defaultValue: "Digits Guessed"))
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                    .foregroundColor(correctGuessCount > 0
                                     ? DesignSystem.Colors.cyanElectric
                                     : DesignSystem.Colors.textSecondary)
                Spacer()
                Text("\(correctGuessCount) × 10 = +\(bonus)")
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                    .foregroundColor(correctGuessCount > 0
                                     ? DesignSystem.Colors.cyanElectric
                                     : DesignSystem.Colors.textSecondary)
            }

            // Malus line
            HStack {
                Text(String(localized: "challenge.result.hints_used", defaultValue: "Hints Used"))
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                Spacer()
                Text("\(revealedCount) × 5 = -\(malus)")
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            // Separator
            Rectangle()
                .fill(DesignSystem.Colors.textSecondary.opacity(0.3))
                .frame(height: 1)

            // Score final
            HStack {
                Text(String(localized: "challenge.result.score", defaultValue: "Score"))
                    .font(DesignSystem.Fonts.monospaced(size: 20, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
                Text("\(score)")
                    .font(DesignSystem.Fonts.monospaced(size: 36, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
            }
        }
        .padding(20)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(16)
    }

    private var recordSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(String(localized: "challenge.result.best_score", defaultValue: "Personal Best"))
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                Spacer()
                if let best = previousBest {
                    Text("\(best)")
                        .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                } else {
                    Text(String(localized: "challenge.result.first_score", defaultValue: "—"))
                        .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }

            // New record badge
            if isNewRecord {
                Text(String(localized: "challenge.result.new_record", defaultValue: "NEW RECORD!"))
                    .font(DesignSystem.Fonts.monospaced(size: 13, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.blackOLED)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(DesignSystem.Colors.cyanElectric)
                    .cornerRadius(20)
                    .scaleEffect(showBadge ? 1.0 : 0.3)
                    .opacity(showBadge ? 1.0 : 0.0)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Train button (outline, orangeElectric)
            Button(action: onTrain) {
                Text(String(localized: "challenge.result.train", defaultValue: "TRAIN ON THIS SEGMENT"))
                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.orangeElectric)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DesignSystem.Colors.orangeElectric, lineWidth: 1.5)
                    )
            }

            // Done button (filled, cyanElectric)
            Button(action: onDismiss) {
                Text(String(localized: "challenge.result.done", defaultValue: "DONE"))
                    .font(DesignSystem.Fonts.monospaced(size: 18, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.blackOLED)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DesignSystem.Colors.cyanElectric)
                    .cornerRadius(16)
            }
        }
    }
}
