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

FR1: L'utilisateur peut sélectionner une constante mathématique (Pi, e, phi, etc.).
FR2: L'utilisateur peut lancer une session en Mode Strict (arrêt immédiat à l'erreur).
FR3: L'utilisateur peut saisir des décimales via un pavé numérique optimisé pour la vitesse.
FR4: Le système valide la saisie en temps réel par rapport aux données mathématiques.
FR5: Le système affiche un compteur de position en temps réel (Position Tracker).
FR6: Le système affiche les décimales saisies par blocs de 10 (Terminal-Grid).
FR7: L'utilisateur peut consulter l'historique de ses 200 dernières performances (date, score, vitesse).
FR8: Le système active le Streak Flow (animations visuelles / Ghost Mode) lors des séries de réussites.
FR9: Le système fournit des retours haptiques et sonores lors de la saisie et des erreurs (Core Haptics).
FR10: Le système enregistre et affiche le record personnel (Personal Best) par constante.
FR11: Le système suit et affiche le nombre de jours consécutifs d'utilisation (Daily Streak).
FR12: Le système envoie des notifications locales de rappel journalier pour maintenir les séries.
FR13: Le système persiste l'intégralité des données localement (Hybride UserDefaults + Fichiers).
FR14: Le système demande explicitement le consentement de l'utilisateur pour les notifications locales dès le premier lancement.
FR15: Le système permet d'activer/désactiver les retours haptiques dans les réglages de l'application.
FR16: L'interface ajuste dynamiquement ses marges pour respecter les Safe Areas de tous les modèles d'iPhone supportés.

### NonFunctional Requirements

NFR1: Latence de feedback visuel/sonore inférieure à 16ms (60 FPS constants).
NFR2: Temps de lancement de l'application inférieur à 2 secondes.
NFR3: Taux d'erreur de validation mathématique de 0%.
NFR4: Respect des standards WCAG AA pour le contraste et VoiceOver.
NFR5: Taille minimale des cibles de saisie de 44x44 points (Contrainte App Store).
NFR6: Threading dédié (User Interactive priority) pour la validation afin de ne jamais bloquer le Main Thread.
NFR7: RAM Management : Pré-chargement des segments de décimales en mémoire vive pour éliminer les latences I/O disque pendant le sprint.

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

<!-- End story breakdown -->





