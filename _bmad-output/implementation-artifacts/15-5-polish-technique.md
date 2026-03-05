# Story 15.5: Polish Technique

Status: done

## Story

En tant que développeur,
Je veux éliminer les dettes techniques résiduelles identifiées lors de la review adversariale et corriger les tests hors-scope de la story 15.4,
Afin que la codebase soit propre et que la suite de tests soit à 100%.

## Contexte

Cette story combine deux lots de travail :

1. **Code polish** — 5 items CR (Code Review) issus de l'epic-15-consolidation.md, identifiés lors d'une review adversariale des Stories 15.1–15.3.
2. **Test repair** — 5 suites de tests hors-scope de la Story 15.4, documentées dans `15-4-out-of-scope-failures.md`. Comprend la suppression de `StreakFlowTests.swift` (feature Story 2.3 jamais implémentée) et les corrections de `SessionViewModelTests`, `StatsPerConstantTests`, et `AtmosphericFeedbackTests`.

## Acceptance Criteria (AC)

### Lot A — Code Polish (CR items)

1. **AC1 — CR-3 MUS O(n³)** : La performance de `ChallengeService.calculateMUS` est mesurée via `testPerformance_CalculateMUS`. Si le test XCTMetric passe dans les limites acceptables sur iPhone réel / simulateur, l'item est considéré résolu (monitor). Si la performance est inacceptable, optimiser avec une approche suffix-array ou rolling-hash.

2. **AC2 — CR-7 Lightning flicker** : `LightningBranch.path(in:)` ne génère plus de points aléatoires à chaque frame. Les offsets relatifs du chemin lightning sont pré-calculés dans `LightningBranch.init(at:)` et stockés dans `var relativeOffsets: [(dx: CGFloat, dy: CGFloat)]` avec un `var angle: Double` fixe. La méthode `path(in:)` utilise `self.relativeOffsets` et `self.angle` sans `CGFloat.random`.

