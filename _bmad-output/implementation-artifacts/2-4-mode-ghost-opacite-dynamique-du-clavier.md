# Story 2.4: Mode "Ghost" - Opacité Dynamique du Clavier

**Status:** done

## Story

**As a** utilisateur expert,
**I want** que le clavier s'efface progressivement lors d'un long streak,
**So that** me concentrer exclusivement sur mes chiffres et ma mémoire musculaire.

## Acceptance Criteria

### Scenario 1: Opacity initiale au repos
**Given** l'écran de pratique est actif
**When** aucune saisie n'a été effectuée ou l'utilisateur est inactif
**Then** l'opacité du Pro-Pad est de 20% (0.2)
**And** le clavier est visible mais discret
**And** tous les chiffres restent lisibles.

### Scenario 2: Activation du mode Ghost lors d'un streak >20
**Given** un streak actif de 20+ succès consécutifs
**When** l'utilisateur continue à saisir des chiffres rapidement
**Then** l'opacité du Pro-Pad diminue progressivement jusqu'à 5% (0.05)
**And** la transition d'opacité est fluide et dure environ 1 seconde
**And** l'animation ne provoque aucune chute de framerate (<16ms).

### Scenario 3: Retour à l'opacité normale après inactivité
**Given** le mode Ghost est actif (opacité à 5%)
**When** l'utilisateur cesse de saisir des chiffres pendant 3 secondes
**Then** l'opacité du Pro-Pad remonte progressivement à 20%
**And** la transition est fluide (durée: 1.0 seconde)
**And** le clavier redevient visible pour faciliter la reprise.

### Scenario 4: Désactivation après erreur ou streak <20
**Given** le mode Ghost est actif (opacité à 5%)
**When** l'utilisateur fait une erreur OU le streak passe en dessous de 20
**Then** l'opacité remonte immédiatement à 20%
**And** la transition est rapide (durée: 0.5 seconde)
**And** le clavier redevient visible pour aider à la reprise.

## Tasks / Subtasks

- [x] Ajouter la logique de gestion d'opacité au `ProPadViewModel` (AC: #2, #3, #4)
  - [x] Créer une computed property `targetOpacity` basée sur le streak et l'activité utilisateur
  - [x] Implémenter la logique : streak >= 20 → 0.05, sinon → 0.2
  - [x] Ajouter un timer pour détecter l'inactivité (3 secondes sans saisie)
  - [x] Exposer les variables `currentStreak` et `lastInputTime` via binding ou observation
