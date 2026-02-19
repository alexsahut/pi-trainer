# Story 13.3: On-Demand Training Mode

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want to generate new challenges instantly without waiting for the next day,
so that I can train as much as I want.

## Acceptance Criteria

1. **Given** I am on the Challenge Hub, **When** I see the "Train Now" button (distinct from Daily Challenge), **Then** I can tap it to instantly generate a new adaptive challenge.
2. **And** completing it awards XP but does **NOT** increment the "Daily Streak".
3. **And** there is no limit to how many times I can use it.
4. **And** the generated challenge follows the same format as Daily Challenges (Context + Missing Digits).
5. **And** the context is randomly selected from the first 10,000 decimals (or user's unlocked range).

## Tasks / Subtasks

- [x] Implement Random Challenge Generation
  - [x] Extend `ChallengeService` with `generateRandomChallenge() -> Challenge`
  - [x] Implement algorithms to pick a random `startIndex` (ensuring bounds)
  - [x] Reuse `DigitsProvider` to fetch reference sequence (context) and expected digits
  - [x] Ensure unique ID generation for each training session
- [x] Update Challenge Hub Logic (`ChallengeHubViewModel`)
  - [x] Add `trainNow()` action
  - [x] Add state `presentedChallenge: Challenge?` to drive navigation
  - [x] Ensure distinct handling for Daily vs Training (Daily updates streak, Training does not)
- [x] Update Challenge Hub UI (`ChallengeHubView`)
  - [x] Add "Train Now" button below the Daily Challenge card
  - [x] Style button clearly as a secondary/unlimited action (distinct from the unique Daily Card)
  - [x] Bind navigation to `ChallengeSessionView` using the generated challenge
- [x] Verify XP & Persistence Isolation
  - [x] Confirm `ChallengeViewModel` credits XP (already implemented in 13.2)
  - [x] Confirm `lastDailyChallengeDate` is **NOT** updated when completing a Training challenge
  - [x] Verify infinite replayability (no cooldown)
- [x] Review Follow-ups (AI)
  - [x] [AI-Review][Low] Extracted duplicated mocks to `ChallengeMocks.swift` during review.

## Dev Notes

- **Architecture**:
  - `ChallengeService` should be the factory for all `Challenge` objects (Daily and Random).
  - `ChallengeSessionView` is the reusable UI component for both modes.
  - `ChallengeViewModel` handles the actual interaction logic (validation, XP).
  - **Separation of Concerns**: The *Caller* (`ChallengeHub`) deterimines what happens on completion (Streak update vs Nothing), while the *ViewModel* handles the session mechanics. Since 13.2 implemented XP crediting inside the VM (`statsStore.creditXP`), this is shared behavior, which is correct (XP is earned for effort everywhere). Streak logic must remain outside the VM or be conditional. **Current approach:** Streak logic is likely in `ChallengeHub`'s `onComplete` or handled by `ChallengeService.markDailyComplete()`. Ensure Training flow does NOT call this.
- **Data Source**:
  - Use `DigitsProvider` (likely available via `ChallengeService` or Singleton) to get the raw numbers.
  - Target range: 0 to 10,000 for relevant practice, or based on User's max known index if available. Default to a safe range (e.g. 0-1000) if no metrics. *Decision: Random 0-1000 for now to ensure accessibility.*

### Project Structure Notes

- `PiTrainer/PiTrainer/Features/Challenges/Services/ChallengeService.swift` (Create or Update)
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubViewModel.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift`
- `PiTrainer/PiTrainer/Core/Data/Challenge.swift` (Model)

### References

- [Epics: Story 13.3](file:///_bmad-output/planning-artifacts/epics.md)
- [Architecture: V2.9 Challenge Service](file:///_bmad-output/planning-artifacts/architecture.md)
- [Source: ChallengeSessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift)

## Dev Agent Record

### Agent Model Used

Antigravity (Gemini 2.0 Flash)

### Debug Log References
- Added `isDaily` to `NavigationCoordinator` to support separate completion logic.
- Refactored `ChallengeService` to share `createChallenge` logic between Daily and Random generators.
- Created `ChallengeHubViewModel` to handle Hub logic (refactored from View).

### Completion Notes List
- Implemented `generateRandomChallenge` in `ChallengeService` using true random generation (SystemRandomNumberGenerator).
- Implemented `ChallengeHubViewModel` with `trainNow` action.
- Added "Train Now" button to `ChallengeHubView` with unlimited play.
- Ensured Training Mode does not update Daily Streak (via `isDaily` flag in Navigation).
- Verified XP is credited for all challenges.

### File List
- PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift
- PiTrainer/PiTrainer/Features/Challenges/ChallengeHubViewModel.swift
- PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift
- PiTrainer/PiTrainer/Shared/Navigation/NavigationCoordinator.swift
- PiTrainer/PiTrainer/HomeView.swift
- PiTrainer/PiTrainerTests/ChallengeServiceTests.swift
- PiTrainer/PiTrainerTests/ChallengeHubViewModelTests.swift

### Change Log
- 2026-01-25: Implemented Story 13.3 - On-Demand Training Mode. Added random challenge generation and updated Hub UI.