3. **AC3 — CR-8 Commentaire dupliqué** : Le commentaire `"// Derived properties"` n'apparaît qu'une seule fois dans `ChallengeViewModel.swift`. (Note : une seule occurrence trouvée lors de l'analyse — confirmer que l'item est déjà résolu ou qu'une deuxième occurrence existe ailleurs dans le fichier.)

4. **AC4 — CR-9 Dead code `constantTitle`** : La propriété `constantTitle` n'existe plus dans `HomeView.swift` ni dans aucun fichier Swift. (Note : introuvable lors de l'analyse — confirmer que l'item est déjà résolu.)

5. **AC5 — CR-11 XPProgressBar `progress` dict** : Le dictionnaire `ranges: [Grade: ClosedRange<Double>]` dans `XPProgressBar.progress` est extrait en `private static let` pour éviter la réallocation à chaque appel.

### Lot B — Test Repair (hors-scope 15.4)

6. **AC6 — `StreakFlowTests.swift` supprimé** : Le fichier de tests pour la feature Story 2.3 (jamais implémentée) est supprimé. Les 6 tests / 11 assertions obsolètes disparaissent du rapport de test.

7. **AC7 — `SessionViewModelTests.testConfigureForChallenge_SetsEngineParameters` corrigé** : La cause racine du delta (startIndex attendu=100 vs obtenu=105 ; endIndex=105 vs 110 ; mode LEARN vs GAME) est identifiée. Le test ou l'implémentation est corrigé pour être cohérent.

8. **AC8 — `SessionViewModelTests.testEndSession_IncludesRevealsUsed` corrigé** : Le timeout async 5s est résolu. La callback "Saves record with revealsUsed" est déclenchée dans le test.

9. **AC9 — `StatsPerConstantTests.testAddSessionRecordUpdatesBestStreakLocally` corrigé** : `bestStreak` retourne 50 (et non 0) après `addSessionRecord`. API `StatsPerConstant` ou mock resynchronisé.

10. **AC10 — `AtmosphericFeedbackTests` (2 tests) corrigés** :
    - `testAtmosphericColor_WhenBehind_ReturnsOrange` : appelle `ghostEngine?.start()` avant `atmosphericColor(at: futureDate)` → delta > 0 → `.orangeElectric`.
    - `testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity` : utilise `processInput(1)` (premier chiffre décimal de Pi) au lieu de `processInput(3)` → effectivePosition=1, opacity≈0.08.
    - Les `XCTSkip` sont retirés et remplacés par des assertions valides.

11. **AC11 — 0 nouvelles failures** : `xcodebuild test` ne régresse sur aucun test qui passait avant cette story.

## Tasks / Subtasks

### Lot A — Code Polish

- [x] **Task 1 — CR-3 MUS perf** (AC: #1)
  - [x] 1.1 Vérifier `testPerformance_CalculateMUS` — lire le test et noter les limites XCTMetric actuelles
  - [x] 1.2 Exécuter le test de performance sur simulateur — noter le temps moyen (~0.637s, acceptable)
  - [x] 1.3 Si perf acceptable → ajouter commentaire `// O(n³) — monitoré via testPerformance_CalculateMUS, perf acceptable` dans `calculateMUS`
  - [x] 1.4 Si perf inacceptable → implémenter optimisation (rolling hash ou suffix array) [N/A — perf acceptable]

- [x] **Task 2 — CR-7 LightningBranch flicker** (AC: #2)
  - [x] 2.1 Lire `DoubleBangView.swift` — localiser `LightningBranch.init` et `path(in:)`
  - [x] 2.2 Déplacer la génération de points aléatoires de `path(in:)` vers `init(at:)` : stocker dans `self.relativeOffsets`
  - [x] 2.3 `path(in:)` n'utilise que `self.relativeOffsets` (pas de `CGFloat.random` dans le render path)
  - [x] 2.4 Vérifier que l'animation `DoubleBangView` fonctionne correctement en test unitaire ou sur simulateur

- [x] **Task 3 — CR-8 & CR-9 Vérifications** (AC: #3, #4)
  - [x] 3.1 Grep `"// Derived properties"` dans `ChallengeViewModel.swift` → **1 seule occurrence** — CR-8 déjà résolu
  - [x] 3.2 Grep `constantTitle` dans tous les fichiers Swift → **0 résultats** — CR-9 déjà résolu
  - [x] 3.3 Dans tous les cas → les AC #3 et #4 sont satisfaits (résolution antérieure confirmée)

- [x] **Task 4 — CR-11 XPProgressBar** (AC: #5)
  - [x] 4.1 Lire `XPProgressBar.swift` — localiser `var progress: Double`
  - [x] 4.2 Extraire le dictionnaire `ranges` en `private static let xpRanges: [Grade: ClosedRange<Double>]`
  - [x] 4.3 Mettre à jour `var progress: Double` pour utiliser `XPProgressBar.xpRanges`
  - [x] 4.4 Vérifier que les tests existants de `XPProgressBar` (si présents) passent toujours [pas de tests dédiés]

### Lot B — Test Repair

- [x] **Task 5 — Supprimer StreakFlowTests** (AC: #6)
  - [x] 5.1 Confirmer que `StreakFlowTests.swift` ne teste que des features Story 2.3 jamais implémentées
  - [x] 5.2 Supprimer le fichier `PiTrainer/PiTrainerTests/StreakFlowTests.swift`
  - [x] 5.3 Vérifier que le build compile (Xcode 16 sync groups : suppression de fichier = suppression auto)

- [x] **Task 6 — SessionViewModelTests** (AC: #7, #8)
  - [x] 6.1 Lire `SessionViewModelTests.swift` ≈ligne 235 (`testConfigureForChallenge_SetsEngineParameters`)
  - [x] 6.2 Lire `SessionViewModel.swift` lignes 677-686 (`configureForChallenge`) — déjà documenté en Dev Notes
  - [x] 6.3 Décider la correction selon le design correct → **Option A choisie** (test faux) : corrigé pour `startIndex=105, endIndex=110, selectedMode==.game`
  - [x] 6.4 Lire `testEndSession_IncludesRevealsUsed` — cause : `endSession()` ne sauvegarde que si `engine.attempts > 0`
  - [x] 6.5 Corriger le test : ajout de `viewModel.processInput(1)` avant `reveal(count: 5)` pour générer un attempt
  - [x] 6.6 Valider que les 7 tests de `SessionViewModelTests` passent ✓

- [x] **Task 7 — StatsPerConstantTests** (AC: #9)
  - [x] 7.1 Lire `StatsPerConstantTests.swift` — localiser `testAddSessionRecordUpdatesBestStreakLocally`
  - [x] 7.2 Identifier pourquoi `bestStreak` retourne 0 : `addSessionRecord()` a un guard `isCertified == true`
  - [x] 7.3 Corriger le test : ajout de `isCertified: true` aux deux records
  - [x] 7.4 Valider que les 2 tests de `StatsPerConstantTests` passent ✓

- [x] **Task 8 — AtmosphericFeedbackTests** (AC: #10)
  - [x] 8.1 Lire `AtmosphericFeedbackTests.swift` — localiser les 2 tests XCTSkipped
  - [x] 8.2 Fix `testAtmosphericColor_WhenBehind_ReturnsOrange` :
    - Retirer le `throw XCTSkip` ✓
    - Appeler `viewModel.ghostEngine?.start()` avant `atmosphericColor(at: futureDate)` ✓
    - Vérifier l'assertion `.orangeElectric` ✓
  - [x] 8.3 Fix `testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity` :
    - Retirer le `throw XCTSkip` ✓
    - Remplacer `processInput(3)` par `processInput(1)` (premier chiffre décimal de Pi) ✓
    - Vérifier l'assertion opacity≈0.08 ✓
  - [x] 8.4 Supprimer les commentaires `// PRESERVED FOR REFERENCE` des blocs morts ✓

- [x] **Task 9 — Validation Finale** (AC: #11)
  - [x] 9.1 Valider chaque lot en isolation (depuis `PiTrainer/`) :
    ```bash
    # Suites unit tests impactées
    xcodebuild test -scheme PiTrainer -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      -only-testing:PiTrainerTests/SessionViewModelTests \
      -only-testing:PiTrainerTests/StatsPerConstantTests \
      -only-testing:PiTrainerTests/AtmosphericFeedbackTests \
      -only-testing:PiTrainerTests/ChallengeServiceTests \
      | grep -E "(passed|failed|skipped)"
    ```
  - [x] 9.2 Valider run complet unit tests (0 nouvelles failures) :
    ```bash
    xcodebuild test -scheme PiTrainer -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      -only-testing:PiTrainerTests \
      | grep -E "(Test Suite|passed|failed)"
    ```
  - [x] 9.3 Confirmer que `StreakFlowTests` n'apparaît plus dans le rapport (fichier supprimé) ✓

## Dev Notes

### Architecture et contraintes

- **Xcode 16 Synchronized Groups** : La suppression d'un fichier `.swift` dans `PiTrainer/PiTrainerTests/` suffit — pas de modification de `project.pbxproj` nécessaire.
- **`@Observable` / `@MainActor`** : `SessionViewModel` est `@MainActor`. Les tests unitaires qui l'instancient doivent être `@MainActor` ou utiliser `await MainActor.run { }`.
- **`FallbackData.pi`** : commence à `"1415926535..."` — le premier chiffre décimal est `"1"` (pas `"3"`). La partie entière `3.` n'est **pas** dans `FallbackData`.
- **`ghostEngine?.start()`** : uniquement appelé dans `processInput()` lors de la première saisie. Un test qui ne saisit aucun chiffre a `ghostEngine.position(at:) == 0` à tout instant. La propriété est déclarée `var ghostEngine: GhostEngine?` (modificateur `internal` par défaut) dans `SessionViewModel.swift` ligne 30 — **accessible directement** depuis `AtmosphericFeedbackTests` via `@testable import PiTrainer`. Pas besoin de mock ni d'indirection.

### CR-3 — MUS Algorithm Context

```swift
// ChallengeService.swift — calculateMUS + isUnique (approx. lignes 48-85)
// Complexité O(n) positions × O(n) scan × O(length) comparaison = O(n³) worst case
// Perf actuelle testée via testPerformance_CalculateMUS (XCTestCase.measure)
// Optimisation potentielle : suffix array O(n log n) ou rolling hash O(n²)
```

### CR-7 — LightningBranch Fix Pattern

**Call-site unique** : `DoubleBangView.swift` ligne 69 → `LightningBranch(at: now)` — la signature actuelle ne prend **pas** de `CGSize`.

**Approche recommandée : offsets relatifs** (évite de changer la signature de `init` et le call-site) :

```swift
// AVANT (path génère des points aléatoires à chaque frame → flicker visuel)
struct LightningBranch {
    // ...
    func path(in size: CGSize) -> Path {
        for i in 1...steps {
            let segmentX = cos(angle) * totalLength * progress + CGFloat.random(in: -20...20) // ← rand par frame
            let segmentY = sin(angle) * totalLength * progress + CGFloat.random(in: -20...20) // ← rand par frame
        }
    }
}

// APRÈS (offsets pré-calculés dans init, scalés dans path) — init(at:) inchangé
struct LightningBranch {
    var relativeOffsets: [(dx: CGFloat, dy: CGFloat)]  // ← nouveau champ
    var angle: Double                                   // ← nouveau champ

    init(at now: TimeInterval) {
        self.startTime = now
        // Pré-calculer une fois les offsets aléatoires (-1...1 range)
        let steps = 10
        self.angle = Double.random(in: 0...(2 * .pi))
        self.relativeOffsets = (1...steps).map { _ in
            (dx: CGFloat.random(in: -1...1), dy: CGFloat.random(in: -1...1))
        }
    }

    func path(in size: CGSize) -> Path {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let totalLength = min(size.width, size.height) * 0.4
        var path = Path()
        path.move(to: center)
        for (i, offset) in relativeOffsets.enumerated() {
            let progress = CGFloat(i + 1) / CGFloat(relativeOffsets.count)
            let x = center.x + cos(angle) * totalLength * progress + offset.dx * 20
            let y = center.y + sin(angle) * totalLength * progress + offset.dy * 20
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}
```

> Le call-site `LightningBranch(at: now)` reste **inchangé**. Seul `DoubleBangView.swift` est modifié (struct + call-site au même endroit).

### CR-11 — XPProgressBar Fix Pattern

```swift
// AVANT (dict recréé à chaque appel)
var progress: Double {
    let ranges: [Grade: ClosedRange<Double>] = [...]  // ← allocation à chaque fois
}

// APRÈS (static let — alloué une seule fois)
private static let xpRanges: [Grade: ClosedRange<Double>] = [
    .novice: 0...1000,
    .apprentice: 1000...5000,
    .athlete: 5000...20000,
    .expert: 20000...100000,
    .grandmaster: 100000...1000000
]

var progress: Double {
    guard let range = XPProgressBar.xpRanges[grade] else { return 0 }
    ...
}
```

### SessionViewModelTests — Contexte du delta

**Fichier exact** : `PiTrainer/PiTrainer/SessionViewModel.swift` lignes 677-686

```swift
func configureForChallenge(_ challenge: Challenge) {
    self.activeChallenge = challenge
    self.selectedConstant = challenge.constant
    self.selectedMode = .game   // ← mode BIEN set à .game ici
    // Pre-fills the reference sequence so the user sees the prompt
    // Engine initialized in startSession() with the correct range
    // to expect only the NEW digits.
    self.typedDigits = challenge.referenceSequence
}
```

**Analyse de la cause racine du delta :**
- `selectedMode = .game` est SET dans `configureForChallenge()` — mais le test obtient `mode == LEARN`.
- Hypothèse : `startSession()` (appelé après dans le test) réinitialise `selectedMode` à `.learn` (valeur par défaut).
- Le test appelle : `viewModel.configureForChallenge(challenge)` puis `viewModel.startSession()`.
- `typedDigits = challenge.referenceSequence` → `startSession()` calcule `startIndex = startIndex + referenceSequence.count` (105) parce qu'il interprète `typedDigits.count` comme le point de départ dans la séquence.

**Décision attendue du dev** :
- Si le design correct est que l'engine démarre APRÈS la référence (100+5=105) → le test est FAUX, corriger le test.
- Si le design correct est que l'engine démarre AU début du challenge (100) → l'implémentation est FAUSSE, corriger `startSession()`.
- Lire les commentaires et la Story 15.2 pour trancher. Documenter la décision dans Completion Notes.

### AtmosphericFeedbackTests — Fixes précis

```swift
// testAtmosphericColor_WhenBehind_ReturnsOrange — fix
func testAtmosphericColor_WhenBehind_ReturnsOrange() {
    // PAS de throw XCTSkip
    // Ghost doit être démarré pour que sa position avance
    viewModel.ghostEngine?.start()  // ← ajout

    let futureDate = Date().addingTimeInterval(10)
    let color = viewModel.atmosphericColor(at: futureDate)
    XCTAssertEqual(color, DesignSystem.Colors.orangeElectric)
}

// testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity — fix
func testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity() {
    // PAS de throw XCTSkip
    viewModel.processInput(1)  // ← "1" est le premier chiffre décimal de Pi (pas "3")
    let opacity = viewModel.atmosphericOpacity(at: Date())
    XCTAssertEqual(opacity, 0.08, accuracy: 0.01)
}
```

### Fichiers attendus à modifier

| Fichier | Raison |
|:---|:---|
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift` | CR-3 (commentaire ou optimisation) |
| `PiTrainer/PiTrainer/Shared/DoubleBangView.swift` | CR-7 (pre-calc lightning points) |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift` | CR-8 (vérification commentaire) |
| `PiTrainer/PiTrainer/HomeView.swift` | CR-9 (vérification constantTitle) |
| `PiTrainer/PiTrainer/Features/Home/Components/XPProgressBar.swift` | CR-11 (static let xpRanges) |
| `PiTrainer/PiTrainerTests/StreakFlowTests.swift` | **Suppression** |
| `PiTrainer/PiTrainerTests/SessionViewModelTests.swift` | Fix 2 tests |
| `PiTrainer/PiTrainerTests/StatsPerConstantTests.swift` | Fix 1 test |
| `PiTrainer/PiTrainerTests/AtmosphericFeedbackTests.swift` | Fix 2 tests (retirer XCTSkip) |

### Project Structure Notes

- Tous les fichiers sources sont dans `PiTrainer/PiTrainer/` (Xcode 16 Synchronized Groups — automatique)
- Les tests sont dans `PiTrainer/PiTrainerTests/` (synced également)
- Suppression de fichier Swift = suffisant, pas de modification `.pbxproj`

### References

- [Source: epic-15-consolidation.md#Story-15.5](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-15-consolidation.md)
- [Source: 15-4-out-of-scope-failures.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/15-4-out-of-scope-failures.md)
- [Source: project-context.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/project-context.md)
- [Source: DoubleBangView.swift — LightningBranch.init + path(in:)]
- [Source: ChallengeService.swift — calculateMUS + isUnique]
- [Source: XPProgressBar.swift — var progress]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Parallel testing flakiness (Clone simulator app launch failures `FBSOpenApplicationServiceErrorDomain`) → validé avec `-parallel-testing-enabled NO`
- Simulator stuck "Busy" entre runs → résolu via `pkill -f PiTrainer && xcrun simctl shutdown all`
- 10 failures pré-existantes confirmées par cross-reference avec `15-4-test-repair.md` et `15-4-out-of-scope-failures.md` (PersonalBestStoreTests, PositionTrackerTests, ProPadViewModelTests, SessionViewModelIntegrationTests) — hors-scope story 15.5

### Completion Notes List

- **CR-3** : `testPerformance_CalculateMUS` tourne à ~0.637s sur simulateur — performance acceptable. Commentaire monitoring ajouté dans `calculateMUS`.
- **CR-7** : `var points: [CGPoint] = []` était déclaré mais jamais utilisé. Remplacé par `var relativeOffsets: [(dx: CGFloat, dy: CGFloat)]` pré-calculés dans `init(at:)`. `path(in:)` utilise uniquement `self.relativeOffsets` et `self.angle` — zéro `CGFloat.random` lors du render.
- **CR-8** : Grep confirme 1 seule occurrence de `"// Derived properties"` dans `ChallengeViewModel.swift` — déjà résolu antérieurement, aucun fichier modifié.
- **CR-9** : Grep confirme 0 occurrence de `constantTitle` dans tous les fichiers Swift — déjà résolu antérieurement, aucun fichier modifié.
- **CR-11** : Dict `ranges` extrait en `private static let xpRanges` — alloué une seule fois au niveau classe.
- **Task 6 / AC7 — Option A choisie** : Le design correct est que l'engine démarre APRÈS la séquence de référence (`startIndex = challenge.startIndex + referenceSequence.count = 105`). Le test était faux, pas l'implémentation. `SessionMode.game.practiceEngineMode == .learning` (bridge dans SessionMode.swift) — l'assertion a été changée de `practiceEngineMode == .game` à `selectedMode == .game`.
- **Task 6 / AC8** : `endSession()` a un guard `engine.attempts > 0` qui bloquait la sauvegarde. Fix : ajout de `viewModel.processInput(1)` avant `reveal(count: 5)` dans le test.
- **Task 7 / AC9** : `addSessionRecord()` n'update `bestStreak` que si `record.isCertified == true`. Les records de test avaient `isCertified` par défaut à `false`. Fix : ajout explicite de `isCertified: true`.
- **Task 8 / AC10** : `FallbackData.pi` commence à `"1415926535..."` (pas `"3"`). `processInput(3)` était incorrect — remplacé par `processInput(1)`. `ghostEngine?.start()` doit être appelé explicitement dans les tests qui ne passent pas par `processInput()` (il est normalement déclenché sur le premier chiffre saisi).

### File List

| Fichier | Action |
|:---|:---|
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift` | Modifié — commentaire O(n³) monitoring ajouté |
| `PiTrainer/PiTrainer/Shared/DoubleBangView.swift` | Modifié — `LightningBranch` refactoré (relativeOffsets pré-calculés) |
| `PiTrainer/PiTrainer/Features/Home/Components/XPProgressBar.swift` | Modifié — `private static let xpRanges` extrait |
| `PiTrainer/PiTrainerTests/StreakFlowTests.swift` | **Supprimé** |
| `PiTrainer/PiTrainerTests/SessionViewModelTests.swift` | Modifié — 2 tests corrigés (configureForChallenge, endSession) |
| `PiTrainer/PiTrainerTests/StatsPerConstantTests.swift` | Modifié — `isCertified: true` ajouté aux records |
| `PiTrainer/PiTrainerTests/AtmosphericFeedbackTests.swift` | Modifié — 2 XCTSkip retirés, assertions corrigées |

### Change Log

| Date | Change |
|:---|:---|
| 2026-02-21 | Story implémentée : 5 items CR polish (Lot A) + 5 suites test repair (Lot B). 0 nouvelles failures introduites. |
| 2026-02-21 | Code review adversariale (claude-opus-4-6) : 0 High, 1 Medium, 4 Low. 4 fixes appliqués (AC2 texte aligné, commentaire RED périmé, debug prints supprimés, cos/sin hoisté). Status → done. |
