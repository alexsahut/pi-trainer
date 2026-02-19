---
title: 'Portage de l''algorithme MUS (Minimal Unique Sequence)'
slug: 'mus-algo-port'
created: '2026-01-23'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['Swift 5.10+', 'iOS 17.0+', 'XCTest']
files_to_modify: ['Features/Challenges/ChallengeService.swift', 'PiTrainerTests/ChallengeServiceTests.swift']
code_patterns: ['[Nom]Service', 'DigitsProvider protocol', 'PracticePersistenceProtocol', 'Dependency Injection', '@Observable']
test_patterns: ['XCTestCase', 'measure (Performance Benchmarks)', 'Mocking via Protocols']
---

# Tech-Spec: Portage de l'algorithme MUS (Minimal Unique Sequence)

**Created:** 2026-01-23

## Overview

### Problem Statement

Créer des défis de mémorisation personnalisés en identifiant la plus petite séquence unique dans le record de l'utilisateur pour éviter la lassitude et renforcer l'apprentissage ciblé.

### Solution

Portage Swift "ligne à ligne" de l'algorithme Python existant pour garantir la fidélité logique, avec une intégration sous forme de service Swift à valider par l'Architecte.

### Scope

**In Scope:**
- Traduction Swift "ligne à ligne" de l'algorithme Python `f(decimales, pos)`.
- Création du service Swift pour encapsuler l'algorithme.
- Tests unitaires (XCTest) couvrant les cas nominaux et les limites.
- Consultation de l'Architecte pour valider l'emplacement et l'interface du service.

**Out of Scope:**
- Interface utilisateur (UI) des défis quotidiens.
- Système de gestion des XP et des Grades.
- Persistence des défis relevés.

## Context for Development

### Codebase Patterns

- **Service Pattern** : Utilisation du suffixe `Service` (ex: `ChallengeService`).
- **Protocols** : Abstraction via protocoles pour faciliter le test unitaire et le mocking (`DigitsProvider`, `PracticePersistenceProtocol`).
- **Dependency Injection** : Passage des dépendances via l'initialiseur (`init(digitsProvider:persistence:)`).
- **Performance** : Respect strict du budget de <1ms sur le thread principal.

### Files to Reference

| File | Purpose |
| ---- | ------- |
| `DigitsProvider.swift` | Protocole d'accès aux décimales. |
| `Core/Persistence/PracticePersistence.swift` | Persistance du record (`highestIndex`). |
| `_bmad-output/analysis/brainstorming-session-2026-01-23.md` | Résultat du brainstorming sur le défi MUS. |
| `_bmad-output/project-context.md` | Règles de développement et architecture V2. |

### Technical Decisions

- **Architecture** : Création d'un `ChallengeService` autonome situé dans `Features/Challenges/`.
- **Structures & Protocoles** :
    ```swift
    struct Challenge: Codable, Identifiable {
        let id: UUID
        let date: String // YYYY-MM-DD
        let constant: Constant
        let startIndex: Int
        let referenceSequence: String // La séquence MUS identifiée
        let expectedNextDigits: String // Les X chiffres à trouver
    }

    protocol ChallengeServiceProtocol {
        /// Génère le défi unique pour une date donnée (déterministe)
        func generateDailyChallenge(for constant: Constant, date: Date) -> Challenge?
        /// Algorithme MUS pur
        func calculateMUS(in digits: [Character], at pos: Int) -> Int
    }
    ```
- **Déterminisme** : Utiliser la date (`YYYYMMDD`) comme "seed" pour le générateur de nombres aléatoires afin que tous les utilisateurs aient le même défi le même jour.
- **Algorithme** : Transposition du code Python opérant sur `[Character]` pour garantir un accès O(1) aux index et respecter le budget de <1ms.
- **Threading** : L'exécution du scan MUS doit se faire sur une queue à haute priorité (`.userInteractive`) pour éviter tout jitter UI.
- **Consultation** : Validation effectuée avec Winston (Architecte) en Party Mode.

## Implementation Plan

### Tasks

- [ ] Task 1: Création des structures et du protocole `ChallengeServiceProtocol`
  - File: `Features/Challenges/ChallengeService.swift`
  - Action: Définir `Challenge` et `ChallengeServiceProtocol`. Implémenter la méthode `calculateMUS` en transposant l'algorithme Python.
  - Notes: **ATTENTION** : Le script Python source contient une erreur de variable (`liste` au lieu de `decimales`). Utiliser `[Character]` pour les performances.

- [ ] Task 2: Logique de génération déterministe (Daily Seed)
  - File: `Features/Challenges/ChallengeService.swift`
  - Action: Implémenter `generateDailyChallenge`. Utiliser un `SeedableRandomNumberGenerator` (ou transformer la date en seed) pour choisir un `startIndex` entre 0 et `persistence.getHighestIndex`.
  - Notes: Garantir que le défi est identique pour une même date et un même record.

- [ ] Task 3: Couverture de tests unitaires et benchmarks
  - File: `PiTrainerTests/ChallengeServiceTests.swift`
  - Action: Créer des tests pour valider l'unicité des séquences retournées par l'algorithme. Ajouter un test de performance avec `measure`.
  - Notes: Tester avec des séquences connues (ex: "1415926535" à l'index 0 de Pi).

### Acceptance Criteria

- [ ] AC 1: Algorithme MUS fidèle
  - Given: Une séquence de décimales "141592653514159" et une position 0.
  - When: J'appelle l'algorithme MUS.
  - Then: Il retourne la taille de la plus petite séquence unique commençant à 0 qui n'apparaît nulle part ailleurs (ici "141592").

- [ ] AC 2: Génération de défi bornée
  - Given: Un utilisateur avec un record (`highestIndex`) de 500 chiffres.
  - When: Je génère un défi quotidien.
  - Then: L'index de départ du défi est compris entre 0 et 500.

- [ ] AC 3: Performance critique
  - Given: Un record utilisateur de 10 000 chiffres.
  - When: L'algorithme MUS est exécuté sur une position aléatoire.
  - Then: Le temps de calcul est inférieur à 10ms (objectif < 1ms, mais tolérance pour le scan ligne à ligne sur 10k).

- [ ] AC 4: Robustesse aux erreurs
  - Given: Une position (`pos`) supérieure à la longueur des décimales disponibles.
  - When: J'appelle l'algorithme.
  - Then: Le service retourne `nil` (ou lève une erreur explicite) plutôt que de crasher.

## Additional Context

### Dependencies

- `DigitsProvider` : Pour accéder à la chaîne complète des décimales.
- `PracticePersistenceProtocol` : Pour récupérer le `highestIndex`.
- `Constant` : Enum existant définissant Pi, e, etc.

### Testing Strategy

- **Unit Tests** : Validation de la logique pure de `f(decimales:pos:)` via `ChallengeServiceTests`.
- **Performance Tests** : Utilisation de `XCTest.measure` pour monitorer l'impact du scan linéaire.
- **Mocking** : Création d'un `MockDigitsProvider` avec des chaînes courtes contrôlées.

### Notes

- **Risque** : Le scan ligne à ligne sur 10 000 chiffres peut être lent en Swift si on manipule mal les `String.Index`. Amelia devra utiliser une conversion en `[Character]` ou `[UInt8]` pour un accès en O(1) si le coût de `index(_:offsetBy:)` est trop élevé.
- **Évolutivité** : La spec est isolée pour permettre d'ajouter plus tard l'UI et le système d'XP sans modifier le moteur MUS.
