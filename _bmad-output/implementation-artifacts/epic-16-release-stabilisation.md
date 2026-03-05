# Epic 16 : Stabilisation Finale & Release TestFlight

**Date de création :** 2026-02-21
**Origine :** Rétrospective Epic 15 (Action Items #2, #3) + pipeline release
**Branche source :** `v2-development`
**Branche cible :** `main`
**Objectif release :** TestFlight v2.0

---

## Objectif

Résoudre les dernières failures de tests, valider l'application sur simulateur, merger vers `main`, et soumettre le build en TestFlight. Cet Epic est le dernier avant la mise en production de la v2.0.

---

## Story 16.1 : Réparation des Tests Restants

**Priorité : 🔴 Immédiate**

En tant que développeur,
Je veux que la suite de tests passe à 100% (0 failures, 0 skips injustifiés),
Afin de pouvoir valider le merge vers `main` en confiance.

### Tests à résoudre

Les failures suivantes ont été découvertes lors de la Story 15.5 (hors-scope) :

| Suite | Cause probable |
|:---|:---|
| `PersonalBestStoreTests` | API désynchronisée depuis Epics 9-14 |
| `PositionTrackerTests` | API `effectivePosition` modifiée |
| `ProPadViewModelTests` | Init/API changé, timers asynchrones |
| `SessionViewModelIntegrationTests` | Certification GameMode init |

### Acceptance Criteria

- [ ] Tous les tests échoués sont corrigés ou explicitement supprimés (si feature obsolète)
- [ ] `xcodebuild test -only-testing:PiTrainerTests` passe à 0 failures sur iPhone 17 Pro / iOS 26.2
- [ ] Les tests UI existants passent (ou XCTSkip justifié maintenu)
- [ ] Aucune régression sur les tests qui passent actuellement
- [ ] Le Dev Agent Record de la Story 15.3 est complété (Action Item retro #1)

---

## Story 16.2 : Validation Complète Simulateur

**Priorité : 🔴 Immédiate**

En tant que développeur,
Je veux valider manuellement tous les parcours utilisateur sur simulateur,
Afin de confirmer que l'application fonctionne correctement avant le merge.

### Scénarios de validation

1. **Cold Start** — Installation fraîche, premier lancement
   - [ ] Home Screen s'affiche correctement
   - [ ] Mode Learn fonctionne (saisie, ghost overlay, segment selection)
   - [ ] Mode Test fonctionne (strict mode, session end on error)
   - [ ] Challenge Hub affiche l'état verrouillé si < 50 digits

2. **Progression normale** — Après avoir saisi 50+ digits
   - [ ] Challenge Mode se déverrouille
   - [ ] Défi quotidien se génère correctement (MUS valide)
   - [ ] Recovery Bridge redirige vers le bon segment
   - [ ] Train Now (mode on-demand) fonctionne

3. **Game Mode** — Session complète
   - [ ] Ghost Engine fonctionne (atmospheric feedback cyan/orange)
   - [ ] Horizon Line affiche correctement
   - [ ] DoubleBang animation se déclenche
   - [ ] PR dynamique se met à jour

4. **Edge Cases**
   - [ ] Changement de constante (Pi → e → φ → √2)
   - [ ] Changement de keypad layout (téléphone ↔ PC)
   - [ ] Daily Streak et notifications
   - [ ] XP et grades s'affichent correctement

5. **Localisation**
   - [ ] Tous les textes affichés en français (pas de textes en dur anglais)
   - [ ] Labels Challenge Hub localisés

### Acceptance Criteria

- [ ] Tous les scénarios ci-dessus sont validés sur iPhone 17 Pro / iOS 26.2
- [ ] Aucun crash ou comportement inattendu
- [ ] Checklist de validation complétée et documentée

---

## Story 16.3 : Merge vers `main`

**Priorité : 🔴 Immédiate (après 16.1 et 16.2)**

En tant que développeur,
Je veux merger la branche `v2-development` vers `main`,
Afin de préparer le build release pour TestFlight.

### Acceptance Criteria

- [ ] Toutes les Stories 16.1 et 16.2 sont done
- [ ] `git merge v2-development` sur `main` réussit (conflits résolus si nécessaire)
- [ ] Build compile sur `main` : `xcodebuild build` — BUILD SUCCEEDED
- [ ] Suite de tests passe sur `main` : 0 failures
- [ ] Aucun fichier sensible dans le diff (credentials, .env, etc.)

---

## Story 16.4 : Soumission TestFlight

**Priorité : 🟠 Haute (après 16.3)**

En tant que développeur,
Je veux soumettre le build en TestFlight,
Afin que les testeurs puissent valider la v2.0 sur appareil réel.

### Acceptance Criteria

- [ ] Version et build number incrémentés dans Xcode
- [ ] Archive build réussie (Release config)
- [ ] Upload vers App Store Connect réussi
- [ ] Build disponible en TestFlight pour les testeurs internes

---

## Plan d'Exécution

```
16.1 (Test Repair) → 16.2 (Validation Simulateur) → 16.3 (Merge main) → 16.4 (TestFlight)
```

Les Stories 16.1 et 16.2 sont **bloquantes** pour le merge.
La Story 16.2 peut démarrer en parallèle de 16.1 si les tests n'impactent pas les scénarios manuels.
