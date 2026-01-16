# Story 3.3: Implémentation du Mode Strict

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a compétiteur,  
I want que ma session s'arrête immédiatement à la moindre erreur,  
so that valider une mémorisation parfaite.

## Acceptance Criteria

1. **Given** une session en mode Strict active
   **When** je saisis un chiffre incorrect
   **Then** la session se termine instantanément
   **And** l'écran de fin s'affiche avec le score et la vitesse moyenne
   **And** un feedback d'erreur agressif (Shake + Vibration double) est déclenché.

## Tasks / Subtasks

- [x] Implémenter la logique du Mode Strict dans `PracticeEngine` (AC: 1)
  - [x] Ajouter une propriété `isStrictMode` dans la configuration/état du moteur
  - [x] Modifier la logique de validation pour arrêter la session immédiatement sur erreur quand `isStrictMode` est actif
- [x] Mettre à jour `SessionViewModel` pour gérer la terminaison immédiate (AC: 1)
  - [x] Gérer l'état de fin de partie via `@Observable`
  - [x] Déclencher la navigation vers le `SummaryView` (ou équivalent)
- [x] Implémenter le Feedback "Agressif" (AC: 1)
  - [x] S'assurer que `HapticService` joue la vibration d'erreur "lourde"
  - [x] Ajouter une animation visuelle (Shake) sur le `TerminalGridView` ou le conteneur principal
- [x] Ajouter des Tests Unitaires pour le Mode Strict
  - [x] Vérifier que `PracticeEngine` passe en état `.finished` (ou `.failed`) dès la première erreur

## Dev Notes

- **Architecture Patterns**:
  - Utiliser `PracticeEngine` comme source de vérité pour l'état de la session.
  - Le Mode Strict est une variante de la logique de validation, pas un mode d'interface séparé.
  - L'animation "Shake" doit être fluide (60 FPS) et ne pas bloquer le thread de validation.

- **Source Tree Components**:
  - `Core/Engine/PracticeEngine.swift`: Logique métier.
  - `Features/Practice/SessionViewModel.swift`: Gestion de l'état UI.
  - `Features/Practice/SessionView.swift`: Feedback visuel (Shake).
  - `Core/Haptics/HapticService.swift`: Feedback haptique.

- **Testing Standards**:
  - Unit Tests: Couverture complète des cas d'arrêt en mode strict.
  - UI Tests: Vérifier la navigation vers l'écran de fin.

### Project Structure Notes

- Respecter l'architecture Feature-Sliced Hybrid.
- `PracticeEngine` doit rester découplé de l'UI (pas d'import SwiftUI dans le moteur si possible, sauf pour `@Observable`).

### References

- [Epics File: Story 3.3](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)
- [Architecture Document](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md)

## Dev Agent Record

### File List

- PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift
- PiTrainer/PiTrainer/SessionViewModel.swift
- PiTrainer/PiTrainer/SessionView.swift
- PiTrainer/PiTrainer/Core/Haptics/HapticService.swift
- PiTrainer/PiTrainer/Shared/ShakeEffect.swift
- PiTrainer/PiTrainerTests/PracticeEngineTests.swift
