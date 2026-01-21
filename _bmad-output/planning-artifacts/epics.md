---
stepsCompleted: ['step-01-validate-prerequisites']
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
---

# pi-trainer - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for pi-trainer, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: (Navigation) Interface principale divisée en 3 onglets : Learn, Practice, Play.
FR2: (Sections) Learn (Outils), Practice (Zen), Play (Compétition/Game).
FR3: (Segmentation) Définition de segment d'apprentissage (ex: 50-100).
FR4: (Visual Guide) Overlay de transparence pour le guidage.
FR5: (Repetition Flow) Saisie par-dessus le modèle ("calque").
FR6: (Ghost System) Calcul et animation du Ghost basé sur le PR.
FR7: (Horizon Line) Visualisation de la course (1px).
FR8: (Atmospheric Feedback) Couleur dynamique selon le delta vitesse.
FR9: (Error Tolerance) Game Mode : erreurs signalées mais non bloquantes.
FR10: (Strict Rules) Compétition : arrêt immédiat à l'erreur.
FR11: (Validity) Certification accessible uniquement en Mode Compétition.
FR12: (Daily Challenge) Défi quotidien unique et statique (V2.8).
FR13: (Rewards System) XP simple, Grades calculés, Double Bang animation.
FR14: (Streak Flow) Animations de combo actives dans tous les modes.

### NonFunctional Requirements

NFR1: Latence < 16ms (60 FPS).
NFR2: Launch time < 2s.
NFR3: Validation mathématique 0% erreur.
NFR4: Accessibilité WCAG AA.
NFR5: Touch targets 44x44 points.

### Additional Requirements

- **Starter Template**: Performance-Optimized MVVM (Custom) avec Swift 5.10 / iOS 17+ et @Observable.
- **Core Haptics**: Utilisation de Core Haptics avec pre-warming proactif à l'entrée dans l'écran de session.
- **Zen Mode (Navigation Lock)**: Verrouillage systématique des gestes (.interactiveDismissDisabled(true)) et désactivation des swipes non-essentiels pendant la session.
- **Terminal-Grid Rendering**: Optimisation via .drawingGroup() et rendu accéléré par le GPU (Metal).
- **Pro-Pad (Ghost Keyboard)**: Pavé numérique avec opacité dynamique (repos 20% à flow intense 5%).
- **Persistance Hybride**: UserDefaults pour records critiques, fichiers JSON/CSV asynchrones pour l'historique massif.
- **Feature-Sliced Hybrid Architecture**: Organisation par domaines (Practice, Learning, Stats) et Core Services transverses.

### FR Coverage Map

- FR1 : Epic 3 - Story 3.1 (Sélection constante)
- FR2 : Epic 3 - Story 3.3 (Mode Strict)
- FR3 : Epic 1 - Story 1.3 (Pavé numérique "Pro-Pad")
- FR4 : Epic 1 - Story 1.4 (Moteur de validation)
- FR5 : Epic 2 - Story 2.2 (Position Tracker)
- FR6 : Epic 2 - Story 2.1 (Terminal-Grid blocs de 10)
- FR7 : Epic 4 - Story 4.3 (Historique 200 sessions)
- FR8 : Epic 2 - Story 2.3 & 2.4 (Streak Flow / Ghost Mode)
- FR9 : Epic 1 - Story 1.2 (Service Haptique Core Haptics)
- FR10 : Epic 4 - Story 4.2 (Dashboard PB)
- FR11 : Epic 5 - Story 5.1 (Daily Streak)
- FR12 : Epic 5 - Story 5.3 (Rappels journaliers)
- FR13 : Epic 1/Story 1.4 (UserDefaults) & Epic 4/Story 4.1 (JSON Files)
- FR14 : Epic 5 - Story 5.2 (Consentement notifications)
- FR15 : Epic 1 - Story 1.3 (Réglage haptique)
- FR16 : Epic 1 - Story 1.1 (Safe Areas / Design System)

