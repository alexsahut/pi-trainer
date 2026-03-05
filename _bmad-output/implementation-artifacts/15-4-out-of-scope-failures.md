# Story 15-4 — Failures hors-scope découvertes

Date de découverte : 2026-02-21
Découvertes lors de l'exécution de la validation AC3 de story 15-4.
**Ces failures ne font PAS partie des 10 tests listés dans story 15-4** — elles nécessitent une story dédiée.

---

## Résumé

| Suite | Tests | Failures | Cause probable |
|:---|:---:|:---:|:---|
| `StreakFlowTests` | 6 | 11 | Tests pour Story 2.3 (StreakFlowViewModel jamais implémenté) — obsolètes |
| `SessionViewModelTests` | 7 | 4 | API désynchronisée (configureForChallenge params, async timeout) |
| `StatsPerConstantTests` | 2 | 2 | API désynchronisée (bestStreak retourne 0 au lieu de 50) |
| `AtmosphericFeedbackTests` | 6 | 2 | Bugs pré-existants dans les tests (digit Pi incorrect, ghost non démarré) — *XCTSkipped dans story 15-4* |

---

## Détail par suite

### StreakFlowTests (6 tests, 11 assertions) — OBSOLÈTES

Tous les messages d'erreur contiennent `"Story 2.3 not implemented"`. `StreakFlowViewModel` n'a jamais été créé.

| Test | Assertion échouée |
|:---|:---|
| `testStreakFlow_NoActivationBelow10` | streak=0 ≠ 9 ; "StreakFlowViewModel does not exist" |
| `testStreakFlow_ActivatesAt10` | streak=0 ≠ 10 ; "StreakFlowViewModel level 1 not implemented" |
| `testStreakFlow_IntensifiesAt20` | streak=0 ≠ 19 ; streak=0 ≠ 20 ; "level 2 not implemented" |
| `testStreakFlow_DeactivatesOnError` | streak=0 ≠ 10 ; "error handling not tested" |
| `testStreakFlow_LevelCalculation` | "level calculation not implemented" |
| `testStreakFlow_AnimationPerformance` | "animation performance test cannot run" |

**Recommandation :** Supprimer `StreakFlowTests.swift` (feature jamais implémentée, tests obsolètes depuis Story 2.3).

---

### SessionViewModelTests (2 tests failing sur 7)

**`testConfigureForChallenge_SetsEngineParameters`** (ligne 251-253) :
- `engine.startIndex` : `105` ≠ `100`
- `engine.endIndex` : `Optional(110)` ≠ `Optional(105)`
- `engine.mode` : `LEARN` ≠ `GAME`

Cause probable : `configureForChallenge()` a été modifiée (paramètres ou logique de calcul des indices), le test n'a pas suivi.

**`testEndSession_IncludesRevealsUsed`** (ligne 215) :
- Timeout async 5s — `"Saves record with revealsUsed"` jamais fulfillé.

Cause probable : La logique `endSession()` ou le mock de persistence ne déclenche plus la callback attendue dans le test.

---

### StatsPerConstantTests (2 tests failing sur 2)

**`testAddSessionRecordUpdatesBestStreakLocally`** (lignes 118, 141) :
- `bestStreak` : `0` ≠ `50`

Cause probable : API de `StatsPerConstant` ou du mock désynchronisée — `bestStreak` n'est plus mis à jour lors de `addSessionRecord`.

---

### AtmosphericFeedbackTests (2 tests — XCTSkipped dans story 15-4)

Ces 2 tests ont été marqués `XCTSkip` dans story 15-4 car ils contiennent des **bugs pré-existants dans les tests** :

**`testAtmosphericColor_WhenBehind_ReturnsOrange`** :
- Le test ne tape aucun chiffre → `ghostEngine?.start()` jamais appelé → ghost position = 0 à tout instant → delta = 0 → `.clear` au lieu de `.orangeElectric`.

**`testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity`** :
- Le commentaire dit `"3" is first digit of Pi` mais `FallbackData.pi` commence par `"1415926535..."` (partie décimale sans le `3` entier). `processInput(3)` est une mauvaise saisie → effectivePosition = 0 → delta = 0 → opacity = 0.0 au lieu de 0.08.

**Recommandation :** Corriger les 2 tests pour :
1. Utiliser `processInput(1)` (premier chiffre décimal de Pi)
2. Appeler `viewModel.ghostEngine?.start()` avant `atmosphericColor(at: futureDate)` pour simuler un ghost en cours

---

## Action requise

Créer une **story 15-5 (ou 15-6)** pour :
- [ ] Supprimer `StreakFlowTests.swift` (tests obsolètes Story 2.3)
- [ ] Corriger `SessionViewModelTests.testConfigureForChallenge_SetsEngineParameters`
- [ ] Corriger `SessionViewModelTests.testEndSession_IncludesRevealsUsed`
- [ ] Corriger `StatsPerConstantTests.testAddSessionRecordUpdatesBestStreakLocally`
- [ ] Corriger `AtmosphericFeedbackTests` (2 tests, bugs de logique)
