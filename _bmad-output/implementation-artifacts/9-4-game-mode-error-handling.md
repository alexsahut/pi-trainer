# Story 9.4: Gestion des Erreurs Game Mode (-1 Pénalité)

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a gamer,
I want que mes erreurs ne stoppent pas la session mais me pénalisent,
so that continuer ma course tout en payant le prix de mes fautes.

## Acceptance Criteria

1. [x] **Error Tolerance:** La session ne s'arrête pas en cas d'erreur en mode **GAME**.
2. [x] **Corrective Input:** L'utilisateur doit saisir le chiffre correct pour avancer après une erreur (l'index n'avance pas sur une erreur).
3. [x] **Visual Ghost Reveal:** Le chiffre correct est révélé en transparence (~20-30% d'opacité) à l'emplacement du curseur immédiatement après une erreur.
4. [x] **Effective Position Penalty:** La position effective du joueur (utilisée pour l'Horizon Line) recule de 1 à chaque erreur (Formule : `(currentIndex - startIndex) - errors`).
5. [x] **Feedback Consistency:** Le feedback d'erreur standard (flash rouge + vibration) est maintenu.

## Tasks / Subtasks

- [x] **PracticeEngine Logic Refinement** (AC: 1, 2)
  - [x] Vérifier que `PracticeEngine.input()` en mode `.game` retourne `indexAdvanced = false` sur une erreur.
- [x] **ViewModel Integration** (AC: 4)
  - [x] Valider `playerEffectivePosition` dans `SessionViewModel+Game.swift` pour inclure la pénalité `errors`.
  - [x] S'assurer que `expectedDigit` est exposé à la vue même en mode Game.
- [x] **UI Rendering - Ghost Reveal** (AC: 3, 5)
  - [x] Modifier `TerminalGridView` pour accepter un `wrongInputDigit` et un `currentIndex` (ou via `typedDigits` count).
  - [x] Afficher le chiffre attendu (`expectedDigit`) en filigrane lors de l'état `showError`.
- [x] **Sudden Death Compatibility** (AC: 1)
  - [x] S'assurer que la règle de Story 9.5 (Victoire si erreur en étant en tête) reste prioritaire sur la continuation.

## Dev Notes

- **Architecture:** Le `PracticeEngine` est déjà configuré pour gérer le mode `.game`. La modification principale réside dans le feedback visuel du `TerminalGridView`.
- **Performance:** La révélation du chiffre fantôme ne doit pas affecter le GPU Rendering (`.drawingGroup()`).
- **Sudden Death:** Cette règle (Story 9.5) bypass le comportement "continue" de 9.4 si le joueur est en avance sur le ghost au moment de l'erreur.

### Project Structure Notes

- **SessionViewModel+Game.swift:** Centralise les calculs de position pour l'Horizon Line.
- **TerminalGridView.swift:** Gère le rendu conditionnel des chiffres (normal vs active vs error vs ghost).

### References

- [Epic 9: Story 9.4](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L558)
- [Architecture V2.5: Error Handling](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L399)
- [Story 9.5: Sudden Death Logic](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/9-5-dynamic-pr-recording.md)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

- Validation Suite: PracticeEngineGameModeTests (Passed)

### Completion Notes List

- Verified `PracticeEngine` logic for Game Mode (errors non-fatal, index pause).
- Added Unit Tests in `PracticeEngineTests.swift` (Game Mode section) covering AC 1, 2.
- Verified `SessionViewModel` logic for effective position (AC 4) and sudden death (AC 1/Story 9.5).
- Implemented Ghost Reveal on error in `TerminalGridView.swift` (AC 3).
- Maintained standard error feedback (AC 5).
- Applied follow-up fixes from AI Code Review (Ghost reveal duration, Magic numbers, Type consistency).

### File List
- `PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift` [MODIFY]
- `PiTrainer/PiTrainerTests/PracticeEngineTests.swift` [MODIFY]
- `PiTrainer/PiTrainer/SessionViewModel.swift` [MODIFY]
- `PiTrainer/PiTrainer/DesignSystem.swift` [MODIFY]
- `PiTrainer/PiTrainer/Core/Features/Practice/SessionViewModel+Game.swift` [MODIFY]
- `PiTrainer/PiTrainer/SessionView.swift` [MODIFY]
