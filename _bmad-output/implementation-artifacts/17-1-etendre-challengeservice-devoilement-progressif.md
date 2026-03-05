# Story 17.1: Étendre le ChallengeService pour le dévoilement progressif

Status: done

## Story

As a **développeur**,
I want **le ChallengeService expose la position exacte de la MUS dans la séquence et la séquence complète post-MUS**,
so that **le mécanisme de dévoilement progressif puisse s'appuyer sur des données complètes**.

## Acceptance Criteria

1. **AC1 — Extension du modèle Challenge** : L'objet `Challenge` contient de nouveaux champs : la position de bloc de 10 (row index + offset), et un pool de décimales post-MUS pour le dévoilement progressif.

2. **AC2 — Génération du pool de dévoilement** : Quand un challenge est généré (daily ou random), le service calcule et stocke les décimales disponibles après la MUS pour le dévoilement, dans les limites de l'index connu de l'utilisateur.

3. **AC3 — Scope Guard préservé** : La MUS + pool de dévoilement + zone de saisie potentielle restent dans les limites du `highestKnownIndex` de l'utilisateur (cohérent avec le scope guard de la Story 14.2).

4. **AC4 — Rétro-compatibilité** : Les challenges existants (qui n'ont pas les nouveaux champs) continuent de fonctionner. Les nouveaux champs ont des valeurs par défaut sensées.

5. **AC5 — Tests** : Tests unitaires couvrant la génération du pool de dévoilement, les cas limites (MUS en fin de séquence connue, pool vide), et la rétro-compatibilité.

## Tasks / Subtasks

- [x] Task 1 — Étendre le modèle `Challenge` (AC: #1, #4)
  - [x] 1.1 Ajouter `blockStartIndex: Int` — position de début du bloc de 10 contenant la MUS
  - [x] 1.2 Ajouter `musOffsetInBlock: Int` — offset de la MUS dans son bloc de 10
  - [x] 1.3 Ajouter `revealPool: String` — décimales disponibles après la MUS pour dévoilement
  - [x] 1.4 Fournir des valeurs par défaut pour la rétro-compatibilité Codable (CodingKeys + init(from:) + encode(to:))
- [x] Task 2 — Modifier la génération de challenges (AC: #2, #3)
  - [x] 2.1 Dans `createChallenge()` : calculer `blockStartIndex` et `musOffsetInBlock` à partir de `startIndex`
  - [x] 2.2 Dans `createChallenge()` : construire `revealPool` = décimales post-MUS jusqu'à `min(highestIndex, musEnd + maxRevealPoolSize)`
  - [x] 2.3 Logique partagée via `createChallenge()` — utilisée par daily ET random
  - [x] 2.4 Définir `maxRevealPoolSize = 20` comme constante statique
- [x] Task 3 — Tests unitaires (AC: #5)
  - [x] 3.1 Test: challenge généré contient un `revealPool` non-vide
  - [x] 3.2 Test: `blockStartIndex` et `musOffsetInBlock` sont correctement calculés
  - [x] 3.3 Test: scope guard — le pool ne dépasse pas `highestKnownIndex`
  - [x] 3.4 Test: revealPool matche les vraies décimales (E2E)
  - [x] 3.5 Test: rétro-compatibilité — décodage d'un JSON sans les nouveaux champs
  - [x] 3.6 Test: daily challenge inclut les nouveaux champs

## Dev Notes

### Architecture Critique

**Fichier principal à modifier :** `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift`

#### Modèle Challenge actuel (lignes 3-18)
```swift
struct Challenge: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let constant: Constant
    let startIndex: Int
    let referenceSequence: String    // ← La MUS
    let expectedNextDigits: String   // ← Décimales attendues (grade-based, 3-15 chars)
}
```

**Nouveaux champs à ajouter :**
```swift
struct Challenge: Identifiable, Codable, Hashable {
    // ... champs existants ...
    let blockStartIndex: Int         // NOUVEAU: début du bloc de 10 (arrondi inférieur)
    let musOffsetInBlock: Int        // NOUVEAU: position de la MUS dans le bloc
    let revealPool: String           // NOUVEAU: décimales post-MUS pour dévoilement
}
```

#### Calcul du bloc de 10
```swift
// startIndex = 358 (position absolue dans Pi)
// blockStartIndex = (358 / 10) * 10 = 350
// musOffsetInBlock = 358 - 350 = 8 (position 8 dans le bloc, 0-indexed)
let blockStartIndex = (startIndex / 10) * 10
let musOffsetInBlock = startIndex - blockStartIndex
```

#### Construction du revealPool
Le `revealPool` contient les décimales qui suivent la MUS et qui pourront être dévoilées une par une dans la Story 17.2. Il est distinct de `expectedNextDigits` (qui est ce que l'utilisateur doit taper après avoir cliqué "Je sais !").

```
Position dans Pi:  ... 350  351  352  353  354  355  356  357  [358  359  360] 361  362  363  364 ...
                                                                 └── MUS ──┘   └── revealPool ──┘
                                                                                └── expectedNextDigits (après reveal)
```

**ATTENTION :** Le `revealPool` et `expectedNextDigits` se chevauchent ou se suivent selon le design. Dans la Story 17.2, le reveal dévoile des décimales du pool. Quand l'utilisateur clique "Je sais !", il doit taper les décimales APRÈS le dernier dévoilement. Le `revealPool` doit donc contenir suffisamment de décimales pour permettre le dévoilement + la saisie ultérieure.

**Recommandation :** `revealPool` = toutes les décimales de `startIndex + musLength` jusqu'à la limite du scope, et `expectedNextDigits` n'est plus pré-calculé mais sera déterminé dynamiquement par le ViewModel (Story 17.3) selon le nombre d'indices révélés.

#### Méthode de génération existante (lignes 207-282)
La génération utilise `DigitsProvider.shared.digits(for:)` pour accéder aux décimales sous forme de `[UInt8]`. Le `revealPool` doit utiliser le même provider :

```swift
let allDigits = DigitsProvider.shared.digits(for: constant)
let musEnd = startIndex + musLength
let poolEnd = min(highestKnownIndex, musEnd + maxRevealPoolSize)
let revealPool = String(allDigits[musEnd..<poolEnd].map { Character(UnicodeScalar($0)) })
```

### Scope Guard (Story 14.2 existante)
Le scope guard existant (lignes ~250-270) valide que `startIndex + referenceSequence.count + expectedNextDigits.count <= highestKnownIndex`. Il faut l'étendre pour inclure le `revealPool` :

```swift
// Le pool de dévoilement ne doit pas dépasser l'index connu
guard musEnd + revealPool.count <= highestKnownIndex else { ... }
```

### Rétro-compatibilité Codable
Les challenges précédemment sauvegardés (Daily challenge completion tracking) n'ont pas les nouveaux champs. Utiliser `decodeIfPresent` avec valeurs par défaut :

```swift
init(from decoder: Decoder) throws {
    // ... champs existants ...
    blockStartIndex = try container.decodeIfPresent(Int.self, forKey: .blockStartIndex) ?? 0
    musOffsetInBlock = try container.decodeIfPresent(Int.self, forKey: .musOffsetInBlock) ?? 0
    revealPool = try container.decodeIfPresent(String.self, forKey: .revealPool) ?? ""
}
```

### Project Structure Notes

- **Alignement :** Toutes les modifications sont dans `Features/Challenges/ChallengeService.swift` — pas de nouveau fichier
- **Naming :** Suit les conventions PascalCase/camelCase du projet
- **Tests :** Fichier existant `PiTrainerTests/` — ajouter des tests dans le fichier de test du ChallengeService existant
- **Aucun changement UI** dans cette story — c'est purement backend/service

### Constantes recommandées
```swift
static let maxRevealPoolSize = 20  // Nombre max de décimales dans le pool de dévoilement
```

### Fichiers impactés

| Fichier | Action |
|---|---|
| `Features/Challenges/ChallengeService.swift` | Modifier : étendre Challenge struct + logique génération |
| `PiTrainerTests/ChallengeServiceTests.swift` | Ajouter : tests pour nouveaux champs |

### References

- [Source: _bmad-output/planning-artifacts/epics-challenge-revamp.md — Story 17.1]
- [Source: _bmad-output/planning-artifacts/architecture.md — V2.9 Challenge Service & moteur MUS]
- [Source: PiTrainer/Features/Challenges/ChallengeService.swift — modèle Challenge + algorithme MUS]
- [Source: _bmad-output/planning-artifacts/prd.md — FR12 Daily Challenge]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Debug Log References
N/A

### Completion Notes List
- Challenge struct étendu avec 3 nouveaux champs : `blockStartIndex`, `musOffsetInBlock`, `revealPool`
- Init avec valeurs par défaut (0, 0, "") pour rétro-compatibilité des call sites existants
- Custom Codable : `init(from:)` avec `decodeIfPresent` + `encode(to:)` pour les nouveaux champs
- `createChallenge()` calcule les nouveaux champs — logique partagée entre daily et random
- `maxRevealPoolSize = 20` défini comme constante statique sur `ChallengeService`
- 9 tests ajoutés (7 initiaux + 2 code review), 26/26 tests passent (22 ChallengeService + 4 ChallengeHub), zéro régression

### Code Review Fixes (2026-02-23)
- **H1** : E2E validation étendue au `revealPool` (vérification ASCII digits)
- **H2** : Test edge case ajouté — `testChallenge_RevealPool_EmptyWhenMUSNearEnd`
- **M1** : Commentaires explicatifs restaurés dans `createChallenge()`
- **M2** : Commentaire ajouté sur l'overlap intentionnel `revealPool`/`expectedNextDigits`
- **M3** : Test déterministe ajouté — `testChallenge_BlockStartIndex_Deterministic` avec invariants mathématiques
- **Bonus** : Bug défensif corrigé — `poolEnd` clampé à `allDigits.count` en plus de `highestIndex`

### File List
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift` — modifié
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift` — modifié
