# Story 17.3: Mode saisie "Je sais !" et flux de réponse

Status: done

## Story

As a **utilisateur**,
I want **appuyer sur "Je sais !" pour basculer en mode saisie et taper les décimales suivantes avec le ProPad**,
so that **je puisse prouver ma reconnaissance de la séquence et gagner des points**.

## Acceptance Criteria

1. **AC1 — Transition "Je sais !"** : Quand l'utilisateur appuie sur "Je sais !", le bouton 👁 et le bouton "Je sais !" disparaissent, le ProPad (clavier 3×4) apparaît, et le curseur de saisie se positionne après la dernière décimale révélée.

2. **AC2 — Saisie correcte** : En mode saisie, quand l'utilisateur tape une décimale correcte, elle s'affiche dans le bloc de 10 à la bonne position avec feedback visuel (cyanElectric) et haptique (playSuccess) identiques au mode Practice.

3. **AC3 — Saisie incorrecte** : En mode saisie, quand l'utilisateur tape une décimale incorrecte, la session se termine immédiatement (no retry). Le nombre de décimales correctement saisies (`correctGuessCount`) est mémorisé pour Story 17.4.

4. **AC4 — Tests** : Tests unitaires couvrant la transition "Je sais !", la saisie correcte, la saisie incorrecte, le `correctGuessCount`, et l'offset de validation (guessing commence après les indices révélés).

## Tasks / Subtasks