## Epic List

### Epic 1 : Fondations de Pratique & Feedback Sensoriel
Créer le moteur de saisie haute performance avec retour haptique et visuel immédiat.
**FRs covered:** FR3, FR4, FR9, FR13 (partiel), FR15, FR16.

### Epic 2 : Expérience "Ghost Terminal" & Visualisation
Implémenter l'affichage par blocs de 10, le suivi de position et le mode immersif (Ghost Mode / Streak Flow).
**FRs covered:** FR5, FR6, FR8.

### Epic 3 : Gestion des Sessions & Mode Strict
Gérer la sélection des constantes (Pi, e, phi) et le cycle de vie complet d'une session avec le défi du Mode Strict.
**FRs covered:** FR1, FR2.

### Epic 4 : Records, Statistiques & Persistance
Sauvegarder les performances, afficher les records personnels (Personal Best) et l'historique détaillé.
**FRs covered:** FR7, FR10, FR13 (complet).

### Epic 5 : Engagement & Rétention (Streaks & Notifications)
Maintenir la motivation via les séries journalières (Daily Streak) et les rappels locaux.
**FRs covered:** FR11, FR12, FR14.

## Epic 1: Fondations de Pratique & Feedback Sensoriel

Créer le moteur de saisie haute performance avec retour haptique et visuel immédiat.

### Story 1.1: Initialisation du Projet & Architecture de Base

As a athlète de la mémoire,
I want que l'application soit correctement configurée avec son design system (Safe Areas, couleurs OLED),
So that disposer d'une base solide et performante dès le lancement.

**Acceptance Criteria:**

**Given** un nouveau projet Xcode
**When** j'initialise l'application pi-trainer
**Then** l'arborescence Core/Features/Shared est créée
**And** les couleurs Noir OLED et Cyan Électrique sont définies dans les Assets
**And** la typographie Monospaced (SF Mono) est configurée comme police par défaut pour les chiffres
**And** le layout de base respecte les Safe Areas sur iPhone 15/16 Pro.

### Story 1.2: Service Haptique (Core Haptics) avec Pre-warming

As a utilisateur cherchant le flow,
I want ressentir un retour haptique instantané lors de chaque pression,
So that synchroniser mes gestes avec ma pensée.

**Acceptance Criteria:**

**Given** l'application lancée
**When** j'accède à l'écran de pratique
**Then** le moteur Core Haptics est "pre-warmed" (activé proactivement)
**And** une réussite déclenche une signature haptique de type "clic sec" (16ms)
**And** une erreur déclenche une signature haptique de type "vibration double"
**And** le feedback est perçu comme instantané par l'utilisateur.

### Story 1.3: Pavé Numérique "Pro-Pad" Immersif

As a utilisateur rapide,
I want un pavé numérique optimisé avec des feedbacks visuels immédiats,
So that saisir les chiffres sans lever les yeux de la zone de focus.

**Acceptance Criteria:**

**Given** l'écran de pratique
**When** je tape sur un chiffre du pavé numérique
**Then** la cible de touche mesure au moins 44x44 points
**And** un micro-flash Cyan apparaît brièvement sur la touche
**And** le `HapticService` est appelé pour confirmer la touche
**And** un réglage permet d'activer/désactiver les haptiques dans les paramètres.

### Story 1.4: Moteur de Validation "PracticeEngine"

As a utilisateur,
I want que ma saisie soit validée en temps réel avec une latence sub-16ms,
So that maintenir mon rythme de récitation.

**Acceptance Criteria:**

**Given** une session de pratique active
**When** je saisis un chiffre
**Then** le `PracticeEngine` valide le chiffre par rapport au fichier `digits.txt` source
**And** l'état `@Observable` est mis à jour instantanément pour l'UI
**And** le traitement s'effectue sur un thread à priorité "User Interactive"
**And** l'index de progression (dernière décimale correcte) est persisté dans `UserDefaults`.

