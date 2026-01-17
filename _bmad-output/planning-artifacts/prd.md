---
stepsCompleted: ['step-e-01-discovery', 'step-e-02-review', 'step-e-03-edit']
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
lastEdited: '2026-01-17T20:00:00+01:00'
editHistory:
  - date: '2026-01-17T20:00:00+01:00'
    changes: 'Restructuration majeure : adoption du triptyque Learn/Practice/Play. Ajout des spécifications pour le Game Mode (Ghost, Horizon), le Learn Mode (Overlay) et le système de Rétention (Daily Challenges).'
  - date: '2026-01-15T22:56:00+01:00'
    changes: 'Ajout des contraintes App Store, des permissions système et des corrections de mesurabilité.'
---

## Executive Summary

**Product Vision:** 
Pi-Trainer est une application mobile iOS native conçue pour transformer la mémorisation des constantes mathématiques en un défi addictif et structuré. Le produit s'articule autour de trois piliers fondamentaux : **Apprendre (Learn)**, **S'entraîner (Practice)** et **Jouer (Play)**, le tout servi par une interface ultra-minimaliste "Zen" qui favorise l'état de flow.

**Core Differentiator:** 
L'application se distingue par son approche **"Zen Gamification"** : une architecture de jeu qui récompense la performance par des feedbacks atmosphériques et haptiques subtils, sans polluer l'interface visuelle. Le mode **Game** introduit une course contre soi-même (Ghost) matérialisée par une simple ligne d'horizon.

**Target Audience:** 
Compétiteurs de mémoire, étudiants passionnés et tout utilisateur souhaitant entraîner sa mémoire musculaire et cognitive, du débutant absolu (Learn) au champion (Play).

---

## Success Criteria

### User Success
- **Moment "Aha!" :** Atteindre un record personnel ("Personal Best") ou réussir sa première série sans erreur grâce au Ghost.
- **Session Idéale :** Alterner entre l'apprentissage d'un nouveau bloc (Learn) et sa validation en jeu (Play).
- **Engagement :** Retour quotidien pour le "Daily Challenge" et maintien du Streak.

### Business & Product Success
- **Positionnement :** L'outil de référence alliant pédagogie (Learn) et compétition (Play).
- **Rétention :** Les utilisateurs sont motivés par la progression de leur Grade et les défis quotidiens.

### Technical & Quality Success
- **Précision :** Zero erreur tolérée dans la base de données des constantes mathématiques.
- **Fluidité :** Latence de saisie imperceptible (16ms) pour supporter une récitation ultra-rapide.
- **Conformité App Store :** Zéro rejet lors de la soumission.

---

## Product Scope & Strategy

### MVP Strategy (Phase 1)
L'approche MVP instaure la structure tripolaire de l'application :
- **Mode Learn (Nouveau) :** Module d'apprentissage par répétition avec calque de transparence (saisie par-dessus le modèle) sur des segments personnalisés (début/fin).
- **Mode Practice (Existant) :** L'entraînement libre actuel (Zen Mode standard).
- **Mode Play :**
    - **Compétition (Ex-Strict) :** Arrêt immédiat à l'erreur.
    - **Game Mode (Nouveau) :** Course contre le Ghost, Ligne d'Horizon 1px, Feedback atmosphérique, Tolérance d'erreur.
- **Socle Technique :** Base de données validée, moteur haptique CoreHaptics.

### Growth Features (Phase 2 - Retention)
- **Section Challenges :** Dashboard dédié aux récompenses et défis.
- **Daily Challenge :** Défi quotidien généré procéduralement (ex: "Trouver la 167ème décimale", "Compléter la suite").
- **Gamification Avancée :** Système complet de Grades et Trophées "Double Bang".

### Vision (Phase 3 - Social)
- **Social Mnemonics :** Partage communautaire de mnémotechniques.
- **AI Coach :** Suggestion de techniques par IA.
- **Multiplay :** Duel temps réel.

---

## User Journeys

### 1. L'Apprenti (Mode Learn)
*   **Contexte :** Léo veut mémoriser les décimales de 50 à 100 de Pi.
*   **Parcours :** Tab "Learn" → Sélection Segment (50-100) → **Mode Transparence** (Les chiffres apparaissent en filigrane).
*   **Action :** Léo tape les chiffres en suivant le modèle. La répétition crée la mémoire musculaire.
*   **Résolution :** Une fois confiant, Léo masque le modèle et valide le segment.

