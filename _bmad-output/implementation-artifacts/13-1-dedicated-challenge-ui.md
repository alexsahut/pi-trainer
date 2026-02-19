# Story 13.1: Dedicated Challenge UI (ChallengeSessionView)

Status: done

## Story

As a user,
I want a dedicated interface for challenges that clearly shows the sequence context and the empty slots to fill,
so that I understand exactly what is asked of me without being confused with the standard game mode.

## Acceptance Criteria

1. **Given** I launch a challenge from the hub, **When** the challenge view appears, **Then** I see the "Prompt" sequence (e.g., "3.1415...") clearly displayed as read-only.
2. **And** I see placeholders for the digits I need to find (e.g., "_ _ _").
3. **And** the standard numeric keypad is available.
4. **And** the UI is distinct from the standard Game Mode (e.g., specific header "Challenge").

## Tasks / Subtasks

- [x] Create `ChallengeSessionView` and `ChallengeViewModel`
  - [x] Initialize `ChallengeViewModel` as `@Observable` class
  - [x] Create `ChallengeSessionView` SwiftUI view
  - [x] Add navigation/presentation logic from `ChallengeHubView` (or Home) to `ChallengeSessionView`
- [x] Implement Challenge UI Structure
  - [x] Add distinct Header ("Challenge du Jour" / "Training")
  - [x] **Prompt Section**: Display the 'prompt' part of the sequence (read-only, distinct style)
  - [x] **Target Section**: Display underscores `_` for missing digits (dynamic count)
- [x] Integrate Numeric Keypad
  - [x] Reuse `KeypadView` component
  - [x] Connect keypad input to `ChallengeViewModel` input logic
- [x] UX/UI Polish
  - [x] Ensure visual distinction from standard `GameView` (e.g., different background hint or layout)
  - [x] Check accessibility (VoiceOver for prompt and empty slots)

## Dev Notes

- **Architecture**:
  - `ChallengeSessionView` should be in `PiTrainer/PiTrainer/Features/Challenge/`.
  - usage of `@Observable` for ViewModel is mandatory.
- **Components**:
  - Reuse `KeypadView.swift` existing component.
  - Do not duplicate logic from `PracticeEngine` if possible, but Challenge logic might be simpler (just matching string) or specialized (`ChallengeEngine`?). *Note: Logic integration is Story 13.2, but ViewModel needs basic state.*
- **UX**:
  - "Prompt" vs "Target" separation is key (FR-Repair-1).
  - "Read-only" format for prompt.

### Project Structure Notes

- New Feature: `Features/Challenge`
- Core dependencies: `Core/Haptics` (for future feedback in 13.2), `Core/Data` (for retrieving records).

## Dev Agent Record

### Agent Model Used

Antigravity (Gemini 2.0 Flash)

### Debug Log References

- Fix build errors in `ChallengeServiceTests.swift` (static method calls, missing grade argument).
- Update `Challenge` to `Hashable` for Navigation usage.
- Update `ChallengeViewModel` to handle Int inputs from `KeypadView`.
- **Code Review**: Fixed Accessibility (VoiceOver) issues in `ChallengeSessionView`.
- **Code Review**: Localized hardcoded strings in `ChallengeSessionView`.

### Completion Notes List

- Implemented `ChallengeViewModel` using `@Observable` and `Challenge` model.
- Created `ChallengeSessionView` with distinct UI layout.
- Integrated `KeypadView` with correct event handling (digit, backspace, reset).
- Updated Navigation system (Coordinator, HomeView) to support seamless transition to Challenge Session.
- Added comprehensive Unit Tests for ViewModel logic.
- Verified test pass status.

### File List

- PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift
- PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift
- PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift
- PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift
- PiTrainer/PiTrainer/Shared/Navigation/NavigationCoordinator.swift
- PiTrainer/PiTrainer/HomeView.swift
- PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift
- PiTrainer/PiTrainerTests/ChallengeServiceTests.swift
