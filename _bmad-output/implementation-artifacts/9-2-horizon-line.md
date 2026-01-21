# Story 9.2: Horizon Line (Visualisation de la Course)

**Parent:** Epic 9 - Mode Game (Ghost System & Atmospheric Feedback)
**Status:** done

## User Story

**As a** gamer,
**I want** voir ma position relative par rapport au Ghost sur une ligne d'horizon,
**So that** savoir instantanément si je suis en avance ou en retard.

## Acceptance Criteria

- [x] **Horizon UI:** Une ligne d'horizon discrète (1px) apparaît au-dessus du Terminal-Grid uniquement en mode Game.
- [x] **Dual Points:**
    - [x] Un point blanc représente la position effective du joueur (`correctCount - errorCount`).
    - [x] Un point gris représente la position actuelle du Ghost (interpolée par le `GhostEngine`).
- [x] **Fluid Movement:** Les points se déplacent fluidement sur l'axe horizontal à chaque input ou mise à jour du Ghost.
- [x] **Position Mapping:** La position sur la ligne correspond au ratio `position / totalTargetDigits` (longueur du segment ou de la constante).

## Technical Context

### 1. Developer Guardrails
- **File Location:** Create `HorizonLineView.swift` in `PiTrainer/PiTrainer/Features/Practice/`.
- **ViewModel Extension:** Create `SessionViewModel+Game.swift` for the physics/math logic to avoid bloating the main `SessionViewModel`.
- **Performance:** Ensure no timers are used; the View should react to `@Published` changes or use `TimelineView` if necessary for the Ghost's continuous movement.

### 2. Architectural Compliance (from architecture.md)
- **playerEffectivePosition:** `engine.correctCount - engine.errorCount`
- **ghostPosition:** `ghostEngine?.ghostPosition ?? 0`
- **mapping:** `CGFloat(position) / CGFloat(max(totalTarget, 1)) * width`

### 3. Previous Story Intelligence (Story 9.1)
- `GhostEngine` is already implemented and accessible via `SessionViewModel`.
- `PersonalBestRecord` already contains `cumulativeTimes`.
- Mode isolation is enforced in `SessionViewModel`.

## Dev Agent Record

### File List
- `PiTrainer/PiTrainer/Features/Practice/HorizonLineView.swift` [NEW]
- `PiTrainer/PiTrainer/Features/Practice/SessionViewModel+Game.swift` [NEW]
- `PiTrainer/PiTrainer/SessionView.swift` [MODIFY]
- `PiTrainer/PiTrainer/SessionViewModel.swift` [MODIFY]

### Change Log
- **2026-01-20:** Created story definition for Horizon Line visualization.
- **2026-01-20:** Implemented `HorizonLineView` and integrated it into `SessionView`.
- **2026-01-20:** Added mathematical logic in `SessionViewModel+Game.swift`.
- **2026-01-20:** Refactored `SessionViewModel` to support PB provider injection for stability.
