# Story 3.1: Sélection de la Constante Mathématique

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur,
I want pouvoir choisir entre différentes constantes (Pi, e, phi),
so that varier mes défis de mémorisation.

## Acceptance Criteria

1. **Given** l'écran d'accueil
2. **When** je change de constante via le sélecteur
3. **Then** la source de données du `PracticeEngine` est mise à jour avec les nouveaux chiffres
4. **And** le titre de l'écran et les records affichés correspondent à la constante sélectionnée.
5. **And** la sélection est persistée entre les lancements (via UserDefaults par exemple, implicite pour l'UX).

## Tasks / Subtasks

- [x] Task 1: Update Architecture for Multi-Constant Support
  - [x] Modify `PracticeEngine` (or `SessionViewModel`) to accept a `Constant` parameter at initialization or via a method.
  - [x] Ensure `FileDigitsProvider` can handle dynamic constant switching (already implemented effectively via init, but ensure lifecycle management).
- [x] Task 2: Create Constant Selector UI
  - [x] Implement a `ConstantSelectorView` (or integrate into `HomeView`) using a `Picker` or custom segmented control.
  - [x] Apply "Dark & Sharp" design system to the selector (Cyan accent).
- [x] Task 3: Integrate Selection Logic
  - [x] Bind the selector to a `@AppStorage` or `@Observable` property in `HomeViewModel` (or equivalent).
  - [x] Pass the selected constant to the `SessionView` / `PracticeEngine` when starting a session.
- [x] Task 4: UI Updates & Polish
  - [x] Update Home screen title dynamically. <!-- e.g., "Pi Trainer" -> "e Trainer"? Or just show symbol -->
  - [x] Verify that Personal Bests (PB) displayed on Home correspond to the selected constant (preparation for Story 4.2, but basics should be there if PBs are displayed).
- [x] Task 5: Testing
  - [x] Unit Test: Verify `PracticeEngine` loads correct digits for `e` and `phi`.
  - [x] UI Test: Verify selector changes the constant context.

## Dev Notes

- **Architecture Constraints**:
  - `Constant` enum already exists in `Constant.swift`.
  - `FileDigitsProvider` already implemented to load `pi_digits`, `e_digits`, etc.
  - **Structure**: New Views should go in `PiTrainer/PiTrainer/Features/Home/` (or `Selection/`).
  - **State**: Use `@Observable` for the ViewModel managing the selection.

### Project Structure Notes

- **Critical**: Ensure any new Swift files are added to `PiTrainer/PiTrainer/` to comport with Xcode 16 strict sync groups.

### References

- [Epics Source](_bmad-output/planning-artifacts/epics.md) - Story 3.1
- [Project Context](_bmad-output/planning-artifacts/project-context.md) - Structure Rules

## Dev Agent Record

### Agent Model Used

Gemini 2.0 Flash (Authentication/Planning Phase)

### Debug Log References

- None yet.

### Completion Notes List

- Implemented multi-constant support in `PracticeEngine` and `SessionViewModel`.
- Updated `HomeView` with dynamic title.
- Added persistence logic using constant IDs.
- Fixed compilation errors in `PositionTrackerTests` and `StreakFlowTests`.
- Added new test validation logic in `PracticeEngineTests`.

### File List

- PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift
- PiTrainer/PiTrainer/SessionViewModel.swift
- PiTrainer/PiTrainer/HomeView.swift
- PiTrainer/PiTrainer/DesignSystem.swift
- PiTrainer/PiTrainer/Localizable.xcstrings
- PiTrainer/PiTrainer/Features/Practice/ProPadView.swift
- PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift
- PiTrainer/PiTrainerTests/PracticeEngineTests.swift
- PiTrainer/PiTrainerTests/PositionTrackerTests.swift
- PiTrainer/PiTrainerTests/StreakFlowTests.swift
- PiTrainer/PiTrainerTests/KeypadLayoutTests.swift
