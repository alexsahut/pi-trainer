# Story 9.1: GhostEngine & PersonalBest avec Timestamps

**Parent:** Epic 9 - Mode Game (Ghost System & Atmospheric Feedback)
**Status:** ready-for-dev

## User Story

**As a** gamer,
**I want** courir contre ma meilleure performance passée,
**So that** me dépasser progressivement.

## Acceptance Criteria

- [ ] **Data Loading:** Le système charge le Personal Best (PR) pour la constante sélectionnée au lancement de la session.
- [ ] **Ghost Initialization:**
    - [ ] Si PR existe: `GhostEngine` est initialisé avec les timestamps cumulés.
    - [ ] Si PR n'existe pas: Le Ghost reste à la position 0 (premier essai).
- [ ] **Ghost Movement:** Le Ghost "avance" virtuellement en fonction du temp écoulé comparé aux timestamps du PR.
- [ ] **Timestamps Recording (Story 9.5 pre-req):** Prévoir la structure de données pour enregistrer les temps.

## Technical Notes

### 1. Data Structures (`Shared/Models`)
- Update `PersonalBestRecord` struct:
    ```swift
    struct PersonalBestRecord: Codable, Equatable {
        let constant: Constant
        let digitCount: Int
        let totalTime: TimeInterval
        let cumulativeTimes: [TimeInterval] // New: Timestamps relative to start
        let date: Date
    }
    ```

### 2. Core Engine (`Core/Engine/GhostEngine.swift`)
- Create `GhostEngine` class (actors or plain class, thread-safety to consider with `PracticeEngine`? Likely `MainActor` or shared actor).
    ```swift
    @Observable
    final class GhostEngine {
        private let timestamps: [TimeInterval]
        private let startTime: Date

        var ghostPosition: Int {
             // Binary search or index tracking (timestamps are sorted) to find current position
        }
    }
    ```

### 3. Persistence (`Core/Persistence/PersonalBestStore.swift`)
- Create store to handle loading/saving `PersonalBestRecord`.
- Should act as the source of truth for the `GhostEngine`.
