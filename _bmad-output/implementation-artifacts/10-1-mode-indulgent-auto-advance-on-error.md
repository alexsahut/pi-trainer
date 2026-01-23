# Story 10.1: Mode Indulgent (Auto-Advance on Error)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur rapide,
I want que mes erreurs soient comptabilisées mais ne bloquent pas ma saisie,
so that conserver mon rythme (flow) et ne pas être frustré par une "cascade" d'erreurs.

## Acceptance Criteria

1. [ ] **Auto-Advance Setting:** Une option "Mode Indulgent" (Auto-Advance) est disponible dans les réglages et persistée (Défaut: Off).
2. [ ] **Flow Preservation:** En cas d'erreur avec l'option activée, le curseur avance automatiquement au chiffre suivant (comme une réussite).
3. [ ] **Error Marking:** Le chiffre incorrect est marqué visuellement (ex: Rouge) dans le `TerminalGridView` pour signaler la faute de manière permanente sur la session.
4. [ ] **Mode Compatibility:** Ce mode est disponible en **Practice** et **Game**.
5. [ ] **Game Mode Penalty:** En mode Game, chaque erreur auto-avancée applique la pénalité standard (-1 sur position effective).
6. [ ] **Strict Mode Exclusion:** Cette option est ignorée en mode Strict (l'erreur reste fatale).

## Tasks / Subtasks

- [ ] **Settings & State Management** (AC: 1)
  - [ ] Ajouter `isAutoAdvanceEnabled` dans `UserDefaults` et `SettingsView` (si existante) ou via un toggle temporaire.
  - [ ] Exposer cette configuration au `PracticeEngine`.

- [ ] **PracticeEngine Logic Update** (AC: 2, 4, 6)
  - [ ] Modifier `PracticeEngine.input()` pour gérer le cas "Auto-Advance".
  - [ ] Si `isIndulgent` est vrai et `mode != .strict`:
    - Incrémenter `errorCount`.
    - Avancer l'index (`nextExpectedIndex += 1`).
    - Retourner un résultat `.error(fatal: false, advanced: true)`.

- [ ] **UI Rendering - Error Visualization** (AC: 3)
  - [ ] Mettre à jour `TerminalGridView` pour supporter l'affichage des erreurs passées.
  - [ ] Actuellement, le grid affiche probablement uniquement les chiffres corrects (Vert/Cyan). Il doit maintenant pouvoir afficher un chiffre en Rouge à un index passé.
  - [ ] Adapter le struct `TypedDigit` ou équivalent pour stocker l'état `isError`.

- [ ] **Game Mode Integration** (AC: 5)
  - [ ] Vérifier que la pénalité de position effective (Story 9.4) s'applique correctement : `correctCount` n'augmente pas, `errorCount` augmente, donc `effectivePosition` diminue.

## Dev Notes

### Architecture & Logic Compliance

- **Engine Isolation:** La logique d'avancement doit être encapsulée dans `PracticeEngine`.
- **Game Mode Conflict:** Le comportement par défaut du Game Mode (Story 9.4) est "Pause on Error". L'option "Mode Indulgent" surcharge ce comportement.
- **Rendering Performance:** L'affichage des erreurs (Rouge) dans le `TerminalGridView` doit rester performant (`.drawingGroup()`).
- **Strict Mode:** Ce mode doit rester impitoyable. L'option `isAutoAdvanceEnabled` doit être ignorée ou désactivée visiblement si le mode Strict est sélectionné.

### Previous Story Intelligence (Story 9.4)

- **Learnings:**
  - Story 9.4 a introduit la gestion des erreurs non-fatales (`InputResult.error(fatal: false)`).
  - Le `TerminalGridView` a été modifié pour afficher le chiffre attendu (Ghost Reveal).
  - **Attention:** `TerminalGridView` assume peut-être que tous les chiffres "validés" (à gauche du curseur) sont corrects. Il faudra probablement modifier le modèle de données de la vue pour accepter des "erreurs validées".

- **Files to Touch:**
  - `PiTrainer/PiTrainer/Core/Engine/PracticeEngine.swift`
  - `PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift` (et son ViewModel/State)
  - `PiTrainer/PiTrainer/Shared/Models/Settings.swift` (ou équivalent)

### Technical Specifications

- **InputResult Enum:** Étendre l'enum pour inclure le cas `advanced: Bool`.
  ```swift
  enum InputResult {
      case correct
      case error(fatal: Bool, revealCorrect: Bool, advanced: Bool) // advanced = true en Mode Indulgent
  }
  ```
- **Visual State:** Rouge profond (`Color.red`) pour les erreurs auto-avancées, distinct du Cyan/Blanc des réussites.

### Project Structure Notes

- **Settings:** Si `SettingsStore` n'existe pas, l'ajouter dans `Core/Persistence` ou utiliser `AppStorage` dans `Features/Home`.
- **Colors:** Utiliser les couleurs sémantiques définies dans le Design System.

### References

- [Epic 10: Story 10.1](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L642)
- [Story 9.4 Implementation](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/9-4-game-mode-error-handling.md)
- [PRD Requirement FR15](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/prd.md#L168)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Implemented `isAutoAdvanceEnabled` in `PracticePersistence` and `StatsStore`.
- Updated `SettingsView` to toggle Indulgent Mode.
- Modified `PracticeEngine` to support non-fatal auto-advance.
- Updated `TerminalGridView` to visually indicate indulged errors.
- Verified Strict Mode exclusion and Game Mode integration.
- Added localization for new settings.
- **Fixes applied during review:** Wired `isAutoAdvanceEnabled` to `SessionViewModel`, fixed `SettingsTests`, added missing localizations.

### File List

- PiTrainer/PiTrainer/Core/Persistence/PracticePersistence.swift
- PiTrainer/PiTrainer/SettingsView.swift
- PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift
- PiTrainer/PiTrainer/SessionViewModel.swift
- PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift
- PiTrainer/PiTrainer/Localizable.xcstrings
- PiTrainer/PiTrainerTests/PracticeEngineIndulgentTests.swift
- PiTrainer/PiTrainerTests/SettingsTests.swift
- PiTrainer/PiTrainer/StatsStore.swift


