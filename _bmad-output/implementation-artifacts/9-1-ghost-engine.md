# Story 9.1: GhostEngine & PersonalBest avec Timestamps

**Parent:** Epic 9 - Mode Game (Ghost System & Atmospheric Feedback)
**Status:** done

## User Story

**As a** gamer,
**I want** courir contre ma meilleure performance passée,
**So that** me dépasser progressivement.

## Acceptance Criteria

- [x] **Data Loading:** Le système charge le Personal Best (PR) pour la constante sélectionnée au lancement de la session.
- [x] **Ghost Initialization:**
    - [x] Si PR existe: `GhostEngine` est initialisé avec les timestamps cumulés.
    - [x] Si PR n'existe pas: Le Ghost reste à la position 0 (premier essai).
- [x] **Ghost Movement:** Le Ghost "avance" virtuellement en fonction du temp écoulé comparé aux timestamps du PR.
- [x] **Timestamps Recording (Story 9.5 pre-req):** Prévoir la structure de données pour enregistrer les temps.

## Technical Notes

### 1. Data Structures (`Shared/Models`)
- `PersonalBestRecord` struct updated to include `cumulativeTimes`.

### 2. Core Engine (`Core/Engine/GhostEngine.swift`)
- `GhostEngine` implemented with `start()` signal and precision timing.
- Strictly isolated: only initialized if `SessionMode.hasGhost` is true.

### 3. Persistence (`Core/Persistence/PersonalBestStore.swift`)
- `PersonalBestStore` implemented with lazy loading for performance.

## Senior Developer Review (AI)

### findings
- **🔴 HIGH:** Originally missing integration in `SessionViewModel`. **FIXED.**
- **🟡 MEDIUM:** Originally missing manual start signal (Ghost started too early). **FIXED.**
- **🟡 MEDIUM:** Originally missing mode isolation. **FIXED.**
- **🟢 LOW:** Originally eager loading all records. **FIXED.**

## Dev Agent Record

### File List
- `PiTrainer/PiTrainer/Shared/Models/PersonalBestRecord.swift`
- `PiTrainer/PiTrainer/Core/Engine/GhostEngine.swift`
- `PiTrainer/PiTrainer/Core/Persistence/PersonalBestStore.swift`
- `PiTrainer/PiTrainer/SessionViewModel.swift` (Modified)
- `PiTrainer/PiTrainerTests/GhostEngineTests.swift`

### Change Log
- **2026-01-20:** Created core models and engines for Story 9.1.
- **2026-01-20:** Refactored for precision timing, mode isolation, and lazy loading after adversarial review.
