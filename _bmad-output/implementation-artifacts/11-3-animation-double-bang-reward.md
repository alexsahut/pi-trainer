# Story 11.3: Animation "Double Bang" (Reward)

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a gamer,
I want une célébration épique quand je bats mon record ET que je monte en grade simultanément,
so that marquer le coup lors d'une performance exceptionnelle et ressentir un fort sentiment d'accomplissement.

## Acceptance Criteria

1. [x] **Dual Success Detection**: Le système doit détecter simultanément :
    - La validation d'un nouveau record personnel (PB / Ghost) par une session certifiée (0 erreur, 0 reveal).
    - Un changement de palier de `Grade` (ex: de Novice à Apprenti) suite à l'ajout de l'XP de la session.
2. [x] **Double Animation**: Une double animation synchronisée se déclenche sur l'écran de résultat :
    - Explosion de particules (Success/XP).
    - Effets d'éclairs (Record/Performance).
3. [x] **Haptic Feedback**: Un feedback haptique intense combinant `Success` + `Impact` + `Rumble` est joué via `Core Haptics`.
4. [x] **UI Branding**: L'écran de résultat doit porter la mention distinctive "DOUBLE BANG" avec un effet de lueur (Glow) cyan.
5. [x] **Performance**: L'animation doit maintenir 60 FPS constants sur iPhone 15+ (utilisation recommandée de `Canvas`).

## Tasks / Subtasks

- [x] **Core Logic (Detection)** (AC: 1)
  - [x] Modifier `StatsStore.addSessionRecord(_:)` pour comparer le grade avant/après mise à jour.
  - [x] Vérifier si `record.isCertified` et si le record de la constante est battu.
  - [x] Créer `RewardManager` pour stocker et diffuser l'état de la récompense.
- [x] **Haptics Engineering** (AC: 3)
  - [x] Ajouter un pattern `playDoubleBang()` dans `HapticService.swift`.
  - [x] Utiliser un `CHHapticPattern` composite (Transient + Continuous).
- [x] **Visual Engineering (SwiftUI Canvas)** (AC: 2, 5)
  - [x] Créer `DoubleBangView.swift` utilisant `Canvas` pour les particules.
  - [x] Implémenter l'effet d'éclairs via des tracés de `Path` animés.
- [x] **UI Integration** (AC: 4)
  - [x] Intégrer `DoubleBangView` dans l'overlay de fin de session de `SessionView`.
  - [x] Ajouter le label "DOUBLE BANG" stylisé dans `SessionView`.

## Dev Notes

### Architecture & Logic Compliance
- **StatsStore Update**: La détection doit se faire *pendant* l'ajout du record pour capturer l'état de transition de l'XP.
- **Haptic Pre-warming**: Le moteur `Core Haptics` est déjà pré-chauffé par `SessionView`, s'assurer que `playDoubleBang()` l'utilise directement.
- **Canvas Rendering**: Prioriser `Canvas` pour les particules afin d'éviter la surcharge du graphe de vue SwiftUI avec des milliers de noeuds.

### Design System Compliance
- **Color**: Utiliser `DesignSystem.Colors.cyanElectric` pour les particules et le texte.
- **Typography**: SF Mono (Monospaced) pour le label "DOUBLE BANG".
- **Glow**: Appliquer `.shadow(color: DesignSystem.Colors.cyanElectric.opacity(0.8), radius: 15)` sur les éléments de célébration.

### References
- [Architecture V2.10 Synchronisation](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#Section-V2.10-Synchronisation-du-Double-Bang)
- [Grade Model thresholds](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Shared/Models/Grade.swift)
- [HapticService implementation](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Haptics/HapticService.swift)

## Review Follow-ups (AI)
- [x] [AI-Review][Medium] Fix Logic Order in StatsStore (Persistence before Reward) [StatsStore.swift:278]
- [x] [AI-Review][Medium] Add Accessibility Announcement [SessionView.swift:187]
- [x] [AI-Review][Medium] Improve Haptic Fallback [HapticService.swift:252]
- [x] [AI-Review][Low] Fix Timer/Magic Numbers [DoubleBangView.swift:70]

## Dev Agent Record

### Agent Model Used
Antigravity (Claude 3.5 Sonnet)

### Completion Notes List
- Implemented `RewardManager` singleton to handle celebration states.
- Added `playDoubleBang()` composite haptic pattern in `HapticService`.
- Enhanced `StatsStore.addSessionRecord()` with concurrent logic for PB and Grade change detection.
- Created `DoubleBangView` using `Canvas` for optimized 60FPS celebrations.
- Integrated celebration overlay into `SessionView`.
- Verified logic with `StatsStoreTests.swift`.
- **Code Review**: Fixed ordering logic (post-persistence trigger), added accessibility support, and improved haptic fallback.

### File List
- [PiTrainer/Core/Engine/RewardManager.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Engine/RewardManager.swift)
- [PiTrainer/Core/Haptics/HapticService.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Haptics/HapticService.swift)
- [PiTrainer/Core/Persistence/StatsStore.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift)
- [PiTrainer/Shared/DoubleBangView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Shared/DoubleBangView.swift)
- [PiTrainer/SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift)
- [PiTrainerTests/StatsStoreTests.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainerTests/StatsStoreTests.swift)
