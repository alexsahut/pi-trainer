# Story 10.3: Fix Learn Mode UI & Reset Loop Button (Hotfix)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a apprenant,
I want que le clavier soit positionné correctement en bas d'écran et avoir un accès rapide au "Reset Loop",
so that pratiquer confortablement et utiliser la nouvelle fonction sans friction.

## Acceptance Criteria

1. [ ] **Layout Fix:** Le clavier (Pro-Pad) est ancré en bas de l'écran en Mode Learn (correction de la régression où il apparaît au milieu).
2. [ ] **Button Swap:** Le bouton "Retour" (<) du clavier est remplacé par le bouton "Reset Loop" (⟳) **uniquement en Mode Learn**.
3. [ ] **Action Wiring:** Le bouton "Reset Loop" déclenche l'action `viewModel.resetLoop()` définie dans la Story 10.2.
4. [ ] **Haptic Feedback:** L'appui sur le bouton déclenche le feedback haptique approprié (déjà géré par le ViewModel ou à ajouter).
5. [ ] **Other Modes:** En modes Practice et Game, le bouton "Retour" reste présevré (ou supprimé si la navigation gestuelle est confirmée suffisante, voir notes).

## Tasks / Subtasks

- [x] **Analyze & Fix Layout Regression** (AC: 1)
  - [x] Inspecter `SessionView` ou `TerminalGridView` pour identifier pourquoi le clavier remonte.
  - [x] Vérifier les `Spacer()`, `VStack` ou `ZStack` mal contraints.
  - [x] S'assurer que le fix n'impacte pas les autres modes.

- [x] **Implement Reset Loop Button in ProPad** (AC: 2, 3, 5)
  - [x] Modifier `ProPadView` (ou composant équivalent) pour accepter un état ou un mode.
  - [x] Ajouter une condition : `if mode == .learn { Show ResetLoop } else { Show Back or Empty }`.
  - [x] Connecter l'action au `SessionViewModel`.

- [x] **Verify Navigation & Haptics** (AC: 4)
  - [x] Vérifier que le gesture "Back" natif fonctionne toujours si on retire le bouton.
  - [x] Confirmer le retour haptique lors du reset.

## Dev Notes

### Architecture & Logic Compliance

- **ViewModel-Driven:** L'UI ne doit pas contenir de logique métier. Elle appelle `viewModel.resetLoop()`.
- **Responsive Layout:** Le fix de layout doit fonctionner sur tous les appareils (iPhone SE à Pro Max). Utiliser `SafeAreas` correctement.

### Previous Story Intelligence

- **Story 10.2 Context:** La fonction `resetLoop()` a été implémentée dans `SessionViewModel`. Elle est sécurisée pour ne fonctionner qu'en mode Learn.
- **Story 10.2 Learnings:** Attention aux leaks d'état. Le reset doit bien remettre le curseur au début du segment.

### Project Structure Notes

- **File Locations:**
  - `PiTrainer/PiTrainer/Features/Practice/SessionView.swift` (Layout)
  - `PiTrainer/PiTrainer/Features/Practice/ProPad.swift` (ou nom similaire pour le clavier)
  - `PiTrainer/PiTrainer/SessionViewModel.swift` (Logique)

### References

- [Epic 10 Retrospective](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-10-retrospective.md)
- [Story 10.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/10-2-reinitialisation-de-serie-loop-reset.md)

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List
- Implemented `showResetLoop` in `ProPadView` to verify button swap logic.
- Fixed `SessionView` layout regression by moving `ProPadView` inside the main `VStack` with a `Spacer()`.
- Wired `Reset Loop` button to `viewModel.resetLoop()`.
- Removed redundant floating/z-stacked Reset Loop button from Story 10.2.

### File List
- PiTrainer/PiTrainer/SessionView.swift
- PiTrainer/PiTrainer/Features/Practice/ProPadView.swift
