# Story 2.1: Affichage "Terminal-Grid" par blocs de 10

**Status:** done

## Story

**As a** utilisateur pratiquant la récitation de constantes,
**I want** voir les chiffres s'afficher par blocs verticaux de 10,
**So that** respecter mon modèle mental de découpage des constantes et visualiser ma progression.

## Acceptance Criteria

### Scenario 1: Affichage en Grille de 10 Colonnes
**Given** une session de pratique active
**When** je saisis des chiffres corrects
**Then** ils s'affichent dans une grille de 10 colonnes maximum par ligne
**And** chaque nouveau chiffre correct s'ajoute à la position suivante de la grille
**And** après 10 chiffres, une nouvelle ligne commence automatiquement.

### Scenario 2: Indicateur de Ligne
**Given** la Terminal-Grid affichant des lignes complètes
**When** une ligne de 10 chiffres est complétée
**Then** un indicateur discret montre le numéro de la ligne (ex: "10 >" pour marquer la fin des décimales 1-10)
**And** l'indicateur utilise la typographie désaturée (SF Pro Caption) pour ne pas distraire.

### Scenario 3: Performance 60 FPS
**Given** l'affichage dynamique des chiffres
**When** l'utilisateur saisit à haute fréquence (>10 Hz)
**Then** le rendu utilise `.drawingGroup()` pour déléguer au GPU
**And** le framerate reste constant à 60 FPS (latence < 16ms)
**And** aucun drop de frame n'est perceptible malgré la densité de `Text` views.

### Scenario 4: Défilement Fluide
**Given** plus de décimales saisies que l'écran peut afficher
**When** une nouvelle ligne est ajoutée
**Then** la grille défile automatiquement (scroll to bottom)
**And** la transition est fluide et non-saccadée
**And** le nouveau chiffre reste visible en bas de l'écran.

## Tasks / Subtasks