- [x] Connecter le ProPadViewModel au PracticeEngine streak (AC: #2, #4)
  - [x] Passer le `currentStreak` depuis `SessionViewModel` vers `ProPadView`
  - [x] S'assurer que le ProPadViewModel observe les changements de streak en temps réel
  - [x] Mettre à jour `lastInputTime` à chaque pression de touche
- [x] Implémenter les animations d'opacité fluides (AC: #2, #3, #4)
  - [x] Utiliser `withAnimation(.easeInOut(duration: 1.0))` pour la transition vers Ghost (5%)
  - [x] Utiliser `withAnimation(.easeInOut(duration: 1.0))` pour le retour après inactivité
  - [x] Utiliser `withAnimation(.easeOut(duration: 0.5))` pour le reset rapide après erreur
  - [x] S'assurer que l'animation est liée à la valeur `opacity` via `.animation(_:value:)`
- [x] Tests Unitaires pour la logique d'opacité
  - [x] Tester que l'opacité cible est 0.05 si streak >= 20
  - [x] Tester que l'opacité cible est 0.2 si streak < 20
  - [x] Tester le reset d'opacité après inactivité (mock du timer)
  - [x] Valider les durées d'animation selon les scénarios
- [x] Tests d'Intégration avec PracticeEngine
  - [x] Vérifier que l'opacité réagit correctement aux changements de streak
  - [x] Confirmer que l'opacité remonte après une erreur
  - [x] Tester le scénario complet: streak 0→20 (0.2→0.05) puis erreur (→0.2)
- [x] Validation de Performance (AC: #2)
  - [x] Vérifier que l'animation d'opacité maintient 60 FPS constants
  - [x] S'assurer qu'aucune gigue n'est visible lors de saisie rapide
  - [x] Confirmer que le timer d'inactivité ne bloque pas le Main Thread
- [x] Accessibilité
  - [x] S'assurer que l'opacité minimale (5%) reste suffisante pour VoiceOver
  - [x] Tester avec Reduced Motion activé (désactiver la transition si nécessaire)
  - [x] Vérifier que les labels d'accessibilité restent audibles à toutes les opacités

## Dev Notes

### Architecture & Patterns

- **Composant principal à modifier**: `PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift`
- **Intégration requise**: `PiTrainer/PiTrainer/SessionView.swift` pour passer le streak au ProPadView
- **Source de vérité**: `PracticeEngine.currentStreak` (propriété `@Observable` existante)
- **Pattern d'animation**: Utiliser `withAnimation()` pour animer les changements d'opacité de manière explicite
- **Timer d'inactivité**: Utiliser `DispatchQueue.main.asyncAfter` ou `Timer.scheduledTimer` pour détecter 3s d'inactivité

### Composants Existants à Réutiliser

| Composant | Emplacement | Usage |
|-----------|-------------|-------|
| `ProPadViewModel.opacity` | `Features/Practice/ProPadViewModel.swift` | Propriété existante (ligne 6), actuellement fixée à 0.2 |
| `PracticeEngine.currentStreak` | `Core/Engine/PracticeEngine.swift` | Source du streak pour la logique d'opacité |
| `SessionViewModel.engine` | `Features/Practice/SessionViewModel.swift` | Accès au PracticeEngine depuis SessionView |
| `ProPadView` | `Features/Practice/ProPadView.swift` | Vue qui applique `.opacity(viewModel.opacity)` ligne 43 |

### Contraintes Techniques (Architecture.md)

> **[PERFORMANCE]** Ultra-Low Latency: Pipeline réactif garantissant un feedback <16ms (60 FPS constants).
> Les animations doivent être GPU-accelerées et ne jamais impacter le Main Thread.
>
> **[RENDERING]** Optimisation via `.drawingGroup()` sur ProPadView (ligne 48). Rendu accéléré par le GPU (Metal) pour maintenir 60 FPS constants.
>
> Source: [architecture.md § Frontend Architecture](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L60-L63)

### Spécifications UX (ux-design-specification.md)

#### Ghost Mode Opacity Behavior

| Condition | Opacité Cible | Durée Transition | Animation Curve |
|-----------|---------------|------------------|-----------------|
| **Repos / Streak <20** | 20% (0.2) | - | - |
| **Streak >=20 actif** | 5% (0.05) | 1.0s | easeInOut |
| **Inactivité 3s** | 20% (0.2) | 1.0s | easeInOut |
| **Erreur / Reset** | 20% (0.2) | 0.5s | easeOut |

#### Spécifications Techniques UX

- **Opacité Minimale**: 5% (0.05) pour maintenir une visibilité minimale même en mode Ghost
- **Opacité de Repos**: 20% (0.2) pour un clavier discret mais utilisable
- **Seuil d'Activation**: Streak >= 20 (cohérent avec Story 2.3 Streak Flow intensification)
- **Détection d'Inactivité**: 3 secondes sans saisie de chiffre
- **Performance**: Transition d'opacité GPU-accelerée via SwiftUI, aucun impact sur framerate

Source: [ux-design-specification.md § Pro-Pad Ghost](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md#L246-L249)

### Learnings from Story 2.3 (Streak Flow Effect)

- **Animation Pattern**: Utiliser `.animation(.easeInOut(duration: X), value: observedProperty)` pour des transitions fluides liées à des changements de state
- **Performance**: Les animations d'opacité sont GPU-friendly et ne devraient pas impacter les 60 FPS si appliquées correctement
- **Source Observable**: Le `PracticeEngine.currentStreak` est déjà observé par `SessionViewModel`, confirme la chaîne de réactivité
- **Pattern confirmé**: Appliquer le modifier d'animation directement sur la vue concernée (ProPadView)

Source: [Story 2.3 Implementation](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/2-3-activation-du-streak-flow-paliers-visuels.md)

### Learnings from Story 1.3 (Pro-Pad Implementation)

- **Architecture existante**: ProPadView utilise déjà `.opacity(viewModel.opacity)` ligne 43
- **GPU Acceleration**: `.drawingGroup()` déjà appliqué ligne 48 pour maintenir 60 FPS
- **ViewModel Pattern**: ProPadViewModel gère l'état du clavier, inclut déjà la propriété `opacity`
- **État initial**: opacity est actuellement fixé à 0.2 (baseline Ghost Mode)
- **Haptic Service**: Le ViewModel utilise déjà `HapticService` pour le feedback tactile

Source: [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift) & [ProPadViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift)

### Web Research: SwiftUI Opacity Animation Performance

#### Key Findings on Opacity & Performance

1. **GPU-Friendly Modifier**: SwiftUI's `.opacity()` modifier is GPU-accelerated by default and is one of the most performant visual modifiers
2. **Animation Best Practices**:
   - Use explicit animations (`withAnimation()`) for controlled state changes
   - Tie animations to specific state values using `.animation(_:value:)` to avoid unwanted animations
   - Opacity changes are lightweight compared to shadow, blur, or mask modifiers
3. **Performance Guidelines**:
   - Opacity animations maintain 60 FPS easily if not combined with expensive modifiers
   - Avoid animating layout AND opacity simultaneously
   - Use `.drawingGroup()` for complex views (already applied to ProPadView)
4. **State Management**:
   - Minimize view invalidation by localizing state changes
   - Use `@Observable` for fine-grained reactivity (already in use)
   - Break down complex views to keep invalidation local

**Implementation Strategy for Ghost Mode**:
- Animate `opacity` property in ProPadViewModel using `withAnimation()` in response to streak changes
- Use `.animation(.easeInOut(duration: 1.0), value: viewModel.opacity)` on ProPadView for smooth transitions
- Implement inactivity timer using `DispatchQueue.main.asyncAfter` to avoid Main Thread blocking
- Leverage existing `.drawingGroup()` to ensure GPU acceleration

Sources: Web research on SwiftUI opacity animation performance

### Implementation Tips

#### 1. Opacity Logic in ProPadViewModel

```swift
// PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift
import SwiftUI

@Observable
final class ProPadViewModel {
    var opacity: Double = 0.2 // Current opacity (animated)
    private var currentStreak: Int = 0
    private var lastInputTime: Date = Date()
    private var inactivityTimer: Timer?
    
    private var targetOpacity: Double {
        guard currentStreak >= 20 else { return 0.2 }
        
        // Check if inactive for 3+ seconds
        let timeSinceLastInput = Date().timeIntervalSince(lastInputTime)
        return timeSinceLastInput >= 3.0 ? 0.2 : 0.05
    }
    
    func updateStreak(_ streak: Int) {
        currentStreak = streak
        updateOpacity(animated: true, fastTransition: streak < 20)
    }
    
    func digitPressed(_ digit: Int) {
        lastInputTime = Date()
        resetInactivityTimer()
        haptics.playTap()
        onDigit?(digit)
        updateOpacity(animated: true, fastTransition: false)
    }
    
    private func updateOpacity(animated: Bool, fastTransition: Bool) {
        let duration = fastTransition ? 0.5 : 1.0
        let animation = fastTransition ? Animation.easeOut(duration: duration) : Animation.easeInOut(duration: duration)
        
        if animated {
            withAnimation(animation) {
                opacity = targetOpacity
            }
        } else {
            opacity = targetOpacity
        }
    }
    
    private func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.updateOpacity(animated: true, fastTransition: false)
        }
    }
}
```

#### 2. Integration in SessionView

```swift
// Dans SessionView.swift, passer le streak au ProPadView
ProPadView(
    currentStreak: viewModel.engine.currentStreak,  // <-- AJOUTER
    onDigit: viewModel.handleDigit,
    onBackspace: viewModel.handleBackspace,
    onOptions: viewModel.handleOptions
)
```

#### 3. Modifier ProPadView pour accepter le streak

```swift
// Dans ProPadView.swift, ajouter le paramètre et passer au ViewModel
struct ProPadView: View {
    @State private var viewModel = ProPadViewModel()
    var currentStreak: Int = 0  // <-- AJOUTER
    
    var body: some View {
        // ... existing code ...
        .onChange(of: currentStreak) { _, newStreak in
            viewModel.updateStreak(newStreak)
        }
    }
}
```

### Fichiers à Créer/Modifier

| Action | Fichier | Raison |
|--------|---------|--------|
| **[MODIFY]** | `PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift` | Ajouter logique d'opacité dynamique et timer d'inactivité |
| **[MODIFY]** | `PiTrainer/PiTrainer/Features/Practice/ProPadView.swift` | Accepter `currentStreak` et le passer au ViewModel |
| **[MODIFY]** | `PiTrainer/PiTrainer/SessionView.swift` | Passer `viewModel.engine.currentStreak` au ProPadView |
| **[NEW/MODIFY]** | `PiTrainer/PiTrainerTests/ProPadGhostModeTests.swift` | Tests unitaires pour la logique d'opacité |

### Project Context Reference

- **Naming**: PascalCase pour structs/classes (`ProPadViewModel`), camelCase pour properties (`currentStreak`)
- **Suffixes**: ViewModel suffix pour les classes de logique (`ProPadViewModel`)
- **Threading**: Animations SwiftUI sur Main Thread, GPU-accelerées automatiquement
- **File Organization**: Composants de Practice dans `Features/Practice/`
- **Observable Pattern**: Utiliser `@Observable` pour la réactivité fine-grained

### Testing Requirements

#### Unit Tests (`ProPadGhostModeTests.swift`)

```swift
// Test cases à implémenter
- testOpacityBaselineIs20Percent()           // opacity = 0.2 au repos
- testOpacityDropsTo5PercentWhenStreak20()   // opacity = 0.05 si streak >= 20
- testOpacityReturnsTo20PercentAfter3sInactivity() // opacity = 0.2 après 3s sans input
- testOpacityResetsFastOnError()             // opacity = 0.2 rapide (0.5s) si streak < 20
- testInactivityTimerCancelsOnNewInput()     // timer reset à chaque saisie
```

#### Manual Performance Tests

1. **Framerate Test**:
   - Lancer une session, atteindre streak 20+ pour activer Ghost Mode
   - Saisir des chiffres rapidement pendant la transition d'opacité
   - **Expected**: 60 FPS constant, aucune gigue visible

2. **Transition Smoothness**:
   - Atteindre streak 19, puis saisir le 20ème → observer fade to 5% (1s)
   - Attendre 3s sans saisir → observer fade to 20% (1s)
   - Faire une erreur pendant Ghost Mode → observer fade rapide to 20% (0.5s)
   - **Expected**: Transitions visuellement fluides, courbes d'animation perceptibles

3. **Visual Quality**:
   - Vérifier que le clavier à 5% est encore perceptible (pas totalement invisible)
   - Vérifier que le clavier à 20% est discret mais utilisable
   - **Expected**: Effet Ghost subtil et premium

### References

- [PRD FR8](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/prd.md) - Streak Flow et Ghost Mode
- [Architecture § Rendering](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L60-L63) - GPU acceleration patterns
- [UX Spec § Pro-Pad Ghost](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md#L246-L249) - Opacité dynamique spécifications
- [Epics.md Story 2.4](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L206-L218) - User story et acceptance criteria
- [Story 2.3 Implementation](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/2-3-activation-du-streak-flow-paliers-visuels.md) - Animation patterns et learnings
- [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift) - Existing opacity implementation
- [ProPadViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift) - Existing ViewModel structure

### Git Intelligence from Recent Commits

Recent commits show:
- **Core Haptics implementation** (85aa6bd): HapticService already integrated in ProPadViewModel
- **Constant selection fixes** (9d092b8, 5f497df): Multi-constant support implemented, confirms session-scoped features
- **Session history per constant** (ad784f0): Stats tracking per constant, Ghost Mode is ephemeral and doesn't need persistence
- **Localization improvements**: Expect accessibility and localization considerations

**Actionable Insights**:
1. Ghost Mode is session-scoped and ephemeral - no persistence needed for opacity state
2. HapticService already integrated - leverage existing haptic feedback on key press
3. Expect thorough code review - prepare comprehensive unit tests
4. Performance is critical - validate smooth animations with manual tests

## Dev Agent Record

### Agent Model Used

Antigravity (BMad-Implementation-Agent)

### Debug Log References

- [ProPadViewModelTests.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainerTests/ProPadViewModelTests.swift) - Verified Ghost Mode logic (baseline, streak, inactivity, reset).
- [ProPadViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift) - Core Ghost Mode logic implemented.
- [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift) - Integrated streak observation.
- [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift) - Passed streak data.

### Completion Notes List

- ✅ Implemented `ProPadViewModel` dynamic opacity logic.
- ✅ Added `inactivityThreshold` (3s) for Ghost Mode reset.
- ✅ Implemented dual-durations for animations (1.0s smooth, 0.5s fast reset).
- ✅ Added `UIAccessibility.isReduceMotionEnabled` check to animations.
- ✅ Integrated `currentStreak` from `PracticeEngine` to `ProPadView`.
- ✅ Verified all logic via unit tests in `ProPadViewModelTests`.
- ✅ Build succeeded for iOS Simulator.

### File List

- [ProPadViewModel.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadViewModel.swift) [MOD] - Optimisation d'opacité et Reduced Motion.
- [ProPadView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/ProPadView.swift) [MOD] - Design System integration et animation déclarative.
- [SessionView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/SessionView.swift) [MOD] - Injection du streak.
- [ProPadViewModelTests.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainerTests/ProPadViewModelTests.swift) [MOD] - Tests de logique et simulation d'intégration.
- [Localizable.xcstrings](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Localizable.xcstrings) [MOD] - Position tracker accessibility strings.
- [StreakFlowEffect.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Practice/StreakFlowEffect.swift) [NEW] - Support visuel du streak.