### 2. Le Gamer (Mode Play - Game)
*   **Contexte :** Sarah veut battre son record personnel (PR) sans la pression du "Game Over".
*   **Parcours :** Tab "Play" → Mode Game → Lancement.
*   **Climax :**
    *   **L'Horizon :** Sarah voit le point blanc (Ghost) avancer sur la ligne d'horizon en haut.
    *   **Le Duel :** Elle accélère pour le doubler. Le fond d'écran se réchauffe (Ambre) indiquant qu'elle est en tête.
    *   **Le Final :** Elle termine le segment avant le Ghost.
*   **Résolution :** Animation "Double Bang" (Explosion de Grade + Éclairs de Vitesse).

### 3. Le Compétiteur (Mode Play - Compétition)
*   **Contexte :** Marc veut valider sa maîtrise parfaite pour le classement.
*   **Parcours :** Tab "Play" → Mode Compétition (Ex-Strict).
*   **Enjeu :** Une seule erreur arrête la session immédiatement.
*   **Résolution :** Marc atteint 200 décimales. Score validé "Certifié". Adrénaline pure.

### 4. La Routine Quotidienne (Retention)
*   **Contexte :** Notification "Challenge du jour : Suite Logique".
*   **Parcours :** Ouverture App → Tab "Profil/Challenges" → Défi "Complétez : 3.1415...".
*   **Action :** Léo trouve les 5 chiffres manquants.
*   **Résolution :** Gain d'XP pour le Grade global et prolongation du Daily Streak.

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

### 1. Structure & Navigation (Nouveau)
- **FR1 (Main Navigation) :** L'interface principale est divisée en 3 onglets (Tabs) : **Learn**, **Practice**, **Play**.
- **FR2 (Sections) :**
    - **Learn :** Outils d'apprentissage assisté.
    - **Practice :** Zone d'entraînement libre (Zen Mode actuel).
    - **Play :** Zone de défi avec choix entre "Compétition" et "Game".

### 2. Mode Learn (Apprentissage)
- **FR3 (Segmentation) :** L'utilisateur peut définir un segment d'apprentissage (ex: décimales 50 à 100).
- **FR4 (Visual Guide) :** Le système affiche les décimales cibles en transparence (overlay) par-dessus la zone de saisie.
- **FR5 (Repetition Flow) :** L'utilisateur peut saisir les chiffres en suivant le guide visuel (comportement "calque").

### 3. Mode Play - Game (Nouveau)
- **FR6 (Ghost System) :** Le système calcule et anime un "Ghost" (curseur) basé sur le Personal Best (PR) de l'utilisateur.
- **FR7 (Horizon Line) :** Une barre de progression minimaliste (1px) en haut d'écran visualise la course entre le joueur (Point Blanc) et le Ghost (Point Gris).
- **FR8 (Atmospheric Feedback) :** La couleur d'ambiance de l'écran évolue dynamiquement selon le delta Vitesse (Chaud = En avance, Froid = En retard).
- **FR9 (Error Tolerance) :** Contrairement au mode strict, les erreurs sont signalées (Haptique/Visuel) mais n'arrêtent pas la session. Elles appliquent une pénalité de temps/score.

### 4. Mode Play - Compétition (Ex-Strict)
- **FR10 (Strict Rules) :** La session s'arrête immédiatement à la première erreur saisie.
- **FR11 (Validity) :** Seuls les scores réalisés dans ce mode sont éligibles aux "Certifications" de maîtrise.

### 5. Rétention & Gamification (Global)
- **FR12 (Daily Challenge) :** Le système génère un défi quotidien unique (ex: "Trouver la n-ième décimale", "Compléter la suite").
- **FR13 (Rewards System) :**
    - **Grades :** Progression basée sur l'XP (Endurance).
    - **Speed Bonus :** Récompense spécifique pour avoir battu le Ghost.
    - **Double Bang :** Animation spéciale lors de l'obtention simultanée Grade + Speed Bonus.
- **FR14 (Streak Flow) :** Le mécanisme de streak flow (animations visuelles de combo) est actif dans tous les modes (Learn/Practice/Play).

---

## Non-Functional Requirements

### Performance & Fluidité
- **NFR1 :** Latence de feedback visuel/sonore inférieure à **16ms** (60 FPS), mesurée via Xcode Instruments lors de tests de charge.
- **NFR2 :** Temps de lancement de l'application inférieur à **2 secondes**, mesuré via métriques système (App Launch metrics).

### Fiabilité & Accessibilité
- **NFR3 :** Taux d'erreur de validation mathématique de **0%**, validé par suite de tests unitaires exhaustive.
- **NFR4 :** Respect des standards **WCAG AA** pour le contraste et VoiceOver, validé via Accessibility Inspector.
- **NFR5 :** Taille minimale des cibles de saisie de **44x44 points** (Contrainte bloquante App Store), vérifiée par inspection des composants d'interface.
