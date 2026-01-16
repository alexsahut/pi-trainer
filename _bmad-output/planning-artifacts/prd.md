---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
inputDocuments:
  - '_bmad-output/project-knowledge/architecture.md'
  - '_bmad-output/project-knowledge/data-models-root.md'
  - '_bmad-output/project-knowledge/index.md'
  - '_bmad-output/project-knowledge/project-overview.md'
  - '_bmad-output/project-knowledge/source-tree-analysis.md'
  - 'DEVLOG.md'
documentCounts:
  briefCount: 0
  researchCount: 0
  brainstormingCount: 0
  projectDocsCount: 6
classification:
  projectType: 'Mobile App (iOS)'
  domain: 'EdTech'
  complexity: 'Medium'
  projectContext: 'brownfield'
elicitationInsights:
  selectedTheme: 'Gamification'
  keyFeatures:
    - 'Streak Flow: interface interactive s’illuminant avec les bonnes réponses'
    - 'Visualisation: groupement par blocs de 10 décimales'
    - 'Feedback: compteur de position de la décimale en cours'
workflowType: 'prd'
lastEdited: '2026-01-15T22:56:00+01:00'
editHistory:
  - date: '2026-01-15T22:56:00+01:00'
    changes: 'Ajout des contraintes App Store, des permissions système et des corrections de mesurabilité.'
---

## Executive Summary

**Product Vision:** 
Pi-Trainer est une application mobile iOS native conçue pour transformer la mémorisation des constantes mathématiques en un défi addictif. Le produit mise sur une interface ultra-minimaliste et performante, centrée sur le plaisir de la récitation rapide.

**Core Differentiator:** 
L'application se distingue par son **Streak Flow**, une expérience immersive où l'interface réagit dynamiquement à la vitesse et à la précision de la saisie, créant un état de concentration intense ("flow").

**Target Audience:** 
Compétiteurs de mémoire, étudiants passionnés et tout utilisateur souhaitant entraîner sa mémoire musculaire et cognitive de manière ludique et universelle.

---

## Success Criteria

### User Success
- **Moment "Aha!" :** Atteindre un record personnel ("Personal Best") ou améliorer son temps de réponse moyen.
- **Session Idéale :** Réaliser plus de décimales en moins de temps par rapport à la session précédente.
- **Engagement :** Plaisir ressenti lors du challenge, poussant à une utilisation régulière (ex: entraînement quotidien).

### Business & Product Success
- **Positionnement :** Le produit est perçu comme un outil de maîtrise et de défi, et non comme un simple support éducatif passif.
- **Rétention :** Les utilisateurs reviennent quotidiennement pour maintenir leur "Daily Streak".

### Technical & Quality Success
- **Précision :** Zero erreur tolérée dans la base de données des constantes mathématiques.
- **Fluidité :** Latence de saisie imperceptible (16ms) pour supporter une récitation ultra-rapide.
- **Conformité App Store :** Zéro rejet lors de la soumission liée aux Human Interface Guidelines (HIG) ou aux politiques de confidentialité.

---

## Product Scope & Strategy