- [x] Task 1 — ChallengeViewModel : état mode saisie (AC: #1, #2, #3)
  - [x] 1.1 Ajouter `var isInGuessingMode: Bool = false`
  - [x] 1.2 Ajouter `var guessingInput: String = ""`
  - [x] 1.3 Ajouter `var correctGuessCount: Int { guessingInput.count }` — pour Story 17.4
  - [x] 1.4 Ajouter `var isSuccessfulCompletion: Bool = false` — distingue succès/erreur pour la célébration
  - [x] 1.5 Ajouter `func activateGuessingMode()` — sets `isInGuessingMode = true`
  - [x] 1.6 Modifier `handleInput(_:)` — dispatch vers `handleGuessDigit` si `isInGuessingMode`, sinon guard-return
  - [x] 1.7 Ajouter `private func handleGuessDigit(_ digit: Int)` — validation contre `revealPool[revealedCount + guessingInput.count]`
  - [x] 1.8 Modifier `handleBackspace()` — en mode saisie, supprime le dernier caractère de `guessingInput` (si non vide)
- [x] Task 2 — ChallengeSessionView : UI mode saisie (AC: #1, #2)
  - [x] 2.1 Rendre `gridTypedDigits` dynamique selon la phase :
    - Revealing : `viewModel.challenge.referenceSequence` (inchangé Story 17.2)
    - Guessing : `viewModel.challenge.referenceSequence + String(viewModel.challenge.revealPool.prefix(viewModel.revealedCount)) + viewModel.guessingInput`
  - [x] 2.2 Mettre à jour `gridRowCount` pour inclure `guessingInput.count` en mode saisie :
    - `let totalPositions = musOffset + musLen + revealedCount + (isInGuessingMode ? guessingInput.count : 0)`
  - [x] 2.3 Mettre à jour `allowsReveal` → `viewModel.canReveal && !viewModel.isInGuessingMode`
  - [x] 2.4 Rendre `iKnowButton` fonctionnel : appel `viewModel.activateGuessingMode()` dans l'action
  - [x] 2.5 Masquer `iKnowButton` quand `viewModel.isInGuessingMode` (ou animer la disparition)
  - [x] 2.6 Ajouter `.id(viewModel.isInGuessingMode ? "guessing" : "revealing")` sur `TerminalGridView` pour reset propre du `revealedDigitsPerRow` interne lors de la transition
  - [x] 2.7 Afficher `ProPadView` conditionnel quand `viewModel.isInGuessingMode`, en bas (remplace la zone vide)
  - [x] 2.8 Modifier `.onChange(of: viewModel.isCompleted)` : n'appeler `triggerCelebration()` que si `viewModel.isSuccessfulCompletion`
- [x] Task 3 — Tests unitaires (AC: #4)
  - [x] 3.1 Test: `activateGuessingMode()` → `isInGuessingMode == true`
  - [x] 3.2 Test: en mode saisie, input correct → `guessingInput` s'étend, `correctGuessCount` s'incrémente
  - [x] 3.3 Test: en mode saisie, input incorrect → `isCompleted == true`, `isSuccessfulCompletion == false`
  - [x] 3.4 Test: en mode saisie avec `revealedCount = 3`, validation commence à `revealPool[3]` (pas `revealPool[0]`)
  - [x] 3.5 Test: `handleBackspace()` en mode saisie supprime le dernier caractère de `guessingInput`
  - [x] 3.6 Test: `handleInput` est no-op si `!isInGuessingMode`
  - [x] 3.7 Anciens tests dead-code supprimés et remplacés par 11 nouveaux tests Story 17.3

## Dev Notes

### Contexte architectural

Cette story est la **troisième** de l'Epic 17 (Refonte Daily Challenge). Les deux précédentes ont posé les fondations :
- **17.1** : `ChallengeService` étendu — `Challenge` contient `blockStartIndex`, `musOffsetInBlock`, `revealPool`
- **17.2** : `ChallengeSessionView` utilise `TerminalGridView` ; `ChallengeViewModel` a `revealedCount`, `canReveal`, `visibleDigits`, `revealNextDigit()`, `revealDigits(count:)` ; bouton "JE SAIS !" est un placeholder no-op

Cette story **active** le bouton "JE SAIS !" et câble le `ProPadView`.

### ChallengeViewModel — Implémentation détaillée

**État à ajouter :**
```swift
// Story 17.3: Guessing mode state
var isInGuessingMode: Bool = false
var guessingInput: String = ""
var isSuccessfulCompletion: Bool = false

var correctGuessCount: Int { guessingInput.count }  // For Story 17.4 scoring
```

**`activateGuessingMode()` :**
```swift
func activateGuessingMode() {
    guard !isInGuessingMode, !isCompleted else { return }
    isInGuessingMode = true
}
```

**`handleInput` modifié :**
```swift
func handleInput(_ digit: Int) {
    guard !isCompleted, isInGuessingMode else { return }
    handleGuessDigit(digit)
}

private func handleGuessDigit(_ digit: Int) {
    let input = String(digit)
    let poolOffset = revealedCount + guessingInput.count

    // Pool exhausté — fin de session par succès
    guard poolOffset < challenge.revealPool.count else {
        isCompleted = true
        isSuccessfulCompletion = true
        hapticService.playDoubleBang()
        return
    }

    let expectedCharIndex = challenge.revealPool.index(
        challenge.revealPool.startIndex, offsetBy: poolOffset)
    let expectedDigit = String(challenge.revealPool[expectedCharIndex])

    if input == expectedDigit {
        guessingInput += input
        hapticService.playSuccess()

        // Vérifier la complétion
        if revealedCount + guessingInput.count >= challenge.revealPool.count {
            isCompleted = true
            isSuccessfulCompletion = true
            hapticService.playDoubleBang()
        }
    } else {
        // Mauvais digit — fin de session immédiate (pas de retry)
        triggerError()
        isCompleted = true
        // isSuccessfulCompletion reste false
    }
}
```

**`handleBackspace` modifié :**
```swift
func handleBackspace() {
    if isInGuessingMode {
        guard !isCompleted, !guessingInput.isEmpty else { return }
        guessingInput.removeLast()
    } else {
        guard !currentInput.isEmpty else { return }
        currentInput.removeLast()
        isErrorShakeActive = false
        isShowingRecovery = false
    }
}
```

**Note critique :** `revealPool` et `expectedNextDigits` commencent au même index (`musEnd`). Quand `revealedCount = 0`, `handleGuessDigit` valide contre `revealPool[0]` qui est le même que `expectedNextDigits[0]`. Cela est intentionnel (overlap Strategy from Story 17.1).

### ChallengeSessionView — Implémentation détaillée

**`gridTypedDigits` dynamique :**
```swift
private var gridTypedDigits: String {
    if viewModel.isInGuessingMode {
        let revealed = String(viewModel.challenge.revealPool.prefix(viewModel.revealedCount))
        return viewModel.challenge.referenceSequence + revealed + viewModel.guessingInput
    }
    return viewModel.challenge.referenceSequence
}
```

**`gridRowCount` dynamique :**
```swift
private var gridRowCount: Int {
    let guessCount = viewModel.isInGuessingMode ? viewModel.guessingInput.count : 0
    let totalPositions = viewModel.challenge.musOffsetInBlock
        + viewModel.challenge.referenceSequence.count
        + viewModel.revealedCount
        + guessCount
    return (totalPositions / 10) + 1
}
```

**TerminalGridView avec reset ID :**
```swift
TerminalGridView(
    typedDigits: gridTypedDigits,
    integerPart: viewModel.challenge.constant.integerPart,
    fullDigits: gridFullDigits,
    isLearnMode: false,
    allowsReveal: viewModel.canReveal && !viewModel.isInGuessingMode,
    startOffset: viewModel.challenge.blockStartIndex,
    onReveal: { count in viewModel.revealDigits(count: count) },
    typedDigitsColumnOffset: viewModel.challenge.musOffsetInBlock,
    fullDigitsOffset: 0,
    forcedRowCount: gridRowCount
)
.id(viewModel.isInGuessingMode ? "guessing" : "revealing")  // Reset revealedDigitsPerRow
```

**Pourquoi `.id()` ?** `TerminalGridView` gère `@State private var revealedDigitsPerRow: [Int: Int]`. En mode saisie, `typedDigits` s'étend pour couvrir les positions précédemment ghost. Sans reset, le state interne déplacerait les ghost digits au-delà de `typedDigits.count`, causant un affichage incorrect. Forcer une nouvelle identité recrée le composant avec un state vide.

**Effet visuel attendu :** Au tap "Je sais !", les digits ghost (30% opacité) deviennent instantanément solides (100%), confirmant visuellement le lock des indices. C'est intentionnel et souhaitable.

**ProPadView conditionnel :**
```swift
if viewModel.isInGuessingMode {
    ProPadView(
        onDigit: { digit in viewModel.handleInput(digit) },
        onBackspace: { viewModel.handleBackspace() },
        onOptions: { /* no-op en mode challenge */ }
    )
    .padding(.horizontal)
    .padding(.bottom, 20)
}
```

**Célébration conditionnelle :**
```swift
.onChange(of: viewModel.isCompleted) { _, completed in
    if completed {
        if viewModel.isSuccessfulCompletion {
            triggerCelebration()
        }
        navigationTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            onComplete?(Date())
            coordinator.pop()
        }
    }
}
```

**Note Story 17.4 :** Le `onComplete(Date())` actuel se contente de popper. Story 17.4 remplacera ce comportement par la navigation vers un écran de résultat, en passant `correctGuessCount` et `revealedCount`.

### ProPadView — API existante (ne pas modifier)

Fichier : `Features/Practice/ProPadView.swift`

```swift
ProPadView(
    layout: .phone,           // Défaut .phone — layout standard
    currentStreak: Int = 0,   // Non utilisé en mode challenge — passer 0
    isActive: Bool = true,
    isGhostModeEnabled: Bool = true,  // Ghost (opacité dynamique) actif
    onDigit: (Int) -> Void,   // REQUIRED
    onBackspace: () -> Void,  // REQUIRED
    onOptions: () -> Void     // REQUIRED — no-op acceptable
)
```

Le `ProPadViewModel` interne gère l'opacité ghost via `currentStreak`. En mode challenge (streak = 0), la touche apparaîtra à opacité normale.

### Anciens tests à supprimer/remplacer

Ces tests dans `ChallengeViewModelTests.swift` testent l'ancien flow direct (`currentInput`/`expectedNextDigits`) qui n'est plus accessible par l'UI après Story 17.3 :
- `testCorrectInput` — remplacer par test guessing mode correct
- `testIncorrectInput` — remplacer par test guessing mode erreur
- `testBackspace` — remplacer par test backspace en mode saisie
- `testDisplayString` — `displayTarget` est du code mort; supprimer
- `testRecoveryLogic` — le recovery bridge fonctionne toujours en mode saisie via `triggerError()`, garder mais adapter
- `testCompletionXP` — Story 17.3 ne crédite pas de XP (Story 17.4 s'en charge); supprimer/remplacer

**Les 8 tests Story 17.2 (`testReveal*`, `testHintCounter*`) ne sont PAS affectés** — ils ne touchent pas `handleInput`.

### Localization

Aucune nouvelle clé requise :
- `challenge.i_know` : déjà ajoutée en Story 17.2 (EN: "I KNOW IT!" / FR: "JE SAIS !")
- `ProPadView` est auto-suffisant (pas de texte localisé)
- La célébration utilise `DoubleBangView` existant

### Fichiers impactés

| Fichier | Action |
|---|---|
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift` | Modifier : ajouter état guessing, `activateGuessingMode()`, `handleGuessDigit()`, modifier `handleInput`, `handleBackspace` |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift` | Modifier : `gridTypedDigits` dynamique, `gridRowCount` dynamique, `.id()` sur TerminalGridView, afficher ProPad, rendre iKnowButton fonctionnel, célébration conditionnelle |
| `PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift` | Supprimer 5 anciens tests, ajouter 7 nouveaux tests mode saisie |

**Aucun nouveau fichier.** Pas de modification à `TerminalGridView.swift`, `ChallengeService.swift`, `Localizable.xcstrings`.

### References

- [Source: _bmad-output/planning-artifacts/epics-challenge-revamp.md — Story 17.3 AC]
- [Source: _bmad-output/implementation-artifacts/17-2-vue-challenge-bloc-10-devoilement-oeil.md — Dev Notes, Completion Notes, learnings Story 17.2]
- [Source: Features/Challenges/ChallengeViewModel.swift — état actuel à étendre]
- [Source: Features/Challenges/ChallengeSessionView.swift — layout actuel, gridTypedDigits, gridRowCount]
- [Source: Features/Practice/TerminalGridView.swift — `@State revealedDigitsPerRow`, paramètre `.id()` reset]
- [Source: Features/Practice/ProPadView.swift — API et callbacks requis]
- [Source: Features/Challenges/ChallengeService.swift — overlap intentionnel `revealPool` / `expectedNextDigits` (musEnd), `maxRevealPoolSize = 20`]
- [Source: PiTrainerTests/ChallengeViewModelTests.swift — tests existants 17.2 à préserver, anciens tests à remplacer]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

N/A

### Completion Notes List

- `ChallengeViewModel` : ajout de `isInGuessingMode`, `guessingInput`, `isSuccessfulCompletion`, `correctGuessCount`, `activateGuessingMode()`, `handleGuessDigit(_:)` (valide contre `revealPool[revealedCount + guessingInput.count]`)
- `handleInput` modifié : dispatch vers `handleGuessDigit` uniquement si `isInGuessingMode`, sinon guard-return (no-op en phase reveal)
- `handleBackspace` modifié : en mode saisie, supprime dernier caractère de `guessingInput` ; en phase reveal, comportement inchangé
- Erreur en mode saisie : `triggerError()` + `isCompleted = true` ; succès (pool épuisé ou complétion) : `isSuccessfulCompletion = true` + `isCompleted = true` + `hapticService.playDoubleBang()`
- `ChallengeSessionView` : `gridTypedDigits` dynamique (MUS + revealed + guessingInput en mode guessing), `gridRowCount` dynamique, `allowsReveal = canReveal && !isInGuessingMode`, `.id()` sur TerminalGridView pour reset propre
- `iKnowButton` désormais fonctionnel : appel `activateGuessingMode()`. Masqué quand `isInGuessingMode`
- `ProPadView` affiché conditionnellement quand `isInGuessingMode`, câblé sur `handleInput` et `handleBackspace`
- Célébration conditionnelle : `DoubleBangView` affiché uniquement si `isSuccessfulCompletion`
- Compteur d'indices (`hintCounter`) masqué en mode saisie (indices verrouillés)
- 6 anciens tests dead-code supprimés (`testCorrectInput`, `testIncorrectInput`, `testBackspace`, `testDisplayString`, `testRecoveryLogic`, `testCompletionXP`)
- 11 nouveaux tests Story 17.3 ajoutés, tous passent ✅
- 8 tests Story 17.2 préservés et passent ✅ (20 tests ChallengeViewModelTests total — 21 après code review)
- 22 tests ChallengeServiceTests préservés ✅
- 4 tests ChallengeHubViewModelTests préservés ✅
- 0 régression introduite

### Code Review Notes (claude-sonnet-4-6 — 2026-02-23)

**7 issues trouvés et traités : 2 HIGH (fixés), 3 MEDIUM (fixés), 2 LOW (action items)**

Fixes appliqués :
- **[H1]** `activateGuessingMode()` : ajout guard `revealedCount < pool.count` — bloque le succès gratuit quand le pool est épuisé avant d'activer le mode saisie
- **[H1-UX]** `iKnowButton` dans `ChallengeSessionView` : `.disabled(!canReveal)` + `.opacity(0.5)` quand pool épuisé
- **[H2]** `triggerRecovery()` : calcul du `localFailIndex` avec `revealedCount + guessingInput.count` en mode saisie (au lieu de `currentInput.count` toujours 0)
- **[M1]** `handleGuessDigit()` : suppression du double haptic — `playSuccess()` uniquement pour les digits non-finaux, `playDoubleBang()` uniquement pour le dernier digit correct
- **[M2]** `displayTarget` supprimé de `ChallengeViewModel` — propriété dead code (jamais référencée depuis Story 17.3)
- **[M3]** `reset()` mis à jour : réinitialise désormais `isInGuessingMode`, `guessingInput`, `isSuccessfulCompletion`
- **[H1-Test]** Test `testActivateGuessingMode_BlockedWhenPoolExhausted` ajouté (21e test)
- **[L2]** `testGuessing_IncorrectInput_EndsSession` : assertion `isShowingRecovery` ajoutée

Action items (LOW) :
- [L1] Dev Notes section ligne ~263 contient des prévisions dépassées ("5 anciens tests", "7 nouveaux") — inoffensif, contexte historique

**Résultat : 21/21 ChallengeViewModelTests ✅ — Story approuvée**

### File List

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift`
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift`
- `PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift`
