# Story 1.2: Service Haptique (Core Haptics) avec Pre-warming

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur cherchant le flow,
I want ressentir un retour haptique instantané lors de chaque pression,
so that synchroniser mes gestes avec ma pensée.

## Acceptance Criteria

1. **Given** l'application lancée, **When** j'accède à l'écran de pratique, **Then** le moteur Core Haptics est "pre-warmed" (activé proactivement).
2. **Given** une session active, **When** une réussite est validée, **Then** une signature haptique de type "clic sec" (16ms) est jouée.
3. **Given** une session active, **When** une erreur est détectée, **Then** une signature haptique de type "vibration double" est jouée.
4. **Given** une utilisation intensive, **When** je saisis rapidement, **Then** le feedback est perçu comme instantané (<16ms) sans latence matérielle.

## Tasks / Subtasks

- [x] Initialiser le service haptique (AC: 1)
  - [x] Créer `HapticService.swift` dans `Core/Haptics/`
  - [x] Implémenter la création d'une instance `CHHapticEngine` unique (Singleton ou Service injecté)
  - [x] Ajouter une méthode `prewarm()` qui démarre l'engine
- [x] Créer les patterns haptiques (AC: 2, 3)
  - [x] Définir le pattern "Success" (Transient, 1.0 intensity, 1.0 sharpness)
  - [x] Définir le pattern "Error" (Complex: deux impacts successifs ou vibration saturée)
- [x] Connecter le service au `PracticeEngine` (AC: 2, 3)
  - [x] Exposer des méthodes `playSuccess()` et `playError()`
  - [x] S'assurer que les appels sont non-bloquants (Main Thread safety)
- [x] Gérer le cycle de vie de l'engine (AC: 4)
  - [x] Gérer les interruptions (AudioSession, Backgrounding)
  - [x] Implémenter le redémarrage automatique en cas d'arrêt de l'engine

## Dev Notes

- **Architecture:** Le service doit être situé dans `PiTrainer/Core/Haptics/HapticService.swift`.
- **Performance:** Appeler `engine.start()` pro-activement pour éviter le délai d'initialisation au premier clic.
- **Threading:** `CHHapticEngine` gère son propre threading, mais l'appel au `HapticService` doit être ultra-rapide.
- **Reference:** [Architecture Document](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L70-L73)

### Project Structure Notes

- Module: `Core`
- Class/Struct: `HapticService`
- Target Path: `PiTrainer/Core/Haptics/HapticService.swift`

### References

- [UX Specification](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md#L45)
- [Core Haptics Best Practices](https://developer.apple.com/documentation/corehaptics/playing_custom_haptic_patterns)

## Dev Agent Record

### Agent Model Used
BMAD Create-Story Engine

### Debug Log References
- Researching Core Haptics pre-warming techniques.
- Analyzing `PracticeEngine.swift` for integration points.

### Completion Notes List
- Ultimate context engine analysis completed.
- Comprehensive developer guide created with specific CHHapticEngine patterns.
- Created `HapticService.swift` with Core Haptics engine, pre-warming, and custom patterns.
- Integrated `HapticService` into `SessionViewModel` replacing legacy haptics.
- Added compatibility methods (`playTap`, `prepare`) for `ProPadViewModel`.
- Verified implementation with `HapticServiceTests` (Passed).
- Comprehensive developer guide created with specific CHHapticEngine patterns.

### File List
- `PiTrainer/PiTrainer/Core/Haptics/HapticService.swift`
- `PiTrainer/PiTrainerTests/HapticServiceTests.swift`
- `PiTrainer/PiTrainer/SessionViewModel.swift`
- `PiTrainer/PiTrainer/PracticeEngine.swift`
- `PiTrainer/PiTrainer/SessionView.swift`

## Senior Developer Review (AI)

- **Date:** 2026-01-16
- **Reviewer:** Agent (Antigravity)
- **Outcome:** Approved with Automatic Fixes
- **Notes:**
    - Added missing files to git tracking.
    - Updated documentation to reflect actual file paths and integration points.
    - Verified Core Haptics implementation against ACs.



