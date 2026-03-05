# Story 17.4: Scoring malus/bonus et écran de résultat

Status: done

## Story

As a **utilisateur**,
I want **voir un score détaillé à la fin du challenge basé sur mes indices utilisés et mes décimales données**,
so that **je comprenne ma performance et sois motivé à m'améliorer**.

## Acceptance Criteria

1. **AC1 — Calcul et affichage du score** : Quand la session se termine (succès ou erreur), l'écran de résultat affiche : `score = (décimalesCorrectementSaisies × 10) - (indicesRévélés × 5)`. Le détail est visible : nombre d'indices (malus), nombre de décimales données (bonus), score final. Le record personnel (meilleur score pour cette constante) est affiché pour comparaison.

2. **AC2 — Nouveau record** : Si le score est supérieur au record personnel, le nouveau record est sauvegardé dans `UserDefaults` et un feedback visuel de célébration est affiché (badge "NOUVEAU RECORD !" visible dans l'écran de résultat).

3. **AC3 — Recovery Bridge** : Dans l'écran de résultat, un bouton "S'entraîner sur ce segment" déclenche le Recovery Bridge vers le mode Learn (réutilise `viewModel.triggerRecovery()` via callback).

4. **AC4 — Navigation** : Le bouton "Terminer" de l'écran de résultat appelle `onComplete?(Date())` puis `coordinator.pop()`. L'écran de résultat remplace l'auto-pop de Story 17.3 (le `coordinator.pop()` automatique après 2.5s est supprimé).

5. **AC5 — Tests** : Tests unitaires couvrant le calcul du score, la persistance du record personnel, et la détection de nouveau record.

## Tasks / Subtasks

- [x] Task 1 — ChallengeScoreStore : persistence du record challenge (AC: #1, #2)
  - [x] 1.1 Créer `PiTrainer/PiTrainer/Features/Challenges/ChallengeScoreStore.swift`
  - [x] 1.2 Classe `@MainActor class ChallengeScoreStore` avec `static let shared`
  - [x] 1.3 Implémenter `func bestScore(for constant: Constant) -> Int?` — charge depuis UserDefaults
  - [x] 1.4 Implémenter `func saveBestScore(_ score: Int, for constant: Constant)` — sauvegarde uniquement si `score > currentBest`
  - [x] 1.5 Clé UserDefaults : `"com.alexandre.pitrainer.challenge.bestScore.\(constant.rawValue)"`
- [x] Task 2 — ChallengeViewModel : `computedScore` (AC: #1, #2)
  - [x] 2.1 Ajouter `var computedScore: Int { correctGuessCount * 10 - revealedCount * 5 }` (pas de floor à 0)
- [x] Task 3 — ChallengeResultView : nouvel écran de résultat (AC: #1, #2, #3, #4)
  - [x] 3.1 Créer `PiTrainer/PiTrainer/Features/Challenges/ChallengeResultView.swift`
  - [x] 3.2 View avec callbacks : `onDismiss: () -> Void`, `onTrain: () -> Void`
  - [x] 3.3 Section résultat : "BRAVO !" (succès) ou "DOMMAGE !" (erreur), avec couleur distincte
  - [x] 3.4 Section détail score :
    - "Décimales saisies: N × 10 = +NNN" (cyanElectric si N > 0)
    - "Indices utilisés: N × 5 = -NNN" (textSecondary)
    - Séparateur visuel
    - "Score: NNN" (grand, cyanElectric)
  - [x] 3.5 Section record : "Record personnel: NNN" — si premier score, afficher "—"
  - [x] 3.6 Badge "NOUVEAU RECORD !" visible si `score > previousBest` (cyanElectric, animation .spring)
  - [x] 3.7 Bouton "S'ENTRAÎNER SUR CE SEGMENT" (orangeElectric, outline) — appelle `onTrain()`
  - [x] 3.8 Bouton "TERMINER" (cyanElectric, filled) — appelle `onDismiss()`
  - [x] 3.9 Ajouter les clés de localisation dans `Localizable.xcstrings` (voir section Localisation)
- [x] Task 4 — ChallengeSessionView : affichage du résultat et navigation (AC: #4)
  - [x] 4.1 Ajouter `@State private var showResult: Bool = false`
  - [x] 4.2 Remplacer le bloc `.onChange(of: viewModel.isCompleted)` :
    - Succès : DoubleBang → après 2.5s → `showResult = true`
    - Erreur : délai 0.5s → `showResult = true` (laisser l'animation de shake se terminer)
    - Supprimer `onComplete?(Date())` + `coordinator.pop()` de ce bloc
  - [x] 4.3 Overlay `ChallengeResultView` conditionnel sur `showResult` :
    - `onDismiss` : sauvegarde score → `showResult = false` → 100ms → `onComplete?` → `coordinator.pop()`
    - `onTrain` : `viewModel.triggerRecovery()` (le viewModel s'occupe de la navigation)
  - [x] 4.4 Sauvegarder le score dans `ChallengeScoreStore` depuis l'action `onDismiss`
- [x] Task 5 — Tests unitaires (AC: #5)
  - [x] 5.1 Dans `ChallengeViewModelTests` : `testComputedScore_AllCorrectNoHints` — `correctGuessCount=10, revealedCount=0` → score=100
  - [x] 5.2 Dans `ChallengeViewModelTests` : `testComputedScore_WithHints` — `correctGuessCount=3, revealedCount=3` → score=15
  - [x] 5.3 Dans `ChallengeViewModelTests` : `testComputedScore_CanBeNegative` — `correctGuessCount=0, revealedCount=5` → score=-25
  - [x] 5.4 Créer `PiTrainer/PiTrainerTests/ChallengeScoreStoreTests.swift`
  - [x] 5.5 `testSaveBestScore_FirstScore_Saves` — premier score sauvegardé
  - [x] 5.6 `testSaveBestScore_HigherScore_Updates` — score supérieur remplace le précédent
  - [x] 5.7 `testSaveBestScore_LowerScore_DoesNotUpdate` — score inférieur ne remplace pas

## Dev Notes

### Contexte architectural

Cette story est la **quatrième** de l'Epic 17. Elle s'appuie sur les trois précédentes :
- **17.1** : `Challenge` contient `revealPool`, `musOffsetInBlock`, `blockStartIndex`
- **17.2** : `ChallengeViewModel` a `revealedCount`, `hintCount`, `revealPool`
- **17.3** : `ChallengeViewModel` a `correctGuessCount = guessingInput.count`, `isSuccessfulCompletion`, `isCompleted`

**État disponible au moment de l'affichage du résultat :**
```swift
viewModel.correctGuessCount  // Int (alias de guessingInput.count)
viewModel.revealedCount      // Int (nombre d'indices révélés)
viewModel.isSuccessfulCompletion  // Bool (fin par succès ou erreur)
viewModel.isCompleted        // Bool (toujours true à ce stade)
viewModel.challenge.constant // Constant (pour récupérer le record)
```

### Task 1 — ChallengeScoreStore

**Pattern à suivre** : identique à `PersonalBestStore` (singleton `@MainActor`, UserDefaults).

```swift
import Foundation

@MainActor
class ChallengeScoreStore {
    static let shared = ChallengeScoreStore()

    private func key(for constant: Constant) -> String {
        "com.alexandre.pitrainer.challenge.bestScore.\(constant.rawValue)"
    }

    func bestScore(for constant: Constant) -> Int? {
        let value = UserDefaults.standard.integer(forKey: key(for: constant))
        // UserDefaults returns 0 for missing key — distinguish "not set" from score=0
        guard UserDefaults.standard.object(forKey: key(for: constant)) != nil else { return nil }
        return value
    }

    func saveBestScore(_ score: Int, for constant: Constant) {
        let current = bestScore(for: constant)
        if current == nil || score > current! {
            UserDefaults.standard.set(score, forKey: key(for: constant))
        }
    }
}
```

⚠️ **Piège UserDefaults** : `UserDefaults.standard.integer(forKey:)` retourne `0` si la clé n'existe pas. Il faut utiliser `.object(forKey:) != nil` pour distinguer "jamais enregistré" de "score = 0".

**Accès depuis `ChallengeScoreStoreTests`** : injecter via `init(defaults: UserDefaults = .standard)` pour les tests (utiliser une suite dédiée `UserDefaults(suiteName: "test")`).

### Task 2 — ChallengeViewModel.computedScore

```swift
/// Story 17.4: score = (correctGuessCount × 10) - (revealedCount × 5)
/// Score can be negative (used more hints than correct guesses).
var computedScore: Int {
    correctGuessCount * 10 - revealedCount * 5
}
```

Pas de `max(0, ...)` — le score négatif est intentionnel (signal que l'utilisateur a trop utilisé d'indices).

### Task 3 — ChallengeResultView

**Structure complète** :

```swift
import SwiftUI

struct ChallengeResultView: View {
    let score: Int
    let correctGuessCount: Int
    let revealedCount: Int
    let isSuccess: Bool
    let constant: Constant
    let previousBest: Int?        // nil = premier score
    let onDismiss: () -> Void
    let onTrain: () -> Void

    private var isNewRecord: Bool {
        guard let best = previousBest else { return true }  // Toujours record si premier
        return score > best
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            VStack(spacing: 24) {
                // 1. Titre (succès/échec)
                // 2. Score détail
                // 3. Record personnel + badge nouveau record
                // 4. Bouton "S'entraîner"
                // 5. Bouton "Terminer"
            }
        }
    }
}
```

**Règle "premier score = toujours record"** : si `previousBest == nil`, c'est un nouveau record (même si score négatif — c'est le premier !). Afficher le badge.

**Calcul du bonus et malus à l'écran** :
```swift
let bonus = correctGuessCount * 10
let malus = revealedCount * 5
```

**Couleurs** :
- Titre succès : `DesignSystem.Colors.cyanElectric`
- Titre erreur : `DesignSystem.Colors.orangeElectric`
- Score final : `DesignSystem.Colors.cyanElectric`
- Badge nouveau record : `DesignSystem.Colors.cyanElectric` (fond) + `.blackOLED` (texte)
- Bouton "Terminer" : fond `cyanElectric`, texte `blackOLED`
- Bouton "S'entraîner" : outline `orangeElectric`, texte `orangeElectric`

**Animation du badge** : `.scaleEffect` + `.opacity` avec `.animation(.spring(response: 0.4, dampingFraction: 0.7), value: isNewRecord)` et un délai de 0.3s.

**Localisation — nouvelles clés à ajouter** :

| Clé | FR | EN (defaultValue) |
|-----|----|--------------------|
| `challenge.result.title_success` | `BRAVO !` | `WELL DONE!` |
| `challenge.result.title_failure` | `DOMMAGE !` | `GOOD TRY!` |
| `challenge.result.correct_guesses` | `Décimales saisies` | `Digits Guessed` |
| `challenge.result.hints_used` | `Indices utilisés` | `Hints Used` |
| `challenge.result.score` | `Score` | `Score` |
| `challenge.result.best_score` | `Record personnel` | `Personal Best` |
| `challenge.result.new_record` | `NOUVEAU RECORD !` | `NEW RECORD!` |
| `challenge.result.done` | `TERMINER` | `DONE` |
| `challenge.result.train` | `S'ENTRAÎNER SUR CE SEGMENT` | `TRAIN ON THIS SEGMENT` |
| `challenge.result.first_score` | `—` | `—` |

### Task 4 — ChallengeSessionView : navigation

**Bloc `.onChange(of: viewModel.isCompleted)` — nouvelle version** :

```swift
.onChange(of: viewModel.isCompleted) { _, completed in
    if completed {
        if viewModel.isSuccessfulCompletion {
            triggerCelebration()
            navigationTask = Task {
                try? await Task.sleep(for: .seconds(2.5))
                guard !Task.isCancelled else { return }
                showResult = true
            }
        } else {
            // Error ending: show result after shake animation
            navigationTask = Task {
                try? await Task.sleep(for: .seconds(0.5))
                guard !Task.isCancelled else { return }
                showResult = true
            }
        }
    }
}
```

**Overlay `ChallengeResultView`** :

```swift
.fullScreenCover(isPresented: $showResult) {
    ChallengeResultView(
        score: viewModel.computedScore,
        correctGuessCount: viewModel.correctGuessCount,
        revealedCount: viewModel.revealedCount,
        isSuccess: viewModel.isSuccessfulCompletion,
        constant: viewModel.challenge.constant,
        previousBest: ChallengeScoreStore.shared.bestScore(for: viewModel.challenge.constant),
        onDismiss: {
            ChallengeScoreStore.shared.saveBestScore(
                viewModel.computedScore,
                for: viewModel.challenge.constant
            )
            onComplete?(Date())
            coordinator.pop()
        },
        onTrain: {
            viewModel.triggerRecovery()
        }
    )
}
```

⚠️ **Alternative à `.fullScreenCover`** : utiliser un ZStack overlay si `.fullScreenCover` cause des problèmes de navigation. Le `.fullScreenCover` est préférable car il superpose proprement sur toute la fenêtre sans interférer avec `TerminalGridView`.

⚠️ **Appel de `saveBestScore` dans `onDismiss`** : se fait AVANT `coordinator.pop()`. Cela garantit la persistance même si l'animation de pop est rapide.

⚠️ **`viewModel.triggerRecovery()` + `coordinator.pop()`** : le Recovery Bridge déclenche `shouldNavigateToPractice = true` sur le viewModel. `ChallengeSessionView` a déjà un `.onChange(of: viewModel.shouldNavigateToPractice)` qui appelle `coordinator.popToRoot()` puis `coordinator.push(.session(mode: .learning))`. La `ChallengeResultView` peut rester présentée pendant que la navigation se fait (le `.fullScreenCover` sera fermé naturellement quand la stack se réinitialise).

**Piège .fullScreenCover avec NavigationCoordinator** : si `coordinator.pop()` est appelé depuis `onDismiss` pendant que `.fullScreenCover` est présenté, l'ordre des operations peut causer un warning. Solution : fermer le cover d'abord, puis pop :

```swift
onDismiss: {
    ChallengeScoreStore.shared.saveBestScore(
        viewModel.computedScore,
        for: viewModel.challenge.constant
    )
    showResult = false  // Ferme le cover
    Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(100))
        onComplete?(Date())
        coordinator.pop()
    }
}
```

### Task 5 — Tests

**Tests `ChallengeViewModelTests`** — les tests `computedScore` se placent après les tests révéal existants.

Setup dans `setUp()` : le mockChallenge a `revealPool: "1415926535"` (10 digits). Pour les tests de score, il faut d'abord activer le guessing mode et taper des digits.

**Approche plus simple** : tester `computedScore` directement en manipulant l'état via `revealDigits()` et `handleInput()`.

```swift
func testComputedScore_AllCorrectNoHints() {
    // revealedCount = 0, type all 10 correctly
    viewModel.activateGuessingMode()
    let poolDigits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    for digit in poolDigits {
        viewModel.handleInput(digit)
    }
    // correctGuessCount = 10, revealedCount = 0
    XCTAssertEqual(viewModel.computedScore, 100)  // 10×10 - 0×5 = 100
}

func testComputedScore_WithHints() {
    // Reveal 3 hints, then guess 3 correct
    viewModel.revealDigits(count: 3)  // revealedCount = 3
    viewModel.activateGuessingMode()
    // revealPool[3] = "5", revealPool[4] = "9", revealPool[5] = "2"
    viewModel.handleInput(5)   // correct
    viewModel.handleInput(9)   // correct
    viewModel.handleInput(2)   // correct
    // correctGuessCount = 3, revealedCount = 3
    XCTAssertEqual(viewModel.computedScore, 15)  // 3×10 - 3×5 = 30-15 = 15
}

func testComputedScore_CanBeNegative() {
    // Reveal 5 hints, guess 0 (activate guessing then error immediately)
    viewModel.revealDigits(count: 5)  // revealedCount = 5
    viewModel.activateGuessingMode()
    viewModel.handleInput(9)   // Wrong: revealPool[5] = "2", so 9 is wrong → error
    // correctGuessCount = 0, revealedCount = 5
    XCTAssertEqual(viewModel.computedScore, -25)  // 0×10 - 5×5 = -25
}
```

**`ChallengeScoreStoreTests`** — utiliser une suite UserDefaults dédiée pour isolation :

```swift
@MainActor
class ChallengeScoreStoreTests: XCTestCase {
    var store: ChallengeScoreStore!
    let testDefaults = UserDefaults(suiteName: "ChallengeScoreStoreTests")!

    override func setUp() {
        super.setUp()
        testDefaults.removePersistentDomain(forName: "ChallengeScoreStoreTests")
        store = ChallengeScoreStore(defaults: testDefaults)
    }

    func testBestScore_NilWhenNotSet() {
        XCTAssertNil(store.bestScore(for: .pi))
    }

    func testSaveBestScore_FirstScore_Saves() {
        store.saveBestScore(50, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 50)
    }

    func testSaveBestScore_HigherScore_Updates() {
        store.saveBestScore(50, for: .pi)
        store.saveBestScore(80, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testSaveBestScore_LowerScore_DoesNotUpdate() {
        store.saveBestScore(80, for: .pi)
        store.saveBestScore(30, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testSaveBestScore_EqualScore_DoesNotUpdate() {
        store.saveBestScore(80, for: .pi)
        store.saveBestScore(80, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testBestScore_PerConstant_Independent() {
        store.saveBestScore(100, for: .pi)
        store.saveBestScore(50, for: .e)
        XCTAssertEqual(store.bestScore(for: .pi), 100)
        XCTAssertEqual(store.bestScore(for: .e), 50)
    }

    func testBestScore_NegativeScore_Saves() {
        store.saveBestScore(-25, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), -25)
    }

    func testBestScore_NegativeScore_UpdatedByPositive() {
        store.saveBestScore(-25, for: .pi)
        store.saveBestScore(10, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 10)
    }
}
```

⚠️ **`ChallengeScoreStore` doit accepter `UserDefaults` en injection** pour les tests. Signature :
```swift
init(defaults: UserDefaults = .standard)
```

### Fichiers impactés

| Fichier | Action |
|---|---|
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeScoreStore.swift` | **Créer** : store de persistance du record challenge |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeResultView.swift` | **Créer** : écran de résultat avec score/record/boutons |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift` | **Modifier** : ajouter `computedScore` |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift` | **Modifier** : remplacer auto-pop par `.fullScreenCover(ChallengeResultView)` |
| `PiTrainer/PiTrainer/Localizable.xcstrings` | **Modifier** : ajouter 9 clés `challenge.result.*` |
| `PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift` | **Modifier** : ajouter 3 tests `computedScore` |
| `PiTrainer/PiTrainerTests/ChallengeScoreStoreTests.swift` | **Créer** : 8 tests unitaires du store |

**Aucune modification à** : `ChallengeService.swift`, `NavigationCoordinator.swift`, `PersonalBestStore.swift`, `TerminalGridView.swift`.

### Localisation — procédure d'ajout xcstrings

`Localizable.xcstrings` est un fichier JSON structuré. Pattern d'une entrée :
```json
"challenge.result.score" : {
  "comment" : "Score label in challenge result screen.",
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Score"
      }
    },
    "fr" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Score"
      }
    }
  }
}
```

**Ne pas ajouter** de clé `%lld` (interpolation) sauf pour `challenge.result.score %lld` si le score est affiché inline dans la clé (mais il est préférable d'utiliser `Text("\(score)")` séparément ou `Text("challenge.result.score \(score)")` qui génère automatiquement une clé `"challenge.result.score %lld"`).

**Approche recommandée** : clés statiques pour les labels, affichage du nombre avec un `Text("\(score)")` séparé ou en interpolation directe dans la view.

### References

- [Source: _bmad-output/planning-artifacts/epics-challenge-revamp.md — Story 17.4 AC]
- [Source: _bmad-output/implementation-artifacts/17-3-mode-saisie-je-sais-flux-reponse.md — état ChallengeViewModel disponible (correctGuessCount, revealedCount, isSuccessfulCompletion)]
- [Source: PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift — état actuel]
- [Source: PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift — navigation actuelle à modifier]
- [Source: PiTrainer/PiTrainer/Core/Persistence/PracticePersistence.swift — patterns UserDefaults (clés, singletons)]
- [Source: PiTrainer/PiTrainer/Shared/Navigation/NavigationCoordinator.swift — push/pop/fullScreenCover]
- [Source: PiTrainer/PiTrainer/Shared/DoubleBangView.swift — pattern célébration overlay existant]
- [Source: PiTrainer/PiTrainer/DesignSystem.swift — cyanElectric, orangeElectric, blackOLED, surface]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- SourceKit faux positifs sur `Constant`, `DesignSystem`, `HapticService` — attendus (types cross-file non résolus sans index projet complet). Build réel OK.
- Tests `FileDigitsProviderTests`, `AssetIntegrityTests`, `DiagnosticTests` en échec pré-existant (erreur lancement simulateur, hors périmètre story 17.4).

### Completion Notes List

- **Task 1 — ChallengeScoreStore** : singleton `@MainActor` avec injection UserDefaults (testability). Piège UserDefaults résolu : utilisation de `.object(forKey:) != nil` pour distinguer "jamais enregistré" de "score = 0".
- **Task 2 — computedScore** : propriété calculée `correctGuessCount * 10 - revealedCount * 5`, score négatif intentionnel (signal sur-utilisation indices).
- **Task 3 — ChallengeResultView** : écran fullscreen avec titre coloré succès/erreur, détail bonus/malus, record personnel, badge "NOUVEAU RECORD !" animé (.spring), boutons Terminer/S'entraîner. Badge animé avec délai 0.3s et state `showBadge`. Premier score = toujours record (previousBest == nil → isNewRecord = true).
- **Task 4 — ChallengeSessionView** : suppression auto-pop, remplacement par `showResult: Bool` + `.fullScreenCover`. onDismiss : sauvegarde → `showResult = false` → 100ms Task → `onComplete?` → `coordinator.pop()`. onTrain : `viewModel.triggerRecovery()` (navigation Recovery Bridge existante).
- **Task 5 — Tests** : 3 tests `computedScore` (100, 15, -25) + 8 tests `ChallengeScoreStoreTests` (nil/save/update/no-update/equal/per-constant/negative). Total : 32/32 ✅.

### File List

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeScoreStore.swift` — **Créé**
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeResultView.swift` — **Créé**
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift` — **Modifié** (ajout `computedScore`)
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift` — **Modifié** (showResult + fullScreenCover + onChange refactoré)
- `PiTrainer/PiTrainer/Localizable.xcstrings` — **Modifié** (10 clés `challenge.result.*` ajoutées)
- `PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift` — **Modifié** (3 tests `computedScore`)
- `PiTrainer/PiTrainerTests/ChallengeScoreStoreTests.swift` — **Créé** (8 tests unitaires)

## Change Log

- 2026-02-23 : Story 17.4 implémentée. Créé `ChallengeScoreStore` (persistence record), `ChallengeResultView` (écran résultat), ajouté `computedScore` à `ChallengeViewModel`, refactoré navigation `ChallengeSessionView` (auto-pop → fullScreenCover), ajouté 10 clés localisation `challenge.result.*`, créé 11 nouveaux tests (32/32 ✅).
- 2026-03-03 : Code review — 6 issues corrigées (1 HIGH, 3 MEDIUM, 2 LOW). Fix: onTrain ferme le fullScreenCover avant triggerRecovery, suppression variable morte capturedPreviousBest, suppression print() debug, extraction isNewRecord() en méthode statique testable + 4 tests ajoutés, suppression force unwrap dans saveBestScore.