## Epic 2: Expérience "Ghost Terminal" & Visualisation

Implémenter l'affichage par blocs de 10, le suivi de position et le mode immersif (Ghost Mode / Streak Flow).

### Story 2.1: Affichage "Terminal-Grid" par blocs de 10

As a utilisateur,
I want voir les chiffres s'afficher par blocs verticaux de 10,
So that respecter mon modèle mental de découpage des constantes.

**Acceptance Criteria:**

**Given** une session de pratique active
**When** je saisis des chiffres corrects
**Then** ils s'affichent dans une grille de 10 colonnes maximum
**And** chaque groupe de 10 chiffres est séparé par un espacement ou un indicateur de ligne (ex: "10 >")
**And** le rendu utilise `.drawingGroup()` pour maintenir 60 FPS constants.

### Story 2.2: Suivi de Position "Position Tracker"

As a utilisateur,
I want voir l'index de la décimale en cours (ex: #156),
So that savoir exactement où j'en suis dans ma mémorisation.

**Acceptance Criteria:**

**Given** l'écran de pratique active
**When** je saisis un chiffre
**Then** un indicateur discret affiche l'index de la prochaine décimale attendue
**And** l'indicateur s'incrémente instantanément après chaque validation correcte.

### Story 2.3: Activation du "Streak Flow" (Paliers Visuels)

As a athlète de la mémoire,
I want que l'interface s'illumine progressivement lors de mes séries de succès,
So that ressentir un sentiment de progression et de flow.

**Acceptance Criteria:**

**Given** un streak en cours
**When** le streak atteint 10 succès consécutifs
**Then** une aura Cyan subtile s'active autour de la zone de saisie
**And** à 20 succès, l'intensité visuelle augmente (Glow fluide)
**And** les animations ne provoquent aucune chute de framerate (<16ms).

### Story 2.4: Mode "Ghost" - Opacité Dynamique du Clavier

As a utilisateur expert,
I want que le clavier s'efface progressivement lors d'un long streak,
So that me concentrer exclusivement sur mes chiffres et ma mémoire musculaire.

**Acceptance Criteria:**

**Given** un streak > 20
**When** la saisie est rapide et continue
**Then** l'opacité du Pro-Pad diminue progressivement jusqu'à 5%
**And** le clavier redevient visible à 20% après 3 secondes d'inactivité
**And** la transition d'opacité est fluide et dure environ 1 seconde.

## Epic 3: Gestion des Sessions & Mode Strict

Gérer la sélection des constantes (Pi, e, phi) et le cycle de vie complet d'une session avec le défi du Mode Strict.

### Story 3.0: Architecture Navigation & Redesign Home

As a utilisateur,
I want une navigation fluide et cohérente entre l'accueil et la session,
So that l'immersion "Zen-Athlete" ne soit jamais brisée par des composants standards ou des bugs de navigation.

**Acceptance Criteria:**
- **Given** l'écran d'accueil
- **When** je lance l'application
- **Then** le design respecte la charte "Dark & Sharp" (Pas de composants natifs gris).
- **And** le cycle de vie Start (Home -> Session) et Stop (Session -> Home) est géré par une machine à état robuste.

### Story 3.1: Sélection de la Constante Mathématique

As a utilisateur,
I want pouvoir choisir entre différentes constantes (Pi, e, phi),
So that varier mes défis de mémorisation.

**Acceptance Criteria:**

**Given** l'écran d'accueil
**When** je change de constante via le sélecteur
**Then** la source de données du `PracticeEngine` est mise à jour avec les nouveaux chiffres
**And** le titre de l'écran et les records affichés correspondent à la constante sélectionnée.

### Story 3.2: Lancement et Contrôle de Session (Zen Mode)

As a utilisateur,
I want démarrer une session sans friction et ne pas être interrompu accidentellement,
So that rester concentré à 100%.

**Acceptance Criteria:**