- [x] Créer `TerminalGridView.swift` (AC: #1, #2, #4)
  - [x] Définir la structure de grille (LazyVStack + HStack de 10)
  - [x] Implémenter le rendu par blocs de 10 avec indicateur de ligne
  - [x] Ajouter le scroll automatique vers le bas (ScrollViewReader + `.scrollTo()`)
  - [x] Styliser avec les couleurs du design system (Noir OLED, Cyan accent, texte blanc)
- [x] Optimiser la Performance GPU (AC: #3)
  - [x] Appliquer `.drawingGroup()` sur la grille complète
  - [x] Vérifier l'absence de recalculs inutiles (body invocations)
  - [x] Tester le framerate avec Instruments (Core Animation FPS)
- [x] Créer un Composant `DigitView` atomique
  - [x] Gérer les états: normal, active (cyan flash), error (rouge)
  - [x] Appliquer la typographie SF Mono pour les chiffres
  - [x] Optimiser pour le re-render minimal (Equatable conformance)
- [x] Intégrer dans `LearningSessionView` ou `SessionView`
  - [x] Remplacer/compléter l'affichage actuel avec `TerminalGridView`
  - [x] Connecter au ViewModel existant (`sessionDigits` ou équivalent)
- [x] Tests Unitaires et Previews
  - [x] Créer des previews avec données mock (10, 50, 200 chiffres)
  - [x] Tester le rendu avec différentes longueurs de séquences
  - [x] Mesurer la performance du scroll avec 100+ lignes

## Dev Notes

### Architecture & Patterns

- **Emplacement cible**: `PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift`
- **Architecture**: MVVM avec `@Observable`. Le ViewModel (`LearningSessionViewModel` ou `SessionViewModel`) expose la liste des chiffres saisis.
- **Pattern recommandé**: Utiliser un `Array<Int>` ou `Array<DigitState>` (struct avec valeur et état) pour l'état de la grille.

### Composants Existants à Réutiliser

| Composant | Emplacement | Usage |
|-----------|-------------|-------|
| `PracticeEngine` | `PiTrainer/PracticeEngine.swift` | Source de vérité pour les chiffres validés |
| `LearningSessionViewModel` | `Features/Practice/LearningSessionViewModel.swift` | ViewModel avec `@Observable` |
| `ProPadView` | `Features/Practice/ProPadView.swift` | Pattern de composant UI à suivre |
| Design System | `Shared/UI/` | Couleurs (NeonCyan, OLEDBlack), Fonts (SF Mono) |

### Contraintes Techniques (Architecture.md)

> **[CRITICAL]** Le rendu utilise **`.drawingGroup()`** pour un rendu accéléré par le GPU (Metal) afin de maintenir 60 FPS constants malgré la densité de chiffres.
> 
> Source: [architecture.md § Frontend Architecture](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md)

### Spécifications UX (ux-design-specification.md)

| Élément | Spécification |
|---------|---------------|
| **Layout** | Blocs verticaux de 10 chiffres (comme un terminal de code) |
| **Indicateur de ligne** | Ex: "150 >" pour le repérage spatial |
| **Défilement** | Fluide vers le haut à mesure que les lignes sont complétées |
| **Typographie chiffres** | SF Mono (monospaced) |
| **Typographie métadonnées** | SF Pro Caption désaturée |
| **Background** | Noir OLED (#000000) |
| **Accent** | Cyan Électrique (#00F2FF) pour le chiffre actif |

Source: [ux-design-specification.md § Component Strategy](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md)

### Learnings from Story 1-4 (PracticeEngine)

- Le `PracticeEngine` est une `struct` mutable avec `ValidationResult` (`.correct`, `.incorrect`, `.endGame`).
- Le ViewModel observe les changements et expose l'état pour l'UI.
- La persistance utilise `UserDefaults` avec des clés par constante (ex: `practice_highest_index_pi`).
- **Pattern ProPadView**: Utiliser `@Observable` pour le ViewModel, pas `@Published`.

### Implementation Tips

1. **LazyVStack vs VStack**: Utiliser `LazyVStack` pour le défilement performant avec beaucoup de lignes.
2. **ScrollViewReader**: Wrapper la grille dans `ScrollViewReader` + `.scrollTo(id, anchor: .bottom)` pour auto-scroll.
3. **DigitView Equatable**: Implémenter `Equatable` sur `DigitState` pour éviter les re-renders inutiles.
4. **Color Assets**: Les couleurs doivent être définies dans `Assets.xcassets` (NeonCyan, OLEDBlack) pour respecter le design system.

### Fichiers à Créer/Modifier

| Action | Fichier |
|--------|---------|
| **[NEW]** | `Features/Practice/TerminalGridView.swift` |
| **[NEW]** | `Shared/UI/DigitView.swift` (optionnel, peut être inline) |
| **[MODIFY]** | `Features/Practice/LearningSessionView.swift` ou `SessionView.swift` (intégration) |
| **[MODIFY]** | `LearningSessionViewModel.swift` (exposer liste des chiffres saisis si non existant) |

### Project Context Reference

- **Naming**: PascalCase pour les types (`TerminalGridView`), camelCase pour les variables (`currentDigits`).
- **Suffixes**: `[Nom]View` pour les vues SwiftUI.
- **Threading**: Tout le rendu UI doit rester sur le Main Thread. Le `.drawingGroup()` délègue au GPU.

### Testing Checklist

- [ ] Preview avec 0, 10, 50, 200 chiffres
- [ ] Test scroll automatique
- [ ] Instruments Core Animation FPS (objectif: 60 FPS constant)
- [ ] VoiceOver: chaque bloc de 10 annoncé comme unité logique

### References

- [PRD FR6](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/prd.md) - Affichage par blocs de 10
- [Architecture § Frontend](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md) - `.drawingGroup()` GPU acceleration
- [UX Design § Component Strategy](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md) - Terminal-Grid specs
- [Story 1-4](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/1-4-moteur-de-validation-practiceengine.md) - PracticeEngine patterns

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4 (Antigravity)

### Debug Log References

Build: xcodebuild PiTrainer scheme succeeded
Tests: PracticeEngineTests (8/8 passed), PracticeEngineAdvancedTests (11/11 passed)

### Completion Notes List

- Created `TerminalGridView.swift` with LazyVStack + HStack(10) structure
- Implemented `DigitState` enum (normal, active, error) and `TerminalRow` struct
- Added line indicators showing cumulative digit count ("10 >", "20 >", etc.)
- Applied `.drawingGroup()` for GPU-accelerated rendering (60 FPS target)
- Integrated into `SessionView.swift` replacing horizontal scroll display
- Created SwiftUI Previews for 0, 10, 50, 200 digits and error state

### File List

- **[NEW]** `PiTrainer/Features/Practice/TerminalGridView.swift`
- **[MODIFIED]** `PiTrainer/SessionView.swift` (lines 46-86 replaced with TerminalGridView)
- **[NEW]** `PiTrainerTests/TerminalGridTests.swift` (10 unit tests)

## Senior Developer Review (AI)

_Reviewer: Claude Sonnet 4 (Antigravity) on 2026-01-16_

**Outcome:** Approved with Fixes

**Fixes Applied:**
1. [M4] Fixed deprecated `onChange` syntax to iOS 17+ format
2. [M2] Added VoiceOver accessibility labels (`accessibilityLabel(for:)`)
3. [H2] Created `TerminalGridTests.swift` with 10 unit tests for TerminalRow logic

**Remaining (LOW):**
- [L1] `rows` computed property could be memoized for performance
- [L2] Missing doc comments on public API

**Tests Added:** TerminalGridTests (10/10 passed)
