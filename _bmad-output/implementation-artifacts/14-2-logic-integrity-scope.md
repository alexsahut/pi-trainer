# Story 14.2: Adaptive Logic Integrity (Scope Guard)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user,
I want the challenge to only ask for digits that I have already learned,
so that I am never blocked by an unfair requirement for unknown decimals.

## Acceptance Criteria

1. **Scope Guard**: Given my highest known index is N, when a challenge is generated (Daily or Train Now), then the `startIndex + promptLength + targetLength` must be less than or equal to N.
2. **Filtering**: The `ChallengeService` filters out any candidate sequences that would overshoot my learned range and finds a valid one within scope.

## Tasks / Subtasks

- [x] Analyze `ChallengeService.swift`
- [x] Implement failing test `testChallengeGenerationRespectsScope` in `ChallengeServiceTests.swift`
- [x] Modify `ChallengeService.createChallenge` to enforce `expectedEnd <= highestIndex`
- [x] Update `generateDailyChallenge` and `generateRandomChallenge` with a retry loop to find a valid challenge within scope
- [x] Verify all tests in `ChallengeServiceTests.swift` pass

## Dev Notes

- **Mental Model**: Challenges should be a review of known digits, not a discovery of new ones.
- **Implementation**: Uses a simple retry loop (50 iterations) to find a valid MUS and target sequence within the user's `highestIndex`.

### Project Structure Notes

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift`
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift`

### References

- [Epics: Story 14.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#Story-142-Adaptive-Logic-Integrity-Scope-Guard)

## Dev Agent Record

### Agent Model Used

Antigravity (Gemini 2.0 Flash)

### Debug Log References

- [Tests Passed](step-id:240)

### Completion Notes List

- Implemented strict scope guard in `ChallengeService`.
- Added new test case for scope validation.
- Fixed existing tests that used insufficient `highestIndex`.

### File List

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift`
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift`
