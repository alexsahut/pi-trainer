# Story 1.3: Pavé Numérique "Pro-Pad" Immersif

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur rapide,
I want un pavé numérique optimisé avec des feedbacks visuels immédiats,
so that saisir les chiffres sans lever les yeux de la zone de focus.

## Acceptance Criteria

1. **Given** l'écran de pratique active
2. **When** j'appuie sur une touche du pavé numérique
3. **Then** la cible de touche mesure au moins 44x44 points (NFR5)
4. **And** un micro-flash Cyan (#00F2FF) apparaît brièvement sur la touche (60 FPS)
5. **And** le `HapticService` est appelé pour confirmer la touche (Story 1.2 dependency)
6. **And** un réglage permet d'activer/désactiver les haptiques dans les paramètres (FR15)
7. **And** l'opacité du pavé est de 20% par défaut (Ghost Mode baseline)

## Tasks / Subtasks

- [x] Création du composant `ProPadView` (AC: 1, 3, 4)
  - [x] Implémenter la grille 3x4 (0-9, Clear, Option)
  - [x] Configurer les frames 44x44 minimum pour chaque bouton
  - [x] Ajouter l'effet de flash Cyan via un `ButtonStyle` ou `.overlay` animé
- [x] Intégration du `HapticService` (AC: 5)
  - [x] Injecter l'instance du service dans la vue ou le ViewModel
  - [x] Déclencher le feedback "clic sec" lors de la pression
- [x] Gestion des paramètres (AC: 6)
  - [x] Lier le toggle haptique à un state persisté ou aux settings globaux
- [x] Optimisation de la performance (AC: 4)
  - [x] Utiliser `.drawingGroup()` si nécessaire pour maintenir les 60 FPS
  - [x] Vérifier que le rendu ne bloque pas le Main Thread

## Dev Notes

- **Architecture Patterns:**
  - S'inscrit dans `Features/Practice`.
  - Utilisation de `@Observable` pour le state du pavé numérique.
  - Suffixes obligatoires : `ProPadView`, `ProPadViewModel`.
- **Source tree components to touch:**
  - `Features/Practice/ProPadView.swift`
  - `Features/Practice/ProPadViewModel.swift`
  - `Shared/UI/Colors.swift` (pour le Cyan Électrique #00F2FF)
- **Testing standards summary:**
  - Verify touch area size in UI Tests.
  - Performance test for input latency (<16ms).

### Project Structure Notes

- Alignment with `Features/Practice/` module.
- `Core/Haptics/` dependency must be respected.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.3]
- [Source: _bmad-output/planning-artifacts/architecture.md#Frontend Architecture]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Component Strategy]

## Dev Agent Record

### Agent Model Used

Antigravity (Gemini 2.0 Flash)

### Debug Log References

### Completion Notes List
- **2026-01-16**: Completed implementation. Implemented ProPadView, Options Menu, and Haptic Toggle.
- **2026-01-16 (Code Review)**: Fixed logic bug in `HapticService.playSuccess`. Updated File List to reflect all changed files.

### File List
- PiTrainer/PiTrainer/Features/Practice/ProPadView.swift
- PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift
- PiTrainer/PiTrainer/Core/Haptics/HapticService.swift
- PiTrainer/PiTrainer/SessionView.swift
- PiTrainer/PiTrainer/SessionViewModel.swift
- PiTrainer/PiTrainer/Localizable.xcstrings
