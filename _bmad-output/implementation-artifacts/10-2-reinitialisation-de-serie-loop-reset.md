# Story 10.2: Réinitialisation de série (Loop Reset)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a apprenant en mode Learn,
I want pouvoir recommencer ma boucle (série) actuelle sans réinitialiser toute la session,
so that reprendre proprement un segment mal engagé sans perdre mon compteur de répétitions global.

## Acceptance Criteria

1. [x] **Action Disponibilité:** Une action "Reset Loop" est disponible uniquement en **Mode Learn**.
2. [x] **Loop Reset Logic:** Au déclenchement, le curseur (`currentIndex`) revient instantanément au début du segment actif (`segmentStart`).
3. [x] **Stats Conservation:** Les statistiques globales de la session (`elapsedTime`, `attempts`, `errors`, `loops`) **ne sont pas** réinitialisées.
4. [x] **Streak Reset:** Le `currentStreak` est remis à zéro.
5. [x] **Feedback:** Un feedback haptique léger (type `selection`) confirme la réinitialisation.
6. [x] **UI Trigger:** L'action est déclenchable via une interaction explicite (ex: Bouton "Replay" discret ou Geste défini) compatible avec le mode Zen.

## Tasks / Subtasks

- [x] **PracticeEngine Logic** (AC: 2, 3, 4)
  - [x] Ajouter `func resetLoop()` dans `PracticeEngine`.
  - [x] Implémentation:
    - [x] `currentIndex = startIndex`
    - [x] `currentStreak = 0`
    - [x] `lastCorrectInputTime = nil`
    - [x] Ne PAS toucher à `attempts`, `errors`, `elapsedTime`.
    - [x] Envoyer un signal/event pour l'UI si nécessaire (ou laisser `@Observable` faire).
  - [x] Test unitaire vérifiant la conservation des stats et le reset de l'index.

- [x] **SessionViewModel Integration** (AC: 1, 5)
  - [x] Exposer `func resetLoop()` dans `SessionViewModel`.
  - [x] Ajouter la garde `guard selectedMode == .learn else { return }`.
  - [x] Déclencher `HapticService.shared.playSelection()` (ou impact léger).
  - [x] Ajouter la méthode au `View` bindable.

- [x] **UI Implementation** (AC: 6)
  - [x] Dans `SessionView` (ou `TerminalGridView` overlay), ajouter le trigger.
  - [x] Bouton de réinitialisation avec localisation.
  - [x] S'assurer que le bouton n'est visible qu'en Mode Learn.

## Dev Notes

### Architecture & Logic Compliance

- **State Management:** Utiliser `@Observable` pour que le changement de `currentIndex` soit immédiatement reflété dans `TerminalGridView`.
- **Logic Isolation:** Toute la logique de manipulation d'index DOIT rester dans `PracticeEngine`. Le ViewModel ne fait que passer la commande.
- **Learn Mode Specifics:**
  - En mode Learn, `startIndex` est défini par le `SegmentStore`. Le reset doit utiliser cette valeur (déjà stockée dans `engine.startIndex`).

### Previous Story Intelligence

- **Context from Story 10.1 & 8.4:**
  - `PracticeEngine` gère déjà des "events" comme `.looped`.
  - Le `TerminalGridView` utilise `currentSegmentOffset` du ViewModel.
  - Assurez-vous que le `TerminalGridView` se rafraîchit correctement (le `drawingGroup()` peut nécessiter un changement d'ID ou de State si l'observation n'est pas directe sur l'index).

### Technical Specifications

- **Engine Method Signature:**
  ```swift
  func resetLoop() {
      // Logic here
  }
  ```
- **Haptics:** Utiliser `HapticService.shared.trigger(.soft)` ou `.rigid` pour différencier du succès/erreur.

### Project Structure Notes

- **File Locations:**
  - Engine: `PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift`
  - ViewModel: `PiTrainer/PiTrainer/SessionViewModel.swift`
  - UI: `PiTrainer/PiTrainer/Features/Practice/SessionView.swift` (à vérifier si le fichier est éclaté)

### References

- [Epic 10: Story 10.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L656)
- [PracticeEngine.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift)

## Dev Agent Record

### Agent Model Used

Claude 3.5 Sonnet (via Antigravity Code Review Fix)

### Debug Log References

N/A

### Completion Notes List

- Implemented `resetLoop()` in `PracticeEngine` to reset progress to segment start without clearing global session stats.
- Added `resetLoop()` to `SessionViewModel` with mode safety and haptic feedback.
- Added localized "Reset Loop" button in `SessionView` (Learn mode only).
- Verified with unit tests, including `elapsedTime` preservation.
- [AI-Review] Fixed state leak in `SessionViewModel.resetLoop()` (indulgentErrorIndices not clearing).
- [AI-Review] Added integration tests for loop reset in `PracticeEngineTests.swift`.
- [AI-Review] Updated File List to include all modified files (Logic and UI components).

### File List

- [PracticeEngine.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift)
- [SessionViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionViewModel.swift)
- [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift)
- [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift)
- [TerminalGridView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift)
- [HapticService.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Haptics/HapticService.swift)
- [StatsStore.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsStore.swift)
- [SettingsView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SettingsView.swift)
- [PracticePersistence.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Persistence/PracticePersistence.swift)
- [Localizable.xcstrings](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Localizable.xcstrings)
- [PracticeEngineTests.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainerTests/PracticeEngineTests.swift)
