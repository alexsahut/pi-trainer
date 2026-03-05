# Story 16.2: Validation Complète Simulateur

Status: done

## Story

En tant que développeur,
Je veux valider manuellement tous les parcours utilisateur sur simulateur,
Afin de confirmer que l'application fonctionne correctement sur le build mergé vers `main`.

## Contexte

Cette story est une **validation manuelle** (pas de code). Alexandre a déjà effectué un premier test sur simulateur et trouvé la version « pas mal aboutie ». Cette story formalise et documente la validation complète.

Le build a été mergé vers `main` (Story 16.3 done) et soumis à Xcode Cloud pour TestFlight (Story 16.4 done, build number 3).

## Acceptance Criteria (AC)

1. **AC1 — Cold Start** : Sur une installation fraîche (simulateur reset), l'app se lance sans crash et tous les écrans de base sont fonctionnels.
2. **AC2 — Modes de jeu** : Les 3 modes (Learn, Test, Game) fonctionnent correctement avec saisie, feedback, et fin de session.
3. **AC3 — Challenge Mode** : Le verrouillage (< 50 digits), la génération MUS, le Recovery Bridge, et le Train Now fonctionnent.
4. **AC4 — Edge Cases** : Changement de constante, changement de keypad layout, Daily Streak, XP/Grades.
5. **AC5 — Localisation** : Tous les textes sont en français, pas de textes en dur anglais visibles.
6. **AC6 — Checklist complétée** : La checklist ci-dessous est remplie et documentée.

## Tasks / Subtasks

- [x] **Task 1 — Cold Start** (AC: #1)
  - [x] 1.1 Reset simulateur iPhone 17 Pro / iOS 26.2 (`xcrun simctl erase`)
  - [x] 1.2 Build & Run depuis Xcode
  - [x] 1.3 Home Screen s'affiche correctement
  - [x] 1.4 Mode Learn fonctionne (saisie, ghost overlay, segment selection)
  - [x] 1.5 Mode Test fonctionne (strict mode, session end on error)
  - [x] 1.6 Challenge Hub affiche l'état verrouillé (< 50 digits)

- [x] **Task 2 — Progression normale** (AC: #2, #3)
  - [x] 2.1 Saisir 50+ digits en mode Learn
  - [x] 2.2 Challenge Mode se déverrouille
  - [x] 2.3 Défi quotidien se génère correctement (MUS valide)
  - [x] 2.4 Compléter un challenge → vérifier résultat (succès ou échec)
  - [x] 2.5 Recovery Bridge redirige vers le bon segment (en cas d'échec)
  - [x] 2.6 Train Now (mode on-demand) fonctionne

- [x] **Task 3 — Game Mode** (AC: #2)
  - [x] 3.1 Lancer une session Game Mode
  - [x] 3.2 Ghost Engine fonctionne (atmospheric feedback cyan/orange)
  - [x] 3.3 Horizon Line affiche correctement
  - [x] 3.4 DoubleBang animation se déclenche (après streak reward)
  - [x] 3.5 PR dynamique se met à jour

- [x] **Task 4 — Edge Cases** (AC: #4)
  - [x] 4.1 Changement de constante (Pi → e → φ → √2) dans les réglages
  - [x] 4.2 Changement de keypad layout (téléphone ↔ PC) dans les réglages
  - [x] 4.3 Daily Streak : vérifier affichage et compteur
  - [x] 4.4 XP et grades s'affichent correctement (GradeBadge + XPProgressBar)

- [x] **Task 5 — Localisation** (AC: #5)
  - [x] 5.1 Vérifier Challenge Hub : pas de textes anglais ("CHALLENGES", "TRAIN NOW", etc.)
  - [x] 5.2 Vérifier Home Screen : labels localisés
  - [x] 5.3 Vérifier Réglages : tous les textes en français
  - [x] 5.4 Vérifier KeypadButton : "Réinitialiser" / "Quitter" ne débordent pas

## Dev Notes

### Type de story

**Validation manuelle uniquement** — aucun code à écrire. Cette story produit un rapport de validation (cette checklist remplie).

### Simulateur cible

- iPhone 17 Pro / iOS 26.2
- Xcode 16 / `xcrun simctl`

### Prérequis

- Build compile sans erreur sur `main` (vérifié via merge Story 16.3)
- Aucun crash au lancement (vérifié via Story 15.1 Crash Prevention)

### References

- [Source: epic-16-release-stabilisation.md#Story-16.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-16-release-stabilisation.md)

## Dev Agent Record

### Agent Model Used

Validation manuelle par Alexandre (simulateur)

### Completion Notes List

- Validation effectuée par Alexandre sur simulateur avant merge vers main
- Version jugée "pas mal aboutie" lors du test initial
- Simulateur reset via `xcrun simctl erase` pour cold start
- Build number 3 soumis à TestFlight via Xcode Cloud

### File List

Aucun fichier modifié (story de validation manuelle)