### MVP Strategy (Phase 1)
L'approche MVP se concentre sur le cœur du challenge : la précision et la fluidité.
- **Must-Have :** Streak Flow v1, Mode Strict (arrêt à l'erreur), compteur de position, groupement par 10, et base de constantes validée.
- **Sacrifice :** Le mode apprentissage et les thèmes visuels sont reportés en phase 2 pour garantir la perfection du moteur de saisie.

### Growth Features (Phase 2)
- **Mode Apprentissage :** Gestion des erreurs et feedback pédagogique.
- **Gamification complète :** Thèmes déblocables, badges d'accomplissement.
- **Social :** Leaderboards locaux et partage de performances.

### Vision (Phase 3)
- **Adaptative Learning :** Analyse des patterns de mémorisation via IA pour parcours personnalisés.
- **Multiplay :** Mode duel en temps réel.

---

## User Journeys

### 1. Le "Moment Aha!" (Premier Lancement)
*   **Contexte :** Léo ouvre l'application pour la première fois.
*   **Parcours :** Ouverture → **Consentements Système** (Notifications, Haptics) → Sélection Pi → Lancement.
*   **Climax :** L'interface s'illumine (Streak Flow) à la 20ème décimale.
*   **Résolution :** Léo ressent une satisfaction immédiate et accepte de revenir demain via la notification programmée.

### 2. Le Défi Express (Léo, l'Apprenti)
*   **Contexte :** Léo veut battre son record sur Pi en 2 minutes.
*   **Parcours :** Ouverture → Sélection Pi → Lancement.
*   **Climax :** L'interface s'illumine (Streak Flow) à la 50ème décimale.
*   **Résolution :** L'app affiche la bonne réponse après l'erreur et félicite Léo pour son progrès.

### 2. Le Test de Maîtrise (L'Expert)
*   **Contexte :** Validation d'une mémorisation parfaite de "e".
*   **Parcours :** Sélection "e" → Mode Strict → Concentration maximale.
*   **Résolution :** Sortie volontaire après 100 décimales sans faute. Affichage de la vitesse moyenne.

### 3. La Récupération (Mémorisation ciblée)
*   **Contexte :** Blocage récurrent sur une séquence spécifique.
*   **Parcours :** Session Apprentissage → Erreur → Visualisation du bloc de 10 fautif.
*   **Résolution :** Répétition immédiate de la séquence pour ancrer la mémorisation.

---

## Mobile App (iOS) Specific Requirements

### Native Device Features
- **Performance Native :** Utilisation optimale des frameworks système pour garantir une réactivité maximale et une persistance robuste.
- **Full Offline :** 100% des fonctions d'entraînement disponibles sans connexion internet requise.
- **Haptics & Sound :** Retour visuel, haptique et sonore synchronisé avec le Streak Flow pour une immersion totale.
- **Daily Notifications :** Rappels locaux basés sur les séries journalières (milestones 3j, 7j, etc.) via le système de notifications local.

### App Store Compliance & Guidelines
- **Privacy :** Déclaration transparente de collecte de données (Data Privacy Nutrition Label) - Aucune donnée personnelle collectée.
- **Ratings :** Utilisation du système standard `SKStoreReviewController` pour les demandes d'avis, déclenché uniquement après un nouveau record personnel (PB).
- **Human Interface Guidelines (HIG) :** Respect strict des standards Apple pour l'accessibilité, les zones de sécurité (Safe Areas) et la hiérarchie visuelle.

---

## Functional Requirements

### 1. Entraînement & Challenge
- **FR1 :** L'utilisateur peut sélectionner une constante mathématique (Pi, e, phi, etc.).
- **FR2 :** L'utilisateur peut lancer une session en **Mode Strict** (arrêt immédiat à l'erreur).
- **FR3 :** L'utilisateur peut saisir des décimales via un pavé numérique optimisé pour la vitesse.
- **FR4 :** Le système valide la saisie en temps réel par rapport aux données mathématiques.
- **FR5 :** Le système affiche un compteur de position en temps réel.
- **FR6 :** Le système affiche les décimales saisies par blocs de 10.
- **FR7 :** L'utilisateur peut consulter l'historique de ses 200 dernières performances (date, score, vitesse).

### 2. Expérience Utilisateur & Gamification
- **FR8 :** Le système active le **Streak Flow** (animations visuelles) lors des séries de réussites.
- **FR9 :** Le système fournit des retours haptiques et sonores lors de la saisie et des erreurs.
- **FR10 :** Le système enregistre et affiche le record personnel (Personal Best) par constante.
- **FR11 :** Le système suit et affiche le nombre de jours consécutifs d'utilisation (Daily Streak).

### 3. Conformité & Système
- **FR12 :** Le système envoie des notifications locales de rappel journalier pour maintenir les séries.
- **FR13 :** Le système persiste l'intégralité des données localement (hors-ligne complet).
- **FR14 :** Le système demande explicitement le consentement de l'utilisateur pour les notifications locales dès le premier lancement.
- **FR15 :** Le système permet d'activer/désactiver les retours haptiques dans les réglages de l'application.
- **FR16 :** L'interface ajuste dynamiquement ses marges pour respecter les **Safe Areas** de tous les modèles d'iPhone supportés.

---

## Non-Functional Requirements

### Performance & Fluidité
- **NFR1 :** Latence de feedback visuel/sonore inférieure à **16ms** (60 FPS), mesurée via Xcode Instruments lors de tests de charge.
- **NFR2 :** Temps de lancement de l'application inférieur à **2 secondes**, mesuré via métriques système (App Launch metrics).

### Fiabilité & Accessibilité
- **NFR3 :** Taux d'erreur de validation mathématique de **0%**, validé par suite de tests unitaires exhaustive.
- **NFR4 :** Respect des standards **WCAG AA** pour le contraste et VoiceOver, validé via Accessibility Inspector.
- **NFR5 :** Taille minimale des cibles de saisie de **44x44 points** (Contrainte bloquante App Store), vérifiée par inspection des composants d'interface.
