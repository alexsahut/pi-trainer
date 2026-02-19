# Hotfix Implementation Plan: Critical Regressions Epic 12

Major regressions identified post-Epic 12 release. Immediate corrective maintenance required.

## User Review Required

> [!CRITICAL]
> **Records Menu Missing**: The new "Challenges" button replaced the "Stats/Records" access in the footer.
> **Fix**: Re-introduce a dedicated access for Records/Stats, or combine it with Settings. Given the "Zen" constraint, we will group "Profile & Settings" to free up a slot, or use a 3-button footer.
> **Proposal**: Restore 3-button footer (Challenges | Stats | Settings) as space permits on standard phones, or group Stats/Settings if on SE. _Decision: 3-button footer for now to restore access quickly._

> [!CRITICAL]
> **Challenge Hub App Crash**: User reports crash. Suspect `ChallengeService` force-unwrapping or missing resource bundle for `challenges.json`.

> [!WARNING]
> **Grade Display Bug**: "GRADE.NOVICE" raw string displayed instead of "NOVICE".

## Proposed Changes

### UI Layer

#### [MODIFY] [HomeView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/HomeView.swift)
- **Restore Stats Access**: Update footer `HStack` to include 3 buttons: Challenges (Left), Stats (Center), Settings (Right).
- **Optimize Footer**: Ensure spacing is dynamic for small screens.

#### [MODIFY] [DesignSystem.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/DesignSystem.swift)
- **Fix Grade Enum**: Verify `displayName` property returns capitalized string without "GRADE." prefix.
- **Debug**: Check if `Localizable.xcstrings` is missing the key if localized.

### Logic Layer

#### [MODIFY] [ChallengeService.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift)
- **Safety Check**: Ensure `generateDailyChallenge` returns a safe Fallback Challenge if `challenges.json` fails to load, instead of crashing.
- **Error Handling**: Add do-catch block around JSON decoding.

## Verification Plan

### Automated Tests
- `xcodebuild test -only-testing:PiTrainerTests/ChallengeServiceTests` (Verify safe fallback)
- `xcodebuild test -only-testing:PiTrainerTests/DesignSystemTests` (Verify grade strings)

### Manual Verification
1.  **Launch App**: Verify Home screen footer has 3 buttons.
2.  **Navigation**: Tap "Stats" -> Verify Dashboard opens.
3.  **Navigation**: Tap "Challenges" -> Verify Hub opens (No Crash).
4.  **UI**: Check Grade Badge on Home Screen. Should read "NOVICE" (not "GRADE.NOVICE").
