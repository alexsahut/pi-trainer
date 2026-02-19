# Epic 15 : Consolidation & Stabilisation Post-Pause

**Date de création :** 2026-02-19  
**Origine :** Revue complète du projet après 25 jours de pause  
**Branche :** `v2-development`  
**Scope delta :** Epics 9-14 vs TestFlight v2.0 (Epics 1-8)

---

## Objectif

Stabiliser et qualifier le code des Epics 9-14 avant de merger vers `main` et déployer en TestFlight. Cet Epic regroupe les findings de la code review adversariale, des tests unitaires, et des tests manuels sur simulateur.

---

## Story 15.1 : Fix Critique — Sécurité & Crash Prevention

**Priorité : 🔴 Immédiate**

En tant que développeur,
Je veux corriger les crashs potentiels identifiés en code review,
Afin de garantir la stabilité de l'application en production.

### Acceptance Criteria

- [ ] **CR-1 : `ChallengeService.isUnique()` L66** — Remplacer `sequence.first!` par un guard safe
- [ ] **CR-2 : `StatsStore` init fallback L192** — Remplacer `try!` par un store in-memory comme dernier recours
- [ ] **CR-12 : `PracticeEngine.finishSession()`** — Marquer `private` pour correspondre à l'intention documentée

### Tests associés
- Vérifier que `ChallengeService` ne crash pas avec des inputs vides
- Vérifier que `StatsStore` init fonctionne même si filesystem est corrompu

---

## Story 15.2 : Fix Critique — Challenge Mode Cassé (Cold Start)

**Priorité : 🔴 Immédiate**

En tant qu'utilisateur sur une installation fraîche,
Je veux que le Challenge Mode fonctionne correctement dès le départ,
Afin de pouvoir utiliser les Défis Quotidiens sans avoir préalablement progressé.

### Bugs identifiés (Test Manuel)

1. **`highestIndex = 0` sur cold start** → `max(1, 0) = 1` → MUS cherche dans 1 seul byte → challenge incohérent
2. **Séquence affichée ne correspond pas à la réalité Pi** — l'utilisateur voit "64" mais la suite proposée ne correspond pas à la position réelle de "64" dans Pi
3. **Recovery Bridge ("Entraîner cette séquence")** redirige vers un segment qui ne contient pas la séquence échouée

### Acceptance Criteria

- [ ] **Minimum viable `highestIndex`** : Si `highestIndex < seuil_minimum` (ex: 50), le Challenge Mode affiche un message "Complète d'abord X décimales en mode Learn" au lieu de générer un challenge cassé
- [ ] **Validation MUS end-to-end** : Après génération, vérifier que `referenceSequence + expectedNextDigits` correspondent exactement aux décimales de Pi à `startIndex`
- [ ] **Recovery Bridge cohérent** : Le segment proposé dans le Recovery Bridge contient bien la séquence de référence du challenge échoué
- [ ] **Tests unitaires** : Ajouter test pour `highestIndex = 0`, `highestIndex = 5`, `highestIndex = 100`

---

## Story 15.3 : Fix UI & UX — Keypad et Réglages

**Priorité : 🟠 Haute**

En tant qu'utilisateur,
Je veux que l'interface soit cohérente et fonctionnelle,
Afin de ne pas rencontrer de problèmes visuels ou de réglages qui ne marchent pas.

### Bugs identifiés

1. **Bouton RESET déborde** — Le texte localisé dépasse la frame du `KeypadButton`
2. **Toggle clavier PC/Téléphone** — Le changement dans Réglages ne se reflète pas immédiatement dans les Sessions/Challenges
3. **CR-4 : Navigation par `DispatchQueue.main.asyncAfter`** — Anti-pattern fragile dans `ChallengeSessionView` (2.5s et 0.3s delays)
4. **CR-5 : Instanciation inline de services** — `ChallengeService` recréé à chaque navigation dans `HomeView`
5. **CR-6 : `StatsStore.shared` en dur** — dans `ChallengeSessionView` au lieu d'injection
6. **CR-10 : Textes non localisés** — "CHALLENGES", "TRAIN NOW", "Unlimited practice...", "XP" en dur

### Acceptance Criteria

- [ ] `KeypadButton` adapte sa font size ou utilise `.minimumScaleFactor` pour les labels longs
- [ ] Le changement de keypad layout se reflète immédiatement dans toutes les vues (observation réactive)
- [ ] Remplacer `asyncAfter` par `Task.sleep` annulable pour la navigation post-challenge
- [ ] Tous les textes visibles dans Challenge Hub/Session passent par `String(localized:)`

---

## Story 15.4 : Réparation des Tests Unitaires

**Priorité : 🟠 Haute**

En tant que développeur,
Je veux que la suite de tests passe à 100%,
Afin de pouvoir valider les futures modifications en confiance.

### Tests échoués (24 tests dans 12 suites)

| Suite | Nb Échecs | Cause probable |
|:---|:---:|:---|
| StreakFlowTests | 6 | API `StreakFlowEffect` changée depuis Epic 9 |
| ProPadViewModelTests | 5 | Init/API changé, timers asynchrones |
| SessionViewModelTests | 4 | Certification, Challenge config, init mismatch |
| AtmosphericFeedbackTests | 2 | Seuils couleur/opacité modifiés |
| HorizonLineTests | 2 | API `effectivePosition`/`progressRatios` changée |
| SessionViewModelIntegrationTests | 2 | Certification GameMode init |
| PracticeEngineTests | 2 | Learning mode advance + persistence mock |
| StatsStoreTests | 1 | DoubleBang trigger conditions |
| StatsPerConstantTests | 1 | BestStreak update path |
| SessionHistoryTests | 1 | FIFO limit timing |
| SessionViewModelLoopResetTests | 1 | LoopReset state |
| RegressionTests (UI) | 1 | First digit visibility |

### Acceptance Criteria

- [ ] Tous les 24 tests échoués sont corrigés ou explicitement supprimés (si test devenu obsolète)
- [ ] `xcodebuild test` passe à 100% sur iPhone 17 Pro / iOS 26.2
- [ ] Aucune régression sur les ~70 tests qui passent actuellement

---

## Story 15.5 (Optionnelle) : Polish Technique

**Priorité : 🟡 Moyenne**

Corrections de qualité de code issues de la review adversariale.

### Items

- [ ] **CR-3 : MUS O(n³)** — Monitorer la perf, optimiser si nécessaire (suffix array)
- [ ] **CR-7 : Lightning flicker** — Pré-calculer les points dans `LightningBranch.init`
- [ ] **CR-8 : Commentaire dupliqué** — "Derived properties" dans `ChallengeViewModel`
- [ ] **CR-9 : Dead code** — Supprimer `constantTitle` dans `HomeView`
- [ ] **CR-11 : XPProgressBar dict** — Optimiser la computed property `progress`

---

## Plan d'Exécution Recommandé

```
15.1 (Crash Prevention) → 15.2 (Challenge Fix) → 15.3 (UI/UX) → 15.4 (Tests) → 15.5 (Polish)
```

Les Stories 15.1 et 15.2 sont **bloquantes** pour tout merge vers `main`.
