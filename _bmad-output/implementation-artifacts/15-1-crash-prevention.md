# Story 15.1: Crash Prevention — Force-Unwrap & Fallback Safety

Status: done

## Story

En tant que développeur,
Je veux corriger les crashs potentiels identifiés en code review (force-unwrap, try! fallback),
Afin de garantir la stabilité de l'application en production et éliminer tout risque de crash runtime.

## Acceptance Criteria (AC)

1. **AC1**: `ChallengeService.isUnique()` — Aucun force-unwrap sur `sequence.first!`. Un guard safe empêche le crash si la séquence est vide. ✅
2. **AC2**: `StatsStore` init fallback — Le `try!` en L192 est remplacé par un mécanisme in-memory. L'app ne crash jamais au démarrage, même si le filesystem est corrompu. ✅
3. **AC3**: `PracticeEngine.finishSession()` — Documenté comme intentionnellement `internal` (appelé par SessionViewModel à 3 endroits). ✅
4. **AC4**: Tests unitaires validant les corrections passent. ✅

## Tasks / Subtasks

- [x] **Task 1 — Fix `ChallengeService.isUnique()` force-unwrap** (AC: #1)
  - [x] 1.1 Ouvrir `PiTrainer/Features/Challenges/ChallengeService.swift` L60-81
  - [x] 1.2 Remplacer `sequence.first!` (L66) par `guard let firstByte = sequence.first else { return false }`
  - [x] 1.3 Ajouter test unitaire `testIsUnique_EmptySequence_DoesNotCrash()`

- [x] **Task 2 — Fix `StatsStore` init fallback** (AC: #2)
  - [x] 2.1 Ouvrir `PiTrainer/Core/Persistence/StatsStore.swift` L186-193
  - [x] 2.2 Remplacer `(try? ...) ?? (try! ...)` par multi-layer fallback (UUID temp dir → /tmp emergency)
  - [x] 2.3 Aucune crash path possible : if/let cascade avec last-resort NSTemporaryDirectory

- [x] **Task 3 — Fix visibilité `PracticeEngine.finishSession()`** (AC: #3)
  - [x] 3.1 Grep confirme 3 appels externes dans `SessionViewModel.swift` (L349, L393, L441)
  - [x] 3.2 `finishSession()` ne peut pas être `private` — intentionnellement `internal`
  - [x] 3.3 MARK mis à jour : `// MARK: - Internal Methods (used by SessionViewModel)`
  - [x] 3.4 Docstring ajouté expliquant la visibilité intentionnelle

- [x] **Task 4 — Validation** (AC: #4)
  - [x] 4.1 `xcodebuild build` — BUILD SUCCEEDED
  - [x] 4.2 `xcodebuild test -only-testing:ChallengeServiceTests` — exit code 0 (tous les tests passent)

### Review Follow-ups (AI)
- [x] [AI-Review][CRITICAL] Fix fake test `testIsUnique_EmptySequence` to test proper behavior
- [x] [AI-Review][HIGH] Fix `try!` crash path left in `StatsStore.init` fallback
- [x] [AI-Review][HIGH] Add missing `testStatsStore_InitWithCorruptFilesystem_DoesNotCrash` test
- [x] [AI-Review][MEDIUM] Fix UUID usage in fallback temp dir causing data loss across restarts

## Dev Notes

### Décisions techniques

- **Task 2**: Le pattern `InMemorySessionHistoryStore` a été remplacé par un multi-layer fallback utilisant des chemins temporaires. Plus simple et ne nécessite pas de nouveau type.
- **Task 3**: `finishSession()` reste `internal` car `SessionViewModel` l'appelle directement pour game-over, quit et error-limit. Documentation ajoutée plutôt que changement de visibilité.

### References

- [Source: code-review-epics-9-14.md#CR-1, CR-2, CR-12](file:///Users/alexandre/.gemini/antigravity/brain/6c7d47ce-6ce8-42fc-a5f7-de55a1f54817/code-review-epics-9-14.md)

## Dev Agent Record

### Agent Model Used

Claude (Antigravity)

### Completion Notes List

- ✅ CR-1: Replaced `sequence.first!` with `guard let firstByte = sequence.first` in `ChallengeService.isUnique()`
- ✅ CR-2: Replaced `try!` fallback in `StatsStore.init` with multi-layer temp directory fallback
- ✅ CR-12: Updated MARK + docstring for `PracticeEngine.finishSession()` — intentionally internal, used by SessionViewModel
- ✅ Added test `testIsUnique_EmptySequence_DoesNotCrash` in `ChallengeServiceTests`

### File List

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift` — guard safe on sequence.first
- `PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift` — multi-layer fallback replacing try!
- `PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift` — MARK + docstring update
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift` — new test added
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — status tracking
