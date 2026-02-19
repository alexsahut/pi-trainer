# Implementation Plan - Adaptive Daily Challenge (V2)

## Goal
Align the Daily Challenge behavior with the original "Zen Athlete" vision:
1.  **Known Segment**: The challenge sequence must start within the *user's known range* (Highest Index reached), not random digits they've never seen.
2.  **Adaptive Difficulty**: The number of digits to guess must depend on the user's **Grade** (e.g., Novice = 3 digits, Grandmaster = 10+), not a fixed number.

## User Review Required
> [!IMPORTANT]
> **Logic Change**: The "Challenge" will now require the `Grade` to be passed to the generator.
> **Difficulty Curve**:
> - Novice: Guess 3 digits
> - Apprentice: Guess 5 digits    
> - Athlete: Guess 8 digits
> - Expert: Guess 12 digits
> - Grandmaster: Guess 15 digits

> [!NOTE]
> **Data Discrepancy**: The user reported seeing index 268 while their "PR" is 21. This suggests `highestIndex` (persistence) might be desynced or tracking something different than "Best Streak". We will ensure `highestIndex` is clamped to reasonable bounds if it seems erroneous, but primarily we will rely on `PracticePersistence.getHighestIndex`. If this value is corrupted on the user's device, they might see advanced content until they reset.

## Proposed Changes

### 1. Model Layer
#### [MODIFY] [Grade.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Shared/Models/Grade.swift)
- Add `challengeLength: Int` property to `Grade` enum.

### 2. Service Layer
#### [MODIFY] [ChallengeService.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift)
- Update `generateDailyChallenge` signature to accept `grade: Grade`.
- Use `grade.challengeLength` to determine `expectedNextDigits`.
- **Safety**: Ensure `startIndex` calculation strictly respects `highestIndex`. If `highestIndex` < 10 (new user), default to a small safe range (0-10).
- **Uniqueness Guarantee**: The algorithm will calculate MUS **only within the known segment** (`0...highestIndex`). This matches the original Python algorithm and ensures the sequence is unique *within what the user has learned*, avoiding confusion with future digits they haven't seen yet.

### 3. UI Layer
#### [MODIFY] [ChallengeHubView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift)
- Specific passing of `StatsStore.shared.currentGrade` to the service.

#### [MODIFY] [SessionViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionViewModel.swift)
- **Prompt Display**: When starting a challenge, pre-fill `typedDigits` with `challenge.referenceSequence` so the user sees the context immediately.
- **Engine Logic**: Initialize the engine starting *after* the reference sequence (`startIndex + referenceSequence.count`).
- **Goal**: Set the session target (end index) to match `expectedNextDigits` length (`start + ref + grade_length`).
- **Feedback**: This ensures the user only types the *missing* digits, and the session ends automatically when they finish the sequence.

## Verification Plan

### Automated Tests
- Run `PiTrainerTests` (if available) or create a new test case for `ChallengeService` verifying length matches Grade.

### Manual Verification
1.  **Check Grade**: Users sees "Novice".
2.  **Check Challenge**: Generated challenge asks for 3 digits (Novice count).
3.  **Check Range**: Ensure the index is within logical bounds (checking manually against expected "known" range).
