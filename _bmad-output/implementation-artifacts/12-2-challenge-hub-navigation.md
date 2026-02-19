# Story 12.2: Challenge Hub Navigation

Status: review

<!-- Note: Validation of prerequisites complete. Context loaded from Epic 11/12 and Codebase. -->

## Story

As a user looking for my daily goal,
I want to access a dedicated "Challenge Hub" from the home screen,
So that I can clearly see today's challenge and launch it without friction.

## Acceptance Criteria

1. **Entry Point Integration**
   - The "Challenges" button in `HomeView` bottom bar (left slot) is active and tappable.
   - Tapping it navigates to the `ChallengeHubView`.

2. **Challenge Hub UI**
   - Displays the current Date.
   - Displays the **Daily Challenge Card**:
     - **Title**: "Daily Challenge" (or specific type name).
     - **Description**: e.g. "Find the sequence starting at #156".
     - **Status**: "Locked", "Play" (Active), or "Completed".
     - **Action**: Button to start the challenge.
     - **Reward Preview**: Shows potential XP/Badge gain.

3. **Navigation Logic**
   - Tapping "Start" on the challenge card launches a `SessionView` configured for the challenge:
     - **Mode**: Game (or a specialized Challenge mode if defined in `PracticeEngine`).
     - **Start Index**: Defined by the challenge (e.g. 156).
     - **End Index**: Defined by challenge length (e.g. 161).
     - **Challenge Context**: Passed to Session to handle success/failure logic specific to challenges.

4. **Empty State / Error Handling**
   - If `ChallengeService` returns no challenge (e.g. error or future date), display a friendly "No Challenge Today" or fallback message.

## Tasks / Subtasks

- [x] **Infrastructure (Navigation)**
  - [x] Add `.challengeHub` case to `NavigationCoordinator.Destination` enum.
  - [x] Update `HomeView` navigation handling to support `.challengeHub`.
  - [x] Connect the "Challenges" button in `HomeView` footer to `coordinator.push(.challengeHub)`.

- [x] **UI Implementation (ChallengeHubView)**
  - [x] Create `ChallengeHubView.swift` in `Features/Challenges`.
  - [x] Create `DailyChallengeCard.swift` component.
  - [x] Integrate `ChallengeService` to fetch today's challenge data.

- [x] **Session Integration**
  - [x] Ensure `SessionViewModel` accepts a `Challenge` object or parameters (startIndex, endIndex).
  - [x] Verify `PracticeEngine` is initialized with these parameters (Validated: Engine supports `start(mode:startIndex:endIndex:)`).

## Dev Notes

### Architecture & Logic Compliance

- **Navigation**: Must use `NavigationCoordinator` (router pattern). Do not use `NavigationLink` directly.
- **Dependency Injection**: `ChallengeService` should already be available or accessible via `ServiceLocator` / Singleton pattern if established, or instantiated in `HomeView` and passed/shared.
- **Design System**: Use `ZenPrimaryButton` for the start action. Use `DesignSystem.Colors.blackOLED` background.
- **Engine**: Use `PracticeEngine.start(mode: .game, startIndex: challenge.startIndex, endIndex: challenge.startIndex + challenge.length)` (or similar logic).

### Existing Components to Reuse

- `HomeView`: Footer button structure exists, just needs action wiring.
- `ChallengeService`: Logic for generating/checking challenges is implemented.
- `DesignSystem`: Colors, Fonts.
- `SessionViewModel`: Ensure it exposes the engine's start/end index configuration.

### References

- [Epic 11 (Functionality)](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)
- [Practice Engine Source](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift)
- [Challenge Service Source](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift)

## Dev Agent Record

### Agent Model Used
{{agent_model_name_version}}

### Debug Log References
- Confirmed `PracticeEngine` supports arbitrary start/end indices.
- Confirmed `ChallengeService` generates `Challenge` struct with `startIndex`.

### File List

#### [MODIFY] [NavigationCoordinator.swift](PiTrainer/PiTrainer/Shared/Navigation/NavigationCoordinator.swift)
#### [NEW] [NavigationCoordinatorTests.swift](PiTrainer/PiTrainerTests/NavigationCoordinatorTests.swift)
#### [MODIFY] [HomeView.swift](PiTrainer/PiTrainer/HomeView.swift)
#### [NEW] [ChallengeHubView.swift](PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift)
#### [NEW] [DailyChallengeCard.swift](PiTrainer/PiTrainer/Features/Challenges/Components/DailyChallengeCard.swift)
#### [MODIFY] [SessionViewModel.swift](PiTrainer/PiTrainer/SessionViewModel.swift)
#### [MODIFY] [SessionViewModelTests.swift](PiTrainer/PiTrainerTests/SessionViewModelTests.swift)

### Change Log

- **Navigation**: Added `.challengeHub` route and support infrastructure.
- **UI**: Added `ChallengeHubView` as main entry for challenges, linked from `HomeView` footer.
- **Components**: Created `DailyChallengeCard` to display daily challenge details.
- **Core Logic**: Updated `SessionViewModel` with `configureForChallenge(_:)` to override session settings based on challenge data.
- **Tests**: Added tests for Navigation destination and SessionViewModel challenge configuration.

### AI Code Review Fixes (2026-01-25)

- **Challenge Logic**: Added `onChallengeCompleted` callback to `SessionViewModel` to trigger `ChallengeService.markChallengeAsCompleted()`.
- **UI Cleanup**: Removed duplicate navigation cases and redundant configuration calls in `HomeView`.
- **Logic**: Use user's selected constant for daily challenge instead of hardcoded Pi.
- **Navigation**: Properly use the `mode` parameter in `navigationDestination`.

### Status

Status: done
