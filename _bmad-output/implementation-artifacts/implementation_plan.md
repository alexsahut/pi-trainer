# Implementation Plan - Story 10.3: Fix Learn Mode UI & Reset Loop Button

## Goal Description
Fix the layout regression in Learn Mode where the keyboard appears in the middle of the screen, and implement the "Reset Loop" button functionality in place of the back button for this mode.

## User Review Required
> [!IMPORTANT]
> **UI Change:** The "Back" button on the keypad will be replaced by "Reset Loop" in Learn Mode. Navigation back to home must be handled via standard gestures or the Options menu.

## Proposed Changes

### PiTrainer/PiTrainer
#### [MODIFY] [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift)
- specific fix: Move the closing brace of the main `VStack` to include `Spacer()` and `ProPadView`, ensuring the keyboard is pushed to the bottom.

#### [MODIFY] [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift)
- Add `showResetLoop: Bool` property (or `sessionMode`).
- Add `onResetLoop: () -> Void` closure.
- In the grid layout, check `if showResetLoop`:
    - Render "Reset Loop" button (arrow.counterclockwise).
    - Trigger `onResetLoop`.
- Else:
    - Render "Back" button (as existing).

#### [MODIFY] [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift) (Wiring)
- Update `ProPadView` initialization to pass `showResetLoop: viewModel.selectedMode == .learn` and `onResetLoop: viewModel.resetLoop`.

## Verification Plan

### Automated Tests
- **UI Test:** (Optional) Verify button existence in Learn Mode vs Practice Mode.

### Manual Verification
1. Open App -> Select **Learn Mode**.
2. **Verify Layout:** Keyboard should be at the very bottom.
3. **Verify Button:** Bottom-left button should be "Reset Loop" icon (⟳).
4. **Functionality:** Tap "Reset Loop" -> Confirm reset.
5. Exit to Home -> Select **Practice Mode**.
6. **Verify Button:** Bottom-left button should be "Back" (<) or Empty.
