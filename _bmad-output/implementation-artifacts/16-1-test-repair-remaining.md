# Story 16.1: Réparation des Tests Restants — Failures Hors-Scope

Status: done

## Story

En tant que développeur,
Je veux corriger ou supprimer les ~10 tests encore en échec (hors-scope des Epics 15),
Afin que `xcodebuild test -only-testing:PiTrainerTests` passe à 0 failures et que le merge vers `main` soit validable en confiance.

## Acceptance Criteria (AC)

1. **AC1 — PersonalBestStoreTests** : `testSave_LightningPR_UnderThreshold_Ignored` corrigé — le seuil du test est aligné avec le code source (`digitCount >= 10`). Le test utilise un `digitCount < 10` pour vérifier le rejet.

2. **AC2 — PositionTrackerTests** : `testPositionTracker_IncrementsOnIncorrectDigit_LearningMode` corrigé — le test reflète le comportement réel du Learning mode : l'index ne s'incrémente PAS sur une erreur (retry sur place).

3. **AC3 — ProPadViewModelTests** : Les 5 tests d'opacité Ghost Mode sont supprimés (feature supprimée Story 9.2 : `targetOpacity` hardcodé à `1.0`). Les 2 tests fonctionnels restants (`testDigitPressTriggersCallback`, `testActionPressTriggersCallback`) et le test haptics continuent de passer.

4. **AC4 — SessionViewModelIntegrationTests** : Les tests de certification Game Mode (`testCertificationFailsWithOneError_GameMode`, `testCertificationSucceedsWithSuddenDeath_GameMode`) sont corrigés ou supprimés selon le comportement actuel. Le test `testGhostSelectionFallbacksToLightning` est vérifié (peut déjà passer avec le code actuel).

5. **AC5 — 0 régressions** : `xcodebuild test -only-testing:PiTrainerTests` passe à 0 failures sur iPhone 17 Pro / iOS 26.2.

6. **AC6 — Dev Agent Record Story 15.3** : Le Dev Agent Record de la Story 15.3 est complété (model, completion notes, file list) — Action Item retro Epic 15 #1.

## Tasks / Subtasks

