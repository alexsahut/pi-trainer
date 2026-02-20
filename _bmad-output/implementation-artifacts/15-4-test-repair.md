# Story 15.4: Réparation des Tests Unitaires & UI

Status: ready-for-dev

## Story

En tant que développeur,
Je veux que la suite de tests passe à 100%,
Afin de pouvoir valider les futures modifications en confiance.

## Contexte

Le run complet du 2026-02-20 montre **10 tests échoués** (réduit de 24 grâce aux fixes des Stories 15.1–15.3).

## Tests Échoués (Actuel)

| # | Suite | Test | Type |
|:---:|:---|:---|:---:|
| 1 | PositionTrackerTests | `testPositionTracker_TracksMultipleDigits` | Unit |
| 2 | StatsStoreTests | `testDoubleBangTriggerConditions` | Unit |
| 3 | PracticeEngineLoopResetTests | `testResetLoop_ResetsIndexAndStreak_ButKeepsGlobalStats` | Unit |
| 4 | PracticeEngineTests | `testPersistence_SavedOnCorrectInput` | Unit |
| 5 | SessionViewModelLoopResetTests | `testResetLoop_ResetsViewModelState` | Unit |
| 6 | HorizonLineTests | `testPlayerEffectivePosition` | Unit |
| 7 | HorizonLineTests | `testProgressRatios` | Unit |
| 8 | KeypadInteractionTests | `testBackspaceRemovesLastDigit` | UI |
| 9 | KeypadInteractionTests | `testKeypadButtonsExistAndAreHittable` | UI |
| 10 | RegressionTests | `testFirstDigitVisibility` | UI |

## Acceptance Criteria (AC)

1. **AC1**: Les 7 tests unitaires échoués (#1-#7) sont corrigés ou explicitement supprimés (si obsolètes).
2. **AC2**: Les 3 tests UI échoués (#8-#10) sont corrigés ou marqués `@disabled` avec justification.
3. **AC3**: `xcodebuild test` passe avec 0 failures sur iPhone 17 Pro / iOS 26.2.
4. **AC4**: Aucune régression sur les tests qui passent actuellement.

## Tasks / Subtasks

- [ ] **Task 1 — Diagnostic des causes racines** (AC: #1, #2)
  - [ ] 1.1 Analyser chaque test échoué : lire le test, comprendre l'assertion, identifier le delta avec le code actuel
  - [ ] 1.2 Classifier en : `fix` (test désynchronisé) vs `delete` (test obsolète)

- [ ] **Task 2 — Fix des tests unitaires** (AC: #1)
  - [ ] 2.1 PositionTrackerTests — API changée
  - [ ] 2.2 StatsStoreTests — DoubleBang trigger conditions modifiées
  - [ ] 2.3 PracticeEngineLoopResetTests — Reset state
  - [ ] 2.4 PracticeEngineTests — Persistence mock
  - [ ] 2.5 SessionViewModelLoopResetTests — LoopReset state
  - [ ] 2.6 HorizonLineTests (×2) — effectivePosition + progressRatios API

- [ ] **Task 3 — Fix des tests UI** (AC: #2)
  - [ ] 3.1 KeypadInteractionTests (×2) — Buttons identification
  - [ ] 3.2 RegressionTests — First digit visibility

- [ ] **Task 4 — Validation Finale** (AC: #3, #4)
  - [ ] 4.1 `xcodebuild test` — 0 failures
  - [ ] 4.2 Vérifier aucune régression sur tests existants

## Dev Notes

### Stratégie

- **Fix first, delete if obsolete.** On ne supprime un test que s'il teste une feature qui n'existe plus.
- **Tests UI :** Souvent fragiles à cause des accessibility identifiers et des timings. Considérer `@disabled` si l'effort de maintenance dépasse la valeur du test.
- **Priorité :** Tests unitaires d'abord (rapides à diagnostiquer), puis UI tests.

### References

- [Source: epic-15-consolidation.md#Story-15.4](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-15-consolidation.md)

## Dev Agent Record

### Agent Model Used

### Completion Notes List

### File List
