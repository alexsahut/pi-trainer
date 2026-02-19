# Story 11.1: Système de Défis Quotidiens (MUS Algorithm Port)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur fidèle,
I want un défi unique chaque jour basé sur une séquence unique de mon propre record,
so that avoir une raison de revenir quotidiennement, tester ma polyvalence et renforcer ma mémorisation sur mes points faibles.

## Acceptance Criteria

1. [ ] **Algorithme MUS (Minimal Unique Sequence) :** Implémentation fidèle de l'algorithme identifiant la plus petite séquence de chiffres commençant à un index donné qui n'apparaît qu'une seule fois dans la constante (ex: Pi).
2. [ ] **ChallengeService :** Création d'un service Swift encapsulant la logique de génération de défis.
3. [ ] **Génération Déterministe :** Le défi est identique pour tous les utilisateurs ayant le même record à une date donnée (utilisation de la date YYYY-MM-DD comme "seed").
4. [ ] **Bornage du Record :** L'index de départ du défi doit être compris entre 0 et le `highestIndex` atteint par l'utilisateur pour cette constante.
5. [ ] **Performance :** Le calcul de la séquence MUS sur un record de 10 000 chiffres doit s'exécuter en moins de 10ms (objectif < 1ms).
6. [ ] **Sauvegarde :** L'état du défi complété est sauvegardé localement pour éviter de gagner la récompense plusieurs fois par jour (`UserDefaults.standard.set(Date(), forKey: "lastChallengeDate")`).

## Tasks / Subtasks

- [x] **Infrastructure & Modèles** (AC: 2)
  - [x] Créer `Features/Challenges/ChallengeService.swift`.
  - [x] Définir la structure `Challenge` (id, date, constant, startIndex, referenceSequence, expectedNextDigits).
  - [x] Définir le protocole `ChallengeServiceProtocol`.

- [x] **Implémentation Moteur MUS** (AC: 1, 5)
  - [x] Implémenter `calculateMUS(in digits: [Character], at pos: Int) -> Int`.
  - [x] Optimiser la recherche pour éviter les allocations inutiles ou les scans O(N^2) si possible (utiliser `[Character]` ou `[UInt8]`).

- [x] **Logique de Défi Quotidien** (AC: 3, 4, 6)
  - [x] Implémenter `generateDailyChallenge(for constant: Constant, date: Date) -> Challenge?`.
  - [x] Intégrer `PersistenceProvider` pour obtenir le `highestIndex`.
  - [x] Utiliser un générateur de nombres aléatoires basé sur la date.

- [x] **Tests Unitaires & Performance**
  - [x] Créer `PiTrainerTests/ChallengeServiceTests.swift`.
  - [x] Tester avec des séquences connues (ex: Séquence unique de Pi à l'index 0).
  - [x] Ajouter un test `measure` pour valider la performance sur 10k chiffres.

## Dev Notes

### Architecture & Logic Compliance

- **Service Pattern :** Le `ChallengeService` doit être injecté là où il est utilisé.
- **Performance-First :** Utiliser des accès O(1) aux index des chiffres.
- **Xcode 16 Sync :** Créer les fichiers dans `PiTrainer/PiTrainer/Features/Challenges/`.

### Source Logic (Python Reference)
L'algorithme de base à porter est le suivant (corrigé) :
```python
def calculate_mus(decimales, pos):
    n = 1
    while pos + n <= len(decimales):
        sequence = decimales[pos:pos+n]
        # Recherche d'une autre occurrence de la même séquence
        if decimales.count(sequence) == 1:
            return n
        n += 1
    return -1 # Ou gestion d'erreur si aucune séquence unique n'est trouvée
```
*Note : En Swift, évitez `String.count(occurencesOf:)` dans une boucle `while` pour des raisons de performance sur de grandes chaînes. Préférez un scan optimisé.*

### Project Structure Notes

- **New Feature Folder :** `PiTrainer/PiTrainer/Features/Challenges/`
- **Dependency :** Dépend de `DigitsProvider` et `PracticePersistence`.

### References

- [Tech-Spec: MUS Algo Port](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/tech-spec-mus-algo-port.md)
- [Brainstorming MUS 2026-01-23](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/analysis/brainstorming-session-2026-01-23.md)
- [Project Context](file:///Users/alexandre/Dev/antigravity/pi-trainer/project-context.md)

## File List
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift`
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift`
- `PiTrainer/PiTrainer/Core/Persistence/PracticePersistence.swift`

## Dev Agent Record

### Agent Model Used

Antigravity (Claude 3.5 Sonnet)

### Completion Notes List
- Created Story file with MUS algorithm focus.
- Integrated latest tech spec requirements.
- Added performance and determinism constraints.
- [2026-01-24] Implemented `ChallengeService` with `calculateMUS` and `generateDailyChallenge`.
- [2026-01-24] Added `PracticePersistence` support for `lastChallengeDate`.
- [2026-01-24] Implemented `ChallengeServiceTests` covering MUS logic, deterministic generation, and performance.
- Validated Tests exist and cover required scenarios.
