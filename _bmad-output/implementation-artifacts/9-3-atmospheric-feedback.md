# Story 9.3: Atmospheric Feedback (Couleurs Dynamiques)

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a gamer,
I want ressentir visuellement si je suis en avance ou en retard,
so that ajuster mon rythme sans regarder des chiffres.

## Acceptance Criteria

1. [ ] **Visual Trigger:** L'effet atmosphérique ne s'active qu'en mode **GAME**.
2. [ ] **Advance State:** Si je suis en **AVANCE** sur le Ghost, le fond se teinte de **CYAN** (#00F2FF).
3. [ ] **Behind State:** Si je suis en **RETARD** sur le Ghost, le fond se teinte d'**ORANGE ÉLECTRIQUE** (#FF6B00).
4. [ ] **Neutral State:** À égalité exacte, le fond reste **NOIR OLED**.
5. [ ] **Dynamic Intensity:** L'opacité de la couleur varie entre **5%** (écart min) et **20%** (écart max de 5 chiffres).
6. [ ] **Fluid Transitions:** Les changements de couleur et d'opacité doivent être fluides (via `TimelineView` ou animation SwiftUI).

## Tasks / Subtasks

- [x] **Technical Alignment** (AC: 2, 3)
  - [x] Confirmer que la logique actuelle dans `SessionViewModel+Game.swift` correspond bien à (Avance=Cyan, Retard=Orange).
- [x] **Logic Refinement** (AC: 5)
  - [x] Valider que `atmosphericOpacity` s'arrête bien à 0% à l'égalité parfaite pour éviter un voile résiduel.
- [x] **Verification & Testing** (AC: 1-6)
  - [x] Créer `AtmosphericFeedbackTests.swift` pour tester la logique de delta et de couleur dans `SessionViewModel`.
  - [x] Vérifier manuellement en Game Mode que le fond change de couleur selon la position relative.
- [x] **Code Review Follow-ups (AI)**
  - [x] [Low] Supprimer les magic numbers dans le calcul d'opacité.
  - [x] [Low] Optimiser `TimelineView` pour ne rafraîchir qu'en mode Game.
  - [x] [Low] Déplacer `SessionViewModel+Game.swift` vers `Core/Features/Practice/`.
  - [x] [Medium] Documenter l'impact sur `StatsStore` et `SegmentStore` pour le fix du Reset.

## Dev Notes

- **Current Implementation:** Une partie de la logique existe déjà dans `SessionViewModel+Game.swift` et est utilisée dans `SessionView.swift` via une `TimelineView`.
- **Discrepancy Detected:** La logique actuelle dans le code est inversée par rapport à la spécification de l'Epic 9. **Priorité 1: Rétablir la conformité.**
- **Performance:** L'utilisation de `TimelineView(.animation)` est déjà en place pour assurer la fluidité sans bloquer le thread principal.

### Project Structure Notes

- **SessionViewModel+Game.swift:** Ce fichier contient la logique métier. Notez qu'il se trouve actuellement à la racine de `PiTrainer/PiTrainer/` (suite à un écart constaté lors de la Story 9.2). Un refactoring vers `Features/Practice/` est suggéré mais non bloquant pour cette story.
- **DesignSystem.swift:** Utiliser `DesignSystem.Colors.cyanElectric` et `DesignSystem.Colors.orangeElectric`.

### References

- [Epic 9: Mode Game (Ghost System & Atmospheric Feedback)](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L493)
- [Architecture V2.3: Horizon Line & Atmospheric Feedback](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L274)
- [Previous Work: Story 9.2 Horizon Line](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/9-2-horizon-line.md)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
- `PiTrainer/PiTrainer/Core/Features/Practice/SessionViewModel+Game.swift` [MODIFY] (Déplacé)
- `PiTrainer/PiTrainer/SessionView.swift` [MODIFY]
- `PiTrainer/PiTrainer/StatsStore.swift` [MODIFY] (Fix Reset bug)
- `PiTrainer/PiTrainer/SegmentStore.swift` [MODIFY] (Fix Reset bug)
- `PiTrainer/PiTrainerTests/AtmosphericFeedbackTests.swift` [NEW]
