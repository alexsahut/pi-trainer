# Story 9.6: Game Mode Rules & Onboarding

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a new gamer,
I want to see a clear explanation of the Twin-Shadows rules,
so that I understand how to earn my Stars and Ghosts and compete effectively.

## Acceptance Criteria

1. **Rules Page**: A dedicated view or overlay explaining the Crown (Distance) vs Lightning (Speed) PRs.
2. **Certification Explanation**: Clear mention that errors or reveals disqualify a run from being "Certified".
3. **Visuals**: Use icons (Crown, Lightning, Shield / Checkmark Shield) to illustrate the rules.
4. **Integration**: An "info" button in Game Mode or a first-launch overlay to access these rules.
5. **Contextual awareness**: Rules should be specific to Game Mode but accessible for reference.

## Tasks / Subtasks

- [x] Create `GameModeRulesView.swift` (AC: 1, 3)
    - [x] Implement layout with sections for Crown, Lightning, and Certification
    - [x] Style with DesignSystem (Black OLED, SF Mono, Cyan/Orange accents)
- [x] Implement "Info" Button in `SessionView` (AC: 4)
    - [x] Add button near mode title or in header
    - [x] Trigger the rules sheet/overlay
- [x] Implement First-Launch Logic (AC: 4)
    - [x] Use `@AppStorage("hasSeenGameModeRules")` to auto-show once
- [x] Add Strings to `Localizable.xcstrings` (AC: 1, 2)
    - [x] Translate titles and descriptions for Crown/Lightning/Certification in EN and FR
- [ ] Verify UI on iPad and iPhone (AC: 1)
- [ ] [AI-Review][High] Complete manual UI verification on physical devices or multiple simulators.

## Dev Notes

- **Architecture**: Follow the MVVM + Feature-Sliced pattern. View goes in `Features/Practice/`.
- **Ghost logic**: Refer to `GhostEngine` for rules (Crown = Distance/Marathon, Lightning = Speed/Sprint).
- **Certification**: Refer to `SessionViewModel.sessionEndStatus` logic: `!learn && revealsUsed == 0 && (errors == 0 || isSuddenDeathVictory)`.
- **Icons**: Use SF Symbols: `crown.fill`, `lightning.fill`, `checkmark.shield.fill`.

### Project Structure Notes

- `Features/Practice/GameModeRulesView.swift`
- `Features/Practice/SessionView.swift` (Integration)

### References

- [Source: epics.md#Story 9.6](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)
- [Source: SessionViewModel.swift#L107](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionViewModel.swift) (Certification logic)

## Dev Agent Record

### Agent Model Used

Antigravity (Claude 3.5 Sonnet)

### Debug Log References

### Completion Notes List

### File List

- [NEW] [GameModeRulesView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/GameModeRulesView.swift)
- [MODIFY] [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift)
- [MODIFY] [Localizable.xcstrings](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Localizable.xcstrings)
- [MODIFY] [SessionViewModel+Game.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Features/Practice/SessionViewModel+Game.swift)
- [MODIFY] [DesignSystem.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/DesignSystem.swift)
- [MODIFY] [TerminalGridView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift)
- [MODIFY] [SessionViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionViewModel.swift)
- [MODIFY] [PracticeEngineTests.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainerTests/PracticeEngineTests.swift)

## Review Follow-ups (AI)

- [x] [AI-Review][Medium] Git Tracking: Ensure `GameModeRulesView.swift` is staged and tracked. [FIXED]
- [ ] [AI-Review][High] Manual Verification: UI layout verification on iPad/iPhone is still pending.
- [ ] [AI-Review][Low] Architecture: Consider migrating `NavigationView` to `NavigationStack` for modern iOS standards.
- [ ] [AI-Review][Low] Testing: Rules UI lacks dedicated UI tests.