- [x] **Task 1 — PersonalBestStoreTests** (AC: #1)
  - [x] 1.1 Lire `PiTrainerTests/PersonalBestStoreTests.swift`
  - [x] 1.2 Confirmer seuil Lightning (`digitCount >= 10`) dans PersonalBestStore.swift
  - [x] 1.3 Corriger `testSave_LightningPR_UnderThreshold_Ignored` : `digitCount = 5` (< 10)
  - [x] 1.4 Corriger `testSave_LightningPR_ExactlyThreshold_Saves` : boundary aligné sur `digitCount = 10`
  - [x] 1.5 10/10 tests passent

- [x] **Task 2 — PositionTrackerTests** (AC: #2)
  - [x] 2.1 Lire `PiTrainerTests/PositionTrackerTests.swift`
  - [x] 2.2 Confirmer learning mode: `indexAdvanced = false` sur erreur (PracticeEngine.swift:303-305)
  - [x] 2.3 Renommer et corriger test: `DoesNotIncrementOnIncorrectDigit_LearningMode`, assert `currentIndex == 0`
  - [x] 2.4 Fix `testPositionTracker_ResetOnSessionRestart` : digits 1,2 → 1,4 (Pi sequence)
  - [x] 2.5 6/6 tests passent

- [x] **Task 3 — ProPadViewModelTests** (AC: #3)
  - [x] 3.1 Identifier 6 tests ghost mode obsolètes
  - [x] 3.2 Confirmer `targetOpacity` hardcodé `1.0` (Story 9.2)
  - [x] 3.3 Supprimer 6 tests obsolètes : `testOpacityBaselineIs20Percent`, `testOpacityDropsTo5PercentWhenStreak20`, `testOpacityResetsWhenStreakFallsBelow20`, `testOpacityReturnsTo20PercentAfterInactivity`, `testInactivityTimerResetsOnNewInput`, `testPracticeEngineIntegration`
  - [x] 3.4 3 tests fonctionnels restants passent

- [x] **Task 4 — SessionViewModelIntegrationTests** (AC: #4)
  - [x] 4.1 Analyser les 5 tests et le code source SessionViewModel
  - [x] 4.2 `testCertificationFailsWithOneError_GameMode` → Renommé `testCertificationWithOneError_GameMode_IsCertified`, assertion corrigée (game mode certifie avec erreurs via Story 9.6 firstErrorSnapshot)
  - [x] 4.3 `testCertificationSucceedsWithSuddenDeath_GameMode` → Supprimé (Sudden Death supprimé Story 9.5, line 359)
  - [x] 4.4 `testCertificationSucceedsWithZeroErrors_GameMode` → Fix titre "NEW RECORD" → "NEW RECORD!"
  - [x] 4.5 `testGhostSelectionFallbacksToLightning` → Passe (fallback Crown→Lightning existe)
  - [x] 4.6 4/4 tests passent (1 supprimé)

- [x] **Task 5 — Compléter Dev Agent Record Story 15.3** (AC: #6)
  - [x] 5.1 Ouvert `15-3-ui-ux-fixes.md`
  - [x] 5.2 Rempli : Agent Model, Completion Notes, File List

- [x] **Task 6 — Validation Finale** (AC: #5)
  - [x] 6.1 `xcodebuild test -only-testing:PiTrainerTests` sur iPhone 17 Pro / iOS 26.2
  - [x] 6.2 **74 tests, 0 failures, 0 régressions** (le `TEST FAILED` est causé par FBSOpenApplicationServiceErrorDomain — bug simulateur Xcode 16/iOS 26.2, pas lié aux tests)
  - [x] 6.3 Aucun XCTSkip requis

## Dev Notes

### Causes racines détaillées

**PersonalBestStoreTests** — `PersonalBestStore.swift` utilise `digitCount >= 10` comme seuil minimum pour les Lightning PR. Le test `testSave_LightningPR_UnderThreshold_Ignored` envoie 40 digits (>= 10, donc accepté) et assert `nil` → failure. Fix : envoyer `digitCount < 10`.

**PositionTrackerTests** — `PracticeEngine.swift` en mode `.learning` ne fait PAS avancer `currentIndex` sur une erreur (l'utilisateur retente le même digit). Le test attend `currentIndex == 1` après un mauvais input, mais le moteur reste à `currentIndex == 0`.

**ProPadViewModelTests** — La Story 9.2 a hardcodé `targetOpacity` à `1.0` ("Keep ProPad opaque in all V2 modes"). Les 5 tests d'opacité testent un Ghost Mode qui n'existe plus. Suppression requise (feature supprimée, pas juste désactivée).

**SessionViewModelIntegrationTests** — Tests de certification complexes avec des dépendances sur `ghostEngine` timing et `sessionEndStatus`. La logique de certification a évolué entre les Epics 9-14. Les mocks utilisent `SVM_MockPersistence` et `SVM_MockDigitsProvider` définis inline.

### Architecture et contraintes

- **Xcode 16 Synchronized Groups** : La suppression de tests Swift ne nécessite pas de modification `.pbxproj`.
- **`@MainActor`** : `SessionViewModel` et ses tests sont `@MainActor`. Les assertions async utilisent `XCTestExpectation` + `fulfillment(of:timeout:)`.
- **Mocks partagés** : `PracticeEngineTests.swift` définit `MockDigitsProvider` et `EngineMockPersistence` utilisés par `PositionTrackerTests`. Ne pas les supprimer.
- **Parallel testing** : Utiliser `-parallel-testing-enabled NO` pour éviter les flaky `FBSOpenApplicationServiceErrorDomain` (retro Epic 15).

### Stratégie de fix

**Priorité : Fix first, delete if feature removed.**
- PersonalBestStoreTests → Fix test (seuil)
- PositionTrackerTests → Fix test (assertion)
- ProPadViewModelTests → Delete tests obsolètes (feature supprimée)
- SessionViewModelIntegrationTests → Fix ou XCTSkip si timing-dependent

### Project Structure Notes

- Tous les test files sont dans `PiTrainer/PiTrainerTests/` (Xcode 16 synced)
- Les UI tests sont dans `PiTrainer/PiTrainerUITests/` (hors-scope cette story)
- Pattern de commit : `fix(story-16.1): Test Repair — <description>`

### References

- [Source: epic-15-retrospective.md#Action-Items](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-15-retrospective.md)
- [Source: epic-16-release-stabilisation.md#Story-16.1](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-16-release-stabilisation.md)
- [Source: 15-5-polish-technique.md#Debug-Log](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/15-5-polish-technique.md) — "10 failures pré-existantes"
- [Source: PersonalBestStore.swift — Lightning threshold `digitCount >= 10`]
- [Source: PracticeEngine.swift — Learning mode `indexAdvanced = false` on error]
- [Source: ProPadViewModel.swift — `targetOpacity` hardcoded `1.0` (Story 9.2)]

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.6 (claude-sonnet-4-6)

### Debug Log References

- Test run: 74 tests, 0 failures on iPhone 17 Pro / iOS 26.2
- `TEST FAILED` status caused by FBSOpenApplicationServiceErrorDomain (Xcode 16 simulator bug, not test failure)

### Completion Notes List

- Task 1: PersonalBestStoreTests — Fixed `UnderThreshold_Ignored` (digitCount 40→5) and `ExactlyThreshold_Saves` (digitCount 50→10) to align with source threshold `>= 10`
- Task 2: PositionTrackerTests — Renamed/fixed `IncrementsOnIncorrectDigit_LearningMode` → `DoesNotIncrementOnIncorrectDigit_LearningMode` (assert index==0). Fixed `ResetOnSessionRestart` (wrong Pi digit: 2→4)
- Task 3: ProPadViewModelTests — Deleted 6 obsolete Ghost Mode opacity tests (feature removed Story 9.2, `targetOpacity` hardcoded 1.0). Kept 3 functional tests.
- Task 4: SessionViewModelIntegrationTests — Deleted `SuddenDeath` test (feature removed Story 9.5). Fixed `OneError` test (game mode certifies with errors via Story 9.6). Fixed `ZeroErrors` title string "NEW RECORD"→"NEW RECORD!". Ghost fallback test passes.
- Task 5: Completed Dev Agent Record for Story 15.3
- Task 6: Validated 74 tests, 0 failures

### File List

- `PiTrainer/PiTrainerTests/PersonalBestStoreTests.swift` — Fixed threshold values
- `PiTrainer/PiTrainerTests/PositionTrackerTests.swift` — Fixed learning mode assertion + reset test digits
- `PiTrainer/PiTrainerTests/ProPadViewModelTests.swift` — Removed 6 obsolete ghost mode tests
- `PiTrainer/PiTrainerTests/SessionViewModelIntegrationTests.swift` — Deleted 1 test, fixed 2 tests, updated 1 comment
- `_bmad-output/implementation-artifacts/15-3-ui-ux-fixes.md` — Completed Dev Agent Record