**Given** l'écran de pratique prêt
**When** je saisis le premier chiffre
**Then** la session démarre automatiquement sans bouton "Start" supplémentaire
**And** le mode Zen est activé via `.interactiveDismissDisabled(true)`
**And** un tap long (3s) ou une erreur permet de quitter la session.

### Story 3.3: Implémentation du Mode Strict

As a compétiteur,
I want que ma session s'arrête immédiatement à la moindre erreur,
So that valider une mémorisation parfaite.

**Acceptance Criteria:**

**Given** une session en mode Strict active
**When** je saisis un chiffre incorrect
**Then** la session se termine instantanément
**And** l'écran de fin s'affiche avec le score et la vitesse moyenne
**And** un feedback d'erreur agressif (Shake + Vibration double) est déclenché.

## Epic 4: Records, Statistiques & Persistance

Sauvegarder les performances, afficher les records personnels (Personal Best) et l'historique détaillé.

### Story 4.1: Système de Persistance Hybride (Records & Histoire)

As a athlète de la mémoire,
I want que mes records soient accessibles instantanément et mes sessions sauvegardées sur le long terme,
So that ne jamais perdre mon progrès.

**Acceptance Criteria:**

**Given** une fin de session
**When** le score est enregistré
**Then** les Records Personnels (PB) sont stockés dans `UserDefaults`
**And** l'historique complet est sauvegardé dans des fichiers JSON de manière asynchrone via `Core/Persistence`
**And** l'enregistrement n'impacte pas la fluidité de l'interface de fin de session.

### Story 4.2: Dashboard des Records Personnels (PB)

As a utilisateur,
I want voir un résumé de mes meilleures performances pour chaque constante,
So that visualiser mes sommets.

**Acceptance Criteria:**

**Given** l'écran d'accueil
**When** je consulte mes records
**Then** le record (nombre max de chiffres) s'affiche pour Pi, e et Phi
**And** la date de réalisation du record est affichée à côté du score.

### Story 4.3: Historique Détaillé des Performances

As a utilisateur,
I want pouvoir consulter la liste de mes 200 sessions les plus récentes,
So that analyser mon évolution de vitesse et de précision.

**Acceptance Criteria:**

**Given** l'écran de statistiques
**When** je consulte l'historique
**Then** les 200 dernières sessions sont listées (date, score, vitesse moyenne en CPS)
**And** les données sont chargées de manière asynchrone depuis le stockage fichier.

## Epic 5: Engagement & Rétention (Streaks & Notifications)

Maintenir la motivation via les séries journalières (Daily Streak) et les rappels locaux.

### Story 5.1: Gestion du "Daily Streak" (Utilisation consécutive)

As a utilisateur régulier,
I want voir le nombre de jours consécutifs où j'ai pratiqué,
So that maintenir ma discipline de mémorisation.

**Acceptance Criteria:**

**Given** une première session réussie dans la journée
**When** la session se termine
**Then** le "Daily Streak" est incrémenté de 1
**And** si plus de 24h (ou au-delà du jour calendaire suivant) s'écoulent sans session, le streak est réinitialisé à 0
**And** la valeur du streak est persistée localement.

### Story 5.2: Système de Consentement & Notifications Locales

As a utilisateur néophyte,
I want être informé de l'intérêt des rappels dès mon premier lancement,
So that choisir d'être accompagné dans ma pratique.

**Acceptance Criteria:**

**Given** la première session de pratique de l'utilisateur
**When** la session est terminée ou pendant l'onboarding
**Then** une alerte système demande explicitement le consentement pour les notifications locales
**And** le choix de l'utilisateur (Autoriser/Refuser) est respecté.

### Story 5.3: Notifications de Rappel Journalier

As a utilisateur distrait,
I want recevoir un rappel si j'oublie de faire ma session quotidienne,
So that sauver ma série (streak) en cours.

**Acceptance Criteria:**

