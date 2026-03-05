# Story 17.2: Vue Challenge avec affichage MUS en bloc de 10 et dévoilement 👁

Status: done

## Story

As a **utilisateur**,
I want **voir la MUS du challenge affichée à sa vraie position dans un bloc de 10 décimales et pouvoir révéler les décimales suivantes une par une avec le bouton oeil**,
so that **je puisse reconnaître la séquence à mon rythme grâce à des repères visuels familiers**.

## Acceptance Criteria

1. **AC1 — Affichage MUS en bloc de 10** : Quand un challenge est actif, la MUS apparaît dans un `TerminalGridView` standard (bloc de 10) à sa position exacte dans la séquence (utilisant `blockStartIndex` et `musOffsetInBlock` de Story 17.1). Les décimales hors-MUS du bloc sont masquées (placeholders `·`).

2. **AC2 — Bouton oeil (👁) et reveal progressif** : L'utilisateur peut appuyer sur le bouton 👁 (identique au mode Practice) pour révéler la décimale suivante après la MUS. Chaque tap révèle une seule décimale du `revealPool`. Long-press révèle la rangée complète.

3. **AC3 — Compteur d'indices** : Un compteur "Indices : 0" est visible et s'incrémente à chaque décimale révélée.

4. **AC4 — Extension multi-blocs** : Si la révélation dépasse le bloc de 10 courant, un nouveau bloc de 10 apparaît en dessous (scroll naturel).

5. **AC5 — Pas de contrainte de temps** : L'utilisateur a tout son temps pour réfléchir. Aucun timer ni pression temporelle.

6. **AC6 — Tests** : Tests unitaires du ViewModel couvrant le tracking des reveals, le compteur d'indices, et les limites du pool.

## Tasks / Subtasks

