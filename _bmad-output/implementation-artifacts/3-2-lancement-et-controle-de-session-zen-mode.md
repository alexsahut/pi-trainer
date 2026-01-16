# Story 3.2: Lancement et Contrôle de Session (Zen Mode)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur,
I want démarrer une session sans friction et ne pas être interrompu accidentellement,
So that rester concentré à 100%.

## Acceptance Criteria

1. **Given** l'écran de pratique prêt
2. **When** je saisis le premier chiffre
3. **Then** la session démarre automatiquement sans bouton "Start" supplémentaire
4. **And** le mode Zen est activé via `.interactiveDismissDisabled(true)`
5. **And** un tap long (3s) ou une erreur permet de quitter la session.

## Tasks / Subtasks

- [x] Task 1: Update Session State Management
  - [x] Modify `SessionViewModel` (and `PracticeEngine`) to handle `Idle` vs `Active` states.
  - [x] Ensure `PracticeEngine` transition to `Active` happens *immediately* upon first valid digit input.
- [x] Task 2: Implement Auto-Start Logic
  - [x] Remove any existing "Start" button from `SessionView` if present.
  - [x] Ensure the keypad is active and listening even in `Idle` state (if appropriate) or activates seamlessly.
- [x] Task 3: Zen Mode Implementation (Navigation Lock)
  - [x] Apply `.interactiveDismissDisabled(true)` to `SessionView` when state is `Active`.
  - [x] Disable non-essential swipes or navigation gestures during the session.
- [x] Task 4: Exit Mechanisms
  - [x] **Long Press**: Add a `LongPressGesture(minimumDuration: 3.0)` to the background or specific area to trigger session end/exit.
  - [x] **Error Handling**: Ensure `PracticeEngine` error events trigger the "End Session" state transition (and navigation back/overlay).
  - [x] **Feedback**: Provide haptic feedback (Success/Error pattern) on exit.
- [x] Task 5: Testing & Validation
  - [x] **Unit Test**: Verify state transitions (Idle -> Active -> Ended).
  - [x] **UI Test**: Verify swipe to dismiss is disabled during session.
  - [x] **Manual**: Test the 3s long press behavior.

## Dev Notes

- **Architecture Compliance**:
  - Use `@Observable` for `SessionViewModel`.
  - **Critical**: Ensure `interactiveDismissDisabled` is bound to the `@Observable` state `isActive` (or similar).
  - **Performance**: The state transition must not cause a frame drop. Code should be lightweight.
- **Haptics**:
  - Remember to use `HapticService` for the exit feedback (e.g., a distinct vibration for "Session Aborted" vs "Session Failed").
- **Project Structure**:
  - Modifications likely in `PiTrainer/PiTrainer/Features/Practice/` (`SessionView.swift`, `SessionViewModel.swift`).
  - Core logic updates in `PiTrainer/PiTrainer/Core/Engine/` (`PracticeEngine.swift`).

### References

- [Epics Source](_bmad-output/planning-artifacts/epics.md) - Story 3.2
- [Architecture](_bmad-output/planning-artifacts/architecture.md) - Lifecycle & Haptics decisions.
- [Project Context](_bmad-output/planning-artifacts/project-context.md) - Sync Groups & Quality Gates.

## Dev Agent Record

### Agent Model Used
Gemini 2.0 Flash (Planning/Context Phase) + Antigravity (Implementation + Review)

### Debug Log References
- Fixed regression in `PracticeEngineTests` due to auto-start logic.
- Fixed `ProPadViewModel` default opacity to match test expectations.
- **Review Fixes**: Added `objectWillChange.send()` in `SessionViewModel.endSession()` to ensure UI update. Improved test clarity in `PracticeEngineTests`.

### Completion Notes List
- Implemented `State` enum in `PracticeEngine` to support Idle/Ready/Running phases.
- Implemented Auto-Start on first digit input.
- Implemented Zen Mode (Navigation Lock) bound to running state.
- Implemented Long Press (3s) to abort session.

### File List
- PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift
- PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift
- PiTrainer/PiTrainer/SessionView.swift
- PiTrainer/PiTrainer/SessionViewModel.swift
- PiTrainer/PiTrainerTests/PracticeEngineTests.swift