**Given** un streak actif (>0)
**When** aucune session n'a été effectuée à l'heure programmée du rappel
**Then** une notification locale est envoyée avec un message mentionnant le streak actuel
**And** la notification est annulée si une session est réalisée avant l'heure du rappel.

### Epic 6: Apprentissage Contextuel (Mode Reveal)

Améliorer le mode Apprentissage en permettant une assistance ponctuelle directement dans la grille de saisie, tout en suivant l'utilisation de cette aide.

#### Story 6.1: Assistance "Juste-à-Temps" (Ghost Reveal)
As a utilisateur bloqué lors d'une session,
I want pouvoir afficher discrètement les chiffres manquants d'une ligne,
So that débloquer ma mémorisation et continuer ma progression sans quitter la session.

**Acceptance Criteria:**
- **Given** une session en mode **LEARN**
- **When** une ligne de 10 chiffres n'est pas encore complétée
- **Then** un bouton discret (icône d'œil ou similaire) apparaît à gauche de la ligne
- **When** j'appuie sur ce bouton
- **Then** les chiffres restants de la ligne s'affichent de manière translucide (transparence ~20%)
- **And** je peux taper par-dessus ces chiffres "fantômes".

#### Story 6.2: Statistiques d'Assistance (Reveal Counter)
As a utilisateur cherchant à mesurer ma progression réelle,
I want savoir combien de fois j'ai utilisé l'assistance lors d'une session,
So that évaluer mon degré d'autonomie dans la mémorisation.

**Acceptance Criteria:**
- **Given** une session active
- **When** j'utilise le bouton de "Reveal"
- **Then** un compteur `revealsUsed` est incrémenté pour la session en cours
- **And** ce score est affiché dans le résumé de fin de session
- **And** le nombre de "reveals" est persisté dans l'historique de la session.

---

## V2 Epics (Version Majeure)

Les Epics suivantes couvrent les nouvelles fonctionnalités de la version 2 : structure tripolaire (Learn/Practice/Game/Strict), Game Mode avec Ghost, et améliorations du Learn Mode.

### Epic 7: Structure de Navigation V2 & Mode Selector

Implémenter la nouvelle architecture de navigation avec sélection du mode directement sur l'écran d'accueil.

**FRs V2 covered:** FR1-V2 (Navigation), FR2-V2 (Mode Selector)

#### Story 7.1: Mode Selector sur Home (Dual Selector Pattern)

As a utilisateur,
I want choisir mon mode de jeu (Learn, Practice, Game, Strict) directement sur l'écran d'accueil,
So that lancer une session dans le mode souhaité en un minimum de taps.

**Acceptance Criteria:**

**Given** l'écran d'accueil
**When** je visualise l'interface
**Then** un sélecteur de mode apparaît sous le sélecteur de constantes
**And** le style est identique au Constant Selector (pills/chips horizontaux)
**And** les 4 modes sont affichés : Learn, Practice, Game, Strict
**And** le mode Learn est sélectionné par défaut
**And** le mode sélectionné est persisté entre les sessions.

**Technical Notes:**
- Créer `SessionMode.swift` avec l'enum et les computed properties
- Créer `ModeSelector.swift` en réutilisant le pattern de `ConstantSelector`
- Stocker dans `UserDefaults` via clé `selectedMode`

#### Story 7.2: Suppression du Mode des Réglages

As a utilisateur,
I want que le choix du mode soit exclusivement sur l'écran d'accueil,
So that l'interface soit cohérente et non redondante.

**Acceptance Criteria:**

**Given** l'écran des réglages
**When** je consulte les options
**Then** l'option de sélection du mode de jeu n'apparaît plus
**And** tous les anciens accès au changement de mode redirigent vers Home.

**Technical Notes:**
- Supprimer `ModePicker` des Settings
- Mettre à jour la documentation in-app si existante

---

### Epic 8: Mode Learn Amélioré (Segment Selection)

Implémenter le nouveau Mode Learn avec sélection de segment personnalisée et overlay permanent.

**FRs V2 covered:** FR3-V2 (Segmentation), FR4-V2 (Visual Guide), FR5-V2 (Repetition Flow)

#### Story 8.1: Dual Slider pour Sélection de Segment

As a apprenant,
I want définir un segment précis à mémoriser (ex: décimales 50 à 100),
So that cibler mon apprentissage sur une zone spécifique.

**Acceptance Criteria:**

**Given** le mode Learn sélectionné sur Home
**When** je prépare ma session
**Then** un Dual Slider apparaît permettant de définir le début et la fin du segment
**And** les valeurs min/max sont contraintes (start < end)
**And** les valeurs par défaut sont 0-50
**And** les valeurs sélectionnées sont persistées entre les sessions.

**Technical Notes:**
- Créer `SegmentSlider.swift` dans Features/Home
- Étendre `LearningStore` avec `segmentStart` et `segmentEnd`
- Le slider n'apparaît QUE si mode == .learn

#### Story 8.2: Overlay Permanent en Mode Learn

As a apprenant,
I want que les chiffres à taper soient toujours visibles en transparence,
So that apprendre par répétition musculaire en suivant le modèle.

**Acceptance Criteria:**

**Given** une session en mode Learn
**When** la session démarre
**Then** l'overlay (mode révélé/œil) est activé automatiquement et non désactivable
**And** seul le segment sélectionné (ex: 50-100) est affiché
**And** l'utilisateur tape par-dessus les chiffres en filigrane
**And** le comportement de validation reste identique au mode Practice (cohérence).

**Technical Notes:**
- Forcer `isRevealed = true` quand `mode == .learn`
- Adapter `DigitsProvider` pour servir uniquement le segment sélectionné

---

### Epic 9: Mode Game (Ghost System & Atmospheric Feedback)

Implémenter le Game Mode avec course contre le Ghost (Personal Best) et feedback atmosphérique dynamique.

**FRs V2 covered:** FR6-V2 (Ghost), FR7-V2 (Horizon), FR8-V2 (Atmospheric), FR9-V2 (Error Tolerance)

#### Story 9.1: GhostEngine — Twin Shadows Logic
As a gamer, I want to compete against two types of ghosts (Distance/Marathon and Speed/Sprint) to push my limits in different ways.

**Acceptance Criteria:**
- **Ghost Types**: Separation between "CROWN" (Distance) and "LIGHTNING" (Speed).
- **Certified Status**: Only sessions with 0 errors starting from Mode Game or Mode Test are eligible for a PR (Ghost).
- **Start Signal**: Ghost waits for the user's first input.
- **Speed Minimum**: Speed PR only eligible for sessions > 50 digits.

**Acceptance Criteria:**

**Given** une session en mode Game
**When** je lance la session
**Then** le système charge mon Personal Best (PR) pour la constante sélectionnée
**And** si un PR existe, un `GhostEngine` est initialisé avec les timestamps cumulés
**And** si aucun PR n'existe, le Ghost reste à position 0 (premier essai)
**And** le Ghost "avance" virtuellement basé sur le temps écoulé vs les temps du PR.

**Technical Notes:**
- Créer `GhostEngine.swift` dans Core/Engine
- Créer/Étendre `PersonalBestRecord` avec `cumulativeTimes: [TimeInterval]`
- Créer `PersonalBestStore.swift` pour la persistance des timestamps

#### Story 9.2: Horizon Line (Visualisation de la Course)

As a gamer,
I want voir ma position relative par rapport au Ghost sur une ligne d'horizon,
So that savoir instantanément si je suis en avance ou en retard.

**Acceptance Criteria:**

**Given** une session en mode Game
**When** je suis en train de taper
**Then** une ligne d'horizon 1px apparaît au-dessus du Terminal-Grid
**And** un point blanc représente ma position effective (décimales - erreurs)
**And** un point gris représente la position du Ghost
**And** les points se déplacent fluidement à chaque input.

**Technical Notes:**
- Créer `HorizonLineView.swift` dans Features/Practice
- Afficher uniquement si `mode == .game`
- Position = ratio sur la largeur de l'écran

#### Story 9.3: Atmospheric Feedback (Couleurs Dynamiques)

As a gamer,
I want ressentir visuellement si je suis en avance ou en retard,
So that ajuster mon rythme sans regarder des chiffres.

**Acceptance Criteria:**

**Given** une session en mode Game
**When** je suis en avance sur le Ghost
**Then** le fond de l'écran se teinte légèrement d'Orange Électrique (#FF6B00)
**When** je suis en retard sur le Ghost
**Then** le fond se teinte légèrement de Cyan (#00F2FF)
**And** l'intensité de la teinte est proportionnelle à l'écart (dynamique)
**And** à égalité, le fond reste neutre (noir OLED).

**Technical Notes:**
- Créer `SessionViewModel+Game.swift` avec `atmosphericDelta` et `atmosphericColor`
- Opacité : 5% (neutre) à 20% (écart max)

#### Story 9.4: Gestion des Erreurs Game Mode (-1 Pénalité)

As a gamer,
I want que mes erreurs ne stoppent pas la session mais me pénalisent,
So that continuer ma course tout en payant le prix de mes fautes.

**Acceptance Criteria:**

**Given** une session en mode Game
**When** je tape un chiffre incorrect
**Then** la session continue (pas d'arrêt)
**And** un feedback d'erreur standard est déclenché (flash/haptic)
**And** le chiffre correct est révélé en transparence
**And** je dois taper le bon chiffre pour continuer
**And** ma position effective sur l'Horizon est décrémentée de 1.

**Technical Notes:**
- Modifier `PracticeEngine.input()` pour retourner `.error(fatal: false)` en mode Game
- Ajouter `errorCount` au moteur
- Position effective = `correctCount - errorCount`

#### Story 9.5: Dynamic PR Recording & Rules

As a gamer, I want the system to automatically certify my runs and update my Twin-Shadows PRs based on the new rules.

**Acceptance Criteria:**
- **Certification Logic**: `if sessionMode != .learn && revealsUsed == 0 && errors == 0 { certify() }`.
- **Tie-break Rule**: If distances are equal, fastest time wins for the Crown.
- **Sprint Logic**: Updates the Lightning Slot if CPS is higher and distance > 50.
- **Practice Exclusion**: Runs with errors or in Learn mode are saved as "Uncertified" in history but NEVER used as Ghosts.

**Acceptance Criteria:**

**Given** une session terminée avec un nouveau PR
**When** le score est enregistré
**Then** les timestamps cumulés (temps à chaque décimale) sont sauvegardés
**And** le nouveau PR remplace l'ancien dans `PersonalBestStore`
**And** l'affichage classique du PB (juste le score) reste inchangé.

**Technical Notes:**
- Enregistrer `Date().timeIntervalSince(startTime)` à chaque input correct
- Structure : `PersonalBestRecord { constant, digitCount, totalTime, cumulativeTimes }`

#### Story 9.6: Game Mode Rules & Onboarding

As a new gamer, I want to see a clear explanation of the Twin-Shadows rules so I understand how to earn my Stars and Ghosts.

**Acceptance Criteria:**
- **Rules Page**: A dedicated view or overlay explaining the Crown (Distance) vs Lightning (Speed) PRs.
- **Certification Explanation**: Clear mention that errors or reveals disqualify a run from being "Certified".
- **Visuals**: Use icons (Crown, Lightning, Shield) to illustrate the rules.

**Technical Notes:**
- Create `GameModeRulesView.swift`.
- Integrate as a "info" button or first-launch overlay in Game Mode.

---

## V2 FR Coverage Map (Extension)

| FR V2 | Epic/Story |
|-------|------------|
| FR1-V2 (Navigation) | 7.1 |
| FR2-V2 (Mode Selector) | 7.1, 7.2 |
| FR3-V2 (Segmentation) | 8.1 |
| FR4-V2 (Visual Guide) | 8.2 |
| FR5-V2 (Repetition) | 8.2 |
| FR6-V2 (Ghost) | 9.1 |
| FR7-V2 (Horizon) | 9.2 |
| FR8-V2 (Atmospheric) | 9.3 |
| FR9-V2 (Error Tolerance) | 9.4 |

### Epic 10: Engagement & Récompenses (Daily & XP)
Créer la boucle d'engagement quotidienne avec des défis statiques et un système d'XP simple ("Zero-Code") pour valoriser la pratique.
**FRs covered:** FR12, FR13.

## Epic 10: Engagement & Récompenses (Daily & XP)

Créer la boucle d'engagement quotidienne avec des défis statiques et un système d'XP simple ("Zero-Code") pour valoriser la pratique.

### Story 10.1: Système de Défis Quotidiens (Static Curated)

As a utilisateur fidèle,
I want un défi unique chaque jour qui change à minuit,
So that avoir une raison de revenir quotidiennement et tester ma polyvalence.

**Acceptance Criteria:**
- **Given** l'application lancée
- **When** j'accède à la section Challenges
- **Then** un défi unique est affiché basé sur la date du jour (YYYY-MM-DD) et le fichier `challenges.json`
- **And** si je complète le défi, l'état est sauvegardé localement (`defaults.lastChallengeDate`)
- **And** je ne peux gagner la récompense qu'une seule fois par jour.

### Story 10.2: Système d'XP "Zero-Code" & Grades

As a athlète de la mémoire,
I want que mon rang (Grade) reflète mon volume d'entraînement total,
So that afficher mon niveau d'expertise.

**Acceptance Criteria:**
- **Given** mon historique de pratique
- **When** je consulte mon profil
- **Then** mon total d'XP est égal à la somme de toutes mes décimales correctes (`totalCorrectDigits`)
- **And** mon Grade est calculé dynamiquement selon les paliers (Novice < 1k, Apprenti < 5k, Athlète < 20k, Expert < 100k, Grandmaster > 100k)
- **And** ce calcul est instantané et ne nécessite pas de base de données dédiée.

### Story 10.3: Animation "Double Bang" (Reward)

As a gamer,
I want une célébration épique quand je bats mon record ET que je monte en grade simultanément,
So that marquer le coup lors d'une performance exceptionnelle.

**Acceptance Criteria:**
- **Given** une session terminée
- **When** j'ai battu mon Personal Best (Ghost) **ET** franchi un palier de Grade
- **Then** une double animation se déclenche (Explosion de particules + Éclairs)
- **And** un feedback haptique intense (Success + Impact) est joué
- **And** l'écran de résultat mentionne "DOUBLE BANG".

## Requirements Coverage Map

FR1 (Navigation) : Epic 7 - Story 7.1
FR2 (Sections) : Epic 7 - Story 7.1
FR3 (Segmentation) : Epic 8 - Story 8.1
FR4 (Visual Guide) : Epic 8 - Story 8.2
FR5 (Repetition Flow) : Epic 8 - Story 8.2
FR6 (Ghost System) : Epic 9 - Story 9.1
FR7 (Horizon Line) : Epic 9 - Story 9.2
FR8 (Atmospheric Feedback) : Epic 9 - Story 9.3
FR9 (Error Tolerance) : Epic 9 - Story 9.4
FR10 (Strict Rules) : Epic 3 - Story 3.3
FR11 (Validity) : Epic 9 - Story 9.5
FR12 (Daily Challenge) : Epic 10 - Story 10.1
FR13 (Rewards System) : Epic 10 - Story 10.2 & 10.3
FR14 (Streak Flow) : Epic 2 - Story 2.3




