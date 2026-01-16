
# Story 3.0: Architecture Navigation & Redesign Home

**Epic:** 3 - Gestion des Sessions & Mode Strict
**Type:** Technical / UI Enabler
**Status:** Done

## Description
**As a** utilisateur,
**I want** une navigation fluide et cohérente entre l'accueil et la session,
**So that** l'immersion "Zen-Athlete" ne soit jamais brisée par des composants standards ou des bugs de navigation.

Cette story vise à combler le "Navigation Gap" identifié lors de l'analyse de préparation. Elle remplace la `HomeView` temporaire par l'implémentation finale "Zen-Athlete" et sécurise le cycle de vie Start/Stop des sessions.

## Acceptance Criteria

### 1. HomeView "Zen-Athlete" (Design)
- **Given** l'écran d'accueil
- **When** l'application se lance
- **Then** l'interface respecte la charte "Dark & Sharp" (Fond Noir pur, Typo Mono).
- **And** les `Picker` standards iOS sont remplacés par des sélecteurs custom minimalistes.
- **And** le bouton "Start" est l'élément central dominant.

### 2. Architecture de Navigation (Routing)
- **Given** une architecture app basée sur `NavigationStack`
- **When** je lance une session
- **Then** la transition vers `SessionView` est fluide.
- **And** `SessionView` a la capacité technique de demander sa propre fermeture (Callback, Binding, ou Environment).

### 3. Cycle de vie Session (Exit Safety)
- **Given** une session en cours (Mode Zen actif)
- **When** la session se termine (Erreur ou Abandon)
- **Then** l'application revient à l'écran `HomeView` dans un état propre (Reset).
- **And** la barre de navigation système ou les onglets ne sont jamais visibles accidentellement pendant la session.

### 4. Keypad Layout Support (PC vs Phone)
- **Given** les réglages de l'application (Home)
- **When** l'utilisateur choisit le Layout "PC" (Calculatrice) ou "Téléphone"
- **Then** l'ordre des touches du ProPad s'inverse (7-8-9 en haut vs 1-2-3 en haut).
- **And** le choix est persisté entre les lancements.

## Technical Tasks
- [x] Refactor `HomeView.swift` : Supprimer `NavigationView` déprécié si présent, utiliser `NavigationStack`.
- [x] Créer composants UI Custom : `ZenSegmentedControl`, `ZenExampleButton` (implémenté comme `ZenPrimaryButton`).
- [x] Implémenter le `SessionCoordinator` ou équivalent simple pour gérer le dismiss.
- [x] Vérifier compatibilité avec `.interactiveDismissDisabled(true)` du Mode Zen.
- [x] Implémenter la logique `KeypadLayout` dans `ProPadView` (Inversion Grid).

## File List
- `PiTrainer/PiTrainer/Features/Home/ZenPrimaryButton.swift` [NEW]
- `PiTrainer/PiTrainer/Features/Home/ZenSegmentedControl.swift` [NEW]
- `PiTrainer/PiTrainer/HomeView.swift` [MODIFIED]
- `PiTrainer/PiTrainer/SessionView.swift` [MODIFIED]


## Dependencies
- Must be done BEFORE Story 3.2 (Zen Mode) and 3.3 (Strict Mode).