- [x] Task 1 — Refactorer ChallengeViewModel pour le mode reveal (AC: #1, #2, #3, #5)
  - [x] 1.1 Ajouter état `revealedCount: Int` — nombre d'indices révélés
  - [x] 1.2 Ajouter computed `visibleDigits: String` — MUS + décimales révélées du pool
  - [x] 1.3 Ajouter `revealNextDigit()` — révèle 1 décimale du `revealPool`, incrémente compteur
  - [x] 1.4 Ajouter `revealDigits(count:)` — révèle N décimales (utilisé par callback TerminalGridView)
  - [x] 1.5 Ajouter computed `canReveal: Bool` — true si revealedCount < revealPool.count
- [x] Task 2 — Adapter ChallengeSessionView pour utiliser TerminalGridView (AC: #1, #2, #4)
  - [x] 2.1 Remplacer l'affichage texte actuel (prompt + target) par TerminalGridView
  - [x] 2.2 Configurer TerminalGridView avec : `startOffset = blockStartIndex`, `fullDigits` = padding + MUS + pool
  - [x] 2.3 Activer `allowsReveal = canReveal` et connecter `onReveal` au ViewModel
  - [x] 2.4 Masquer le KeypadView (pas de saisie dans cette phase — Story 17.3)
  - [x] 2.5 Afficher le compteur d'indices en haut de l'écran
- [x] Task 3 — Bouton "Je sais !" placeholder (AC: #5)
  - [x] 3.1 Ajouter un bouton "JE SAIS !" visible sous la grille (non fonctionnel — Story 17.3)
  - [x] 3.2 Le bouton est toujours visible pendant la phase reveal
- [x] Task 4 — Tests unitaires (AC: #6)
  - [x] 4.1 Test: `revealNextDigit()` incrémente `revealedCount` et étend `visibleDigits`
  - [x] 4.2 Test: `revealNextDigit()` ne dépasse pas `revealPool.count`
  - [x] 4.3 Test: `canReveal` retourne false quand pool épuisé
  - [x] 4.4 Test: `visibleDigits` contient la MUS complète + les décimales révélées

## Dev Notes

### Architecture Critique

**Pattern de réutilisation :** Cette story réutilise le `TerminalGridView` existant du mode Practice. Le composant supporte déjà l'affichage en blocs de 10, le bouton oeil, et le reveal progressif. L'enjeu est de l'adapter au contexte Challenge.

#### TerminalGridView — API existante à réutiliser

Fichier : `Features/Practice/TerminalGridView.swift` (362 lignes)

```swift
TerminalGridView(
    typedDigits: String,          // Digits saisis par l'utilisateur
    integerPart: String,          // Partie entière ("3" pour Pi)
    fullDigits: String,           // Séquence complète de référence
    isLearnMode: Bool,            // Affiche overlay transparent
    allowsReveal: Bool,           // Active le bouton 👁
    startOffset: Int,             // Index de début dans la séquence globale
    segmentLength: Int?,          // Longueur du segment affiché
    onReveal: ((Int) -> Void)?,   // Callback quand l'utilisateur révèle
    showErrorReveal: Bool,        // Affiche le digit attendu sur erreur
    showErrorFlash: Bool,         // Flash rouge sur erreur
    wrongInputDigit: Int?,        // Digit erroné saisi
    indulgentErrorIndices: Set<Int>
)
```

**Mécanisme reveal existant** (lignes 157-170) :
- Bouton 👁 en début de rangée
- Tap simple → `revealNextDigit(in: row)` — 1 décimale
- Long-press (0.5s) → `revealFullRow(in: row)` — rangée complète
- State interne : `@State private var revealedDigitsPerRow: [Int: Int]`
- Callback : `onReveal?(count)` à chaque révélation
- Opacité ghost : `DesignSystem.Animations.ghostRevealOpacity = 0.3`

#### ChallengeSessionView — Transformation requise

Fichier actuel : `Features/Challenges/ChallengeSessionView.swift` (168 lignes)

L'écran actuel affiche :
1. Header avec bouton X et titre "FOLLOW THE SEQUENCE"
2. Zone prompt : `viewModel.prompt` (la MUS en texte brut)
3. Zone target : `viewModel.displayTarget` (blancs + digits saisis)
4. `KeypadView` pour saisie

**Transformation Story 17.2 :**
1. Header → garder mais adapter le titre
2. Zone prompt + target → **remplacer par `TerminalGridView`**
3. KeypadView → **masquer** (la saisie arrive en Story 17.3)
4. **Ajouter** : compteur d'indices + bouton "Je sais !"

#### ChallengeViewModel — État reveal

Fichier actuel : `Features/Challenges/ChallengeViewModel.swift` (143 lignes)

**Propriétés à ajouter :**
```swift
// Story 17.2: Progressive reveal state
var revealedCount: Int = 0

var canReveal: Bool {
    revealedCount < challenge.revealPool.count
}

// Digits visibles dans la grille : MUS + décimales révélées
var visibleDigits: String {
    let revealed = String(challenge.revealPool.prefix(revealedCount))
    return challenge.referenceSequence + revealed
}
```

**Méthodes à ajouter :**
```swift
func revealNextDigit() {
    guard canReveal else { return }
    revealedCount += 1
}

func revealDigits(count: Int) {
    // Appelé par le callback onReveal de TerminalGridView
    revealedCount = min(revealedCount + count, challenge.revealPool.count)
}
```

#### Construction du fullDigits pour TerminalGridView

Le `TerminalGridView` attend un `fullDigits` qui est la séquence complète de référence. Pour le challenge, on doit construire cette string de manière à ce que :

1. Les positions 0 à `musOffsetInBlock - 1` du bloc sont des placeholders (digits non affichés)
2. La MUS est affichée à sa position correcte
3. Les décimales du revealPool suivent après la MUS

```swift
// Construire la séquence pour TerminalGridView
// Le TerminalGridView va afficher en blocs de 10 à partir de startOffset
// typedDigits = visibleDigits (MUS + revealed) — traité comme "déjà saisi"
// fullDigits = MUS + revealPool complet — référence pour le reveal ghost
let fullDigits = challenge.referenceSequence + challenge.revealPool
let typedDigits = visibleDigits // MUS + digits révélés
// startOffset = challenge.blockStartIndex
```

**ATTENTION :** Le `TerminalGridView` utilise `startOffset` pour calculer les numéros de ligne. Il faut passer `blockStartIndex` pour que le label "350>" apparaisse correctement.

**ATTENTION :** Le `typedDigits` dans le contexte TerminalGridView représente les digits "validés/visibles". Pour le challenge, la MUS + les digits révélés doivent apparaître comme `typedDigits` (opacité 100%), tandis que les digits non révélés apparaissent en ghost (opacité 0.3) quand le bouton 👁 est utilisé.

#### Adaptations nécessaires de TerminalGridView

Le TerminalGridView actuel affiche les digits depuis l'index 0 du `typedDigits`. Pour le challenge, il faut :

1. **Pré-remplir les positions avant la MUS** avec des placeholders visuels (les décimales du bloc avant la MUS ne sont pas connues par l'utilisateur dans ce contexte)
2. **Distinguer la MUS** des digits révélés visuellement (MUS = pleine opacité, révélés = ghost 0.3)

**Option recommandée :** Passer `typedDigits` = string avec padding de `musOffsetInBlock` placeholders + MUS + revealed. Utiliser le mécanisme `revealedDigitsPerRow` existant pour gérer le reveal.

**Alternative plus simple :** Ne pas modifier TerminalGridView, mais construire les données d'entrée pour simuler le comportement voulu :
- `startOffset = blockStartIndex`
- `typedDigits = padding("·", musOffsetInBlock) + MUS` (les positions avant la MUS sont masquées)
- `fullDigits = padding("·", musOffsetInBlock) + MUS + revealPool`
- `allowsReveal = true`

Le reveal fonctionnera alors naturellement : les digits après le `typedDigits` seront révélés via le bouton 👁, apparaissant en ghost opacity.

### Fichiers impactés

| Fichier | Action |
|---|---|
| `Features/Challenges/ChallengeViewModel.swift` | Modifier : ajouter état reveal, computed properties |
| `Features/Challenges/ChallengeSessionView.swift` | Modifier : remplacer layout par TerminalGridView + compteur + bouton |
| `PiTrainerTests/ChallengeServiceTests.swift` | Ajouter : tests ViewModel reveal |

### KeypadView vs ProPadView

Le challenge utilise actuellement `KeypadView` (120 lignes, dans le root). Le mode Practice utilise `ProPadView` (150 lignes, dans Features/Practice/). Pour la cohérence avec le design (Story 17.3 utilisera le ProPad), ne PAS migrer vers ProPad dans cette story — la Story 17.3 s'en chargera quand le mode saisie sera implémenté.

### Constantes de design

```swift
// DesignSystem existant
DesignSystem.Colors.cyanElectric     // #00F2FF — accent
DesignSystem.Colors.orangeElectric   // #FF6B00 — warnings
DesignSystem.Animations.ghostRevealOpacity  // 0.3
DesignSystem.chunkSize               // 10 (bloc de 10)
```

### Project Structure Notes

- **Pas de nouveau fichier** — modifications dans les fichiers existants du dossier `Features/Challenges/`
- **Réutilisation du `TerminalGridView`** existant dans `Features/Practice/` — pas de copie ni de fork
- **Tests** dans `PiTrainerTests/ChallengeServiceTests.swift` (section existante)
- **Naming :** conventions camelCase du projet, `@Observable` pattern

### Story 17.1 Learnings

- `revealPool` et `expectedNextDigits` commencent au même index (`musEnd`) — overlap intentionnel
- `blockStartIndex = (startIndex / 10) * 10`, `musOffsetInBlock = startIndex % 10`
- Le `poolEnd` est clampé à `min(allDigits.count, highestIndex, musEnd + 20)` — défensif
- E2E validation couvre le revealPool (vérification ASCII digits)
- Tests déterministes préférés aux tests aléatoires single-run

### References

- [Source: _bmad-output/planning-artifacts/epics-challenge-revamp.md — Story 17.2]
- [Source: Features/Practice/TerminalGridView.swift — mécanisme reveal 👁, lignes 157-170]
- [Source: Features/Challenges/ChallengeSessionView.swift — layout actuel à transformer]
- [Source: Features/Challenges/ChallengeViewModel.swift — état actuel à étendre]
- [Source: SessionView.swift — intégration de référence TerminalGridView, lignes 146-161]
- [Source: Shared/Models/SessionMode.swift — permissions reveal, ligne 52]
- [Source: _bmad-output/implementation-artifacts/17-1-*.md — learnings Story 17.1]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Debug Log References
N/A

### Completion Notes List
- ChallengeViewModel extended with progressive reveal state: `revealedCount`, `visibleDigits`, `canReveal`, `hintCount`
- Two reveal methods: `revealNextDigit()` (single) and `revealDigits(count:)` (bulk, used by TerminalGridView callback)
- ChallengeSessionView completely refactored: prompt+target+keypad replaced by TerminalGridView + hint counter + "JE SAIS !" button
- TerminalGridView extended with 3 new opt-in parameters (backward-compatible, default=0/nil): `typedDigitsColumnOffset`, `fullDigitsOffset`, `forcedRowCount`
- `gridTypedDigits` = referenceSequence only (fixed, never grows) — positions before musOffsetInBlock rendered as "·" placeholder
- `gridFullDigits` = padding(musOffsetInBlock) + MUS + revealPool, indexed from 0 via fullDigitsOffset=0
- `gridRowCount` = (musOffset + musLen + revealedCount) / 10 + 1 — grows with reveals to support AC4 multi-block
- Ghost opacity (30%) correctly shown via TerminalGridView's internal `revealedDigitsPerRow` mechanism
- `revealFullRow` corrected for challenge mode: reveals only the available ghost slots (not a fixed 10)
- Eye button hidden when row is visually full (`isRowVisuallyFull`) even if `isComplete` is false
- `allowsReveal` bound to `viewModel.canReveal` — disables eye button when pool exhausted
- Hint counter shows orange color when hints > 0; localization key `challenge.hints %lld` added to xcstrings (EN+FR)
- `challenge.i_know` localization key added to xcstrings (EN: "I KNOW IT!" / FR: "JE SAIS !")
- "JE SAIS !" button is placeholder (no-op) — Story 17.3 will implement input mode
- 8 unit tests added to ChallengeViewModelTests: increment, pool limit, canReveal, visibleDigits, bulk reveal, clamp, empty pool, hint counter
- Total: 74 tests pass (15 ChallengeViewModel, 22 ChallengeService, 4 ChallengeHub, + others), zero regressions post code-review fixes

### File List
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeViewModel.swift` — modified (added reveal state + methods)
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeSessionView.swift` — modified (full UI refactor + code-review fixes)
- `PiTrainer/PiTrainer/Features/Practice/TerminalGridView.swift` — modified (3 new opt-in params for challenge mode)
- `PiTrainer/PiTrainer/Localizable.xcstrings` — modified (added challenge.hints %lld + challenge.i_know keys)
- `PiTrainer/PiTrainerTests/ChallengeViewModelTests.swift` — modified (8 new reveal tests)
