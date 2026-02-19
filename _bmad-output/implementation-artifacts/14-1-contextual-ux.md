# Story 14.1: Contextual UX & Messaging

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want to be prompted to "Continue the sequence" based on what I see on screen,
so that I don't have to think about technical "indexes" or "positions" while training my memory.

## Acceptance Criteria

1. **Daily Challenge Card (Hub)**: The description must be changed from "Find sequence starting at index #X" to "Continue the sequence..." or "Follow the sequence...".
2. **Challenge Session View**: The header and internal labels must emphasize the "Sequence" context instead of technical identifiers.
3. **Recovery Bridge**: The "Practice This" button must be clearly labeled to indicate it helps the user learn the specific sequence they just failed.
4. **Localization**: All updated strings must be properly localized (French/English).

## Tasks / Subtasks

- [x] Update `DailyChallengeCard.swift` ([L70](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/Components/DailyChallengeCard.swift#L70))
  - [x] Replace `challengeDescription` pattern.
  - [x] **Target**: Change "Find the sequence starting at index #X" to "Continue the sequence after..." or "Follow the pattern after...".
- [x] Update `ChallengeSessionView.swift`
  - [x] **L110**: Change `Text("CHALLENGE")` to `Text("FOLLOW THE SEQUENCE")`. Use `cyanElectric`.
  - [x] **L142**: Change `Text("PROMPT")` to `Text("STARTING PATTERN")`.
  - [x] **Accessibility**: Ensure `accessibilityLabel` for the prompt ([L150](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift#L150)) reflects the new context.
- [x] Update `ChallengeViewModel.swift` ([L113-135](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift#L113-135))
  - [x] Review `triggerRecovery` to ensure the transition to Learn mode carries the correct "Sequence" context.

## Dev Notes

- **Mental Model**: Transition from "Technical Position" (Index) to "Memory Context" (Pattern).
- **Localization**: Ensure we don't break i18n while changing these strings.
- **Visuals**: Maintain the `DesignSystem.Fonts.monospaced` for the sequence itself.

### Project Structure Notes

- `PiTrainer/PiTrainer/Features/Challenges/Components/DailyChallengeCard.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift`

### References

- [Epics: Story 14.1](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)
- [Retro: Failure 1](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-13-retrospective.md#Failure-1-Mental-Model-Mismatch-Index-vs-Context)

## Dev Agent Record

### Agent Model Used

Antigravity (Gemini 2.0 Flash)

### Debug Log References

- [Tests Succeeded](step-id:75)
- [Review Fixes Verified](step-id:141)

### Completion Notes List

- Updated `DailyChallengeCard.swift` description to "Continue the sequence from #X" (localized).
- Updated `ChallengeSessionView.swift` header to "FOLLOW THE SEQUENCE" and prompt label to "STARTING PATTERN" (localized).
- Updated Accessibility labels in `ChallengeSessionView.swift` for better context (localized).
- Refined "Practice This" label to "PRACTICE THIS SEQUENCE" (localized).
- Updated `ChallengeViewModel.swift` documentation for recovery bridge context.
- Verified all changes with `ChallengeViewModelTests`.
- **Review Fixes**: Added full French/English localization, removed magic numbers in `ChallengeViewModel`, and cleaned up unused localization keys.

### File List

- `PiTrainer/PiTrainer/Features/Challenges/Components/DailyChallengeCard.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift`
- `PiTrainer/PiTrainer/DesignSystem.swift`
- `PiTrainer/PiTrainer/Localizable.xcstrings`

## Dev Agent Record (Senior Reviewer)

### Senior Developer Review (AI)

**Outcome**: Approved with fixes
**Date**: 2026-01-26
**Action Items**:
- [x] [HIGH] Implement missing localization in `Localizable.xcstrings`
- [x] [MEDIUM] Remove hardcoded strings in UI components
- [x] [MEDIUM] Replace magic numbers in `ChallengeViewModel`
- [x] [LOW] Cleanup unused localization keys

## Change Log

- 2026-01-26: Initial implementation of Contextual UX & Messaging (Story 14.1). Updated UI strings and accessibility for sequence-focused mental model.
- 2026-01-26: Fixed code review findings regarding localization and technical debt.
