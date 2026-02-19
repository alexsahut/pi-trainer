# Story 12.1: Home Screen "Zen" Layout Refactor

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with a small screen device (iPhone SE/Mini),
I want a home screen that fits perfectly without scrolling or cutting off elements,
So that I can access all features comfortably and enjoy the "Zen" aesthetic.

## Acceptance Criteria

1. [x] **Remove Title:** The large "Pi Trainer" title is removed from the top of the screen to free up vertical space. Context is provided by the App Icon and content.
2. [x] **Compact Start Button:** The "Start Session" button is redesigned:
    - Reduced height (compact "Pill" shape).
    - Preserves touch target size (44pt minimum height) but reduces visual padding.
3. [x] **Optimized Spacing:** The vertical spacing between the Segment Slider, Mode Selector, and other elements is dynamic or reduced to prevent cramping.
4. [x] **Small Screen Compliance:** On an iPhone SE (3rd Gen) or iPhone 13 Mini simulator, the entire interface (including the bottom bar) is visible *without* scrolling.

## Tasks / Subtasks

- [x] **UI Refactor (HomeView)**
  - [x] Remove `Text("Pi Trainer")` title block.
  - [x] Refactor `StartSessionButton` (if it exists) or the button code to be adjustable/compact.
  - [x] Adjust `VStack` spacing or use `Spacer(minLength:)` intelligently.
- [x] **Verification**
  - [x] Verify layout on iPhone 15 Pro (Standard).
  - [x] Verify layout on iPhone SE 3 (Compact).

## Dev Notes

### Architecture & Logic Compliance

- **Design System:** Maintain the "Zen" aesthetic. Do not introduce new colors or clutter. Use existing `DesignSystem` tokens if adaptable.
- **Accessibility:** Ensure the new compact button still meets the 44x44pt touch durability requirement even if it looks smaller (use transparent padding if needed).

### References

- [Epics Definition](file:///Users/alexandre/.gemini/antigravity/brain/b574368e-258c-4db4-bc6d-2cb7b540a410/epics.md)

## Dev Agent Record

### Files Changed
- `PiTrainer/PiTrainer/HomeView.swift` (Layout refactor)
- `PiTrainer/PiTrainer/Features/Home/ZenPrimaryButton.swift` (Compact mode)
- `PiTrainer/PiTrainer/Features/Home/Components/GradeBadge.swift` (New component)
- `PiTrainer/PiTrainer/Features/Home/Components/XPProgressBar.swift` (New component)

### Review Notes
- Refactored `HomeView` to use smaller spacing and extracted components.
- Verified "Zen" aesthetic on small screens.
- Added `GradeBadge` and `XPProgressBar` as reusable components.
