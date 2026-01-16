---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/prd-validation-report.md'
  - '_bmad-output/project-knowledge/architecture.md'
  - '_bmad-output/project-knowledge/project-overview.md'
  - '_bmad-output/project-knowledge/index.md'
  - '_bmad-output/project-knowledge/data-models-root.md'
  - '_bmad-output/project-knowledge/source-tree-analysis.md'
---

# UX Design Specification pi-trainer

**Author:** Alex
**Date:** 2026-01-15

---

<!-- UX design content will be appended sequentially through collaborative workflow steps -->

## Executive Summary

### Project Vision
Pi-Trainer est une application mobile iOS native conçue pour transformer la mémorisation des constantes mathématiques en un défi addictif. Le produit mise sur une interface ultra-minimaliste et performante, centrée sur le plaisir de la récitation rapide via le "Streak Flow".

### Target Users
Compétiteurs de mémoire, étudiants passionnés et utilisateurs technophiles cherchant un entraînement cognitif centré sur la performance et la répétition efficace.

### Key Design Challenges
- **Fluidité Prioritaire :** Garantir une latence de réponse <16ms, même pendant les pics d'animations.
- **Feedback Stimulant :** Créer un système de récompense visuelle qui encourage la vitesse sans obstruer la visibilité des chiffres.

### Design Opportunities
- **Système de "Tiered Flow" :** Le retour visuel s'intensifie par paliers (ex: x10, x20, x50 décimales sans erreur).
- **Haptique Rythmique :** Utiliser le Taptic Engine pour confirmer la précision du rythme de frappe.

## Core User Experience

### Defining Experience
L'expérience centrale est un état de "Flow" induit par la répétition rapide et précise. L'interface s'efface au profit de la récitation, ne réapparaissant que comme un système de feedback sensoriel (visuel et haptique) qui valide et encourage la performance.

### Platform Strategy
- **Native iOS :** Utilisation de SwiftUI avec optimisation du rendu via `drawingGroup` pour maintenir 60 FPS constants.
- **Haptic Engine :** Feedback physique distinct pour la validation (clic sec) et l'erreur (vibration double).
- **Zéro Latence :** Persistance locale immédiate via `UserDefaults`/`StatsStore`.

### Effortless Interactions
- **Focus Dynamique :** L'attention de l'utilisateur reste centrée sur le pavé numérique, avec une vision périphérique dédiée au streak.
- **Auto-Chunking :** Groupement visuel instantané des décimales par 10 pour faciliter la lecture/relecture.

### Critical Success Moments
- **PB Achievement :** Célébration subtile mais gratifiante lors du dépassement du record personnel.
- **Flow State Entry :** Activation douce des effets visuels après un streak de 10 décimales sans hésitation.

### Experience Principles
1. **Performance over Aesthetics :** Rien ne doit ralentir la saisie, même l'animation la plus belle.
2. **Sensory Reward :** Chaque réussite doit être "ressentie" physiquement (haptic) et visuellement.
3. **Frictionless Entry :** Lancer une session doit prendre moins de 3 secondes depuis l'ouverture de l'app.

## Desired Emotional Response

### Primary Emotional Goals
L'objectif est de placer l'utilisateur dans la peau d'un **athlète de la mémoire**. L'expérience doit générer de l'adrénaline par la vitesse, tout en récompensant la précision par un sentiment de maîtrise intellectuelle absolue.

### Emotional Journey Mapping
- **Lancement :** Concentration (Calme avant la tempête).
- **Session :** Adrénaline (Montée en puissance via le Streak Flow).
- **Échec :** Détermination (Effet "One more try" immédiat).
- **Succès (PB) :** Exaltation et Maîtrise (Validation de la performance).

### Micro-Emotions
- **Tension vs Flow :** Maintenir une légère excitation qui se transforme en fluidité totale lors des longs streaks.
- **Frustration Positive :** L'échec est un levier de motivation pour recommencer instantanément.

### Design Implications
- **Esthétique "Dark & Sharp" :** Mode sombre OLED profond, typographie technique (monospaced), contrastes élevés (Lime/Cyan électrique).
- **Audio de Tension (Heartbeat) :** Feedback sonore subtil de battement de cœur qui s'accélère à l'approche du record personnel (PB).
- **Haptique Évolutif :** Retour haptique qui devient plus sec et précis au fur et à mesure que le streak augmente.
- **Athlete Mode :** Option permettant de masquer tous les éléments non essentiels pour un tunnel de concentration pur (uniquement le chiffre en cours et le clavier).

### Emotional Design Principles
1. **Challenge-Driven :** Le design doit constamment inciter à dépasser ses limites.
2. **Resilient Failure :** L'échec est une étape d'apprentissage ; le bouton de redémarrage est prioritaire.
3. **Elite Aesthetic :** Un look pro et ultra-performant pour valoriser le sérieux de l'entraînement.

## UX Pattern Analysis & Inspiration

### Inspiring Products Analysis
- **Monkeytype (Performance Tool) :** Maîtrise du flow via une interface minimale. Pattern de feedback immédiat sur la précision et la vitesse (Digital Rain / Minimal Highlight).
- **Strava (Athletic Motivation) :** Gamification basée sur la performance pure et le dépassement de soi (Records Personnels/PB).
- **Rhythm Games (Sensory Immersion) :** Feedback crescendo basé sur le "streak" pour stimuler l'adrénaline.

### Transferable UX Patterns
- **Velocity Tracker :** Afficher discrètement un compteur de "Chiffres par seconde" pour stimuler la vitesse.
- **Progressive Feedback :** Le Streak Flow s'active par paliers de 10, 20, 50, devenant visuellement plus riche.
- **Instant Restart :** Un pattern "Echec -> Recommencement" sans friction (une seule action).

### Anti-Patterns to Avoid
- **Interstitial Overload :** Éviter les pop-ups ou écrans de transition longs entre deux sessions (tue le flow).
- **Gamification Enfantine :** Éviter les mascottes ou couleurs criardes qui nuiraient au côté "Pro / Athlète".

### Design Inspiration Strategy
- **Adopter :** Le minimalisme de Monkeytype pour l'écran de saisie.
- **Adapter :** Le système de records de Strava pour les statistiques de mémorisation.
- **Éviter :** Toute animation qui ralentirait la perception de la saisie (latence visuelle).

## Design System Foundation

### 1.1 Design System Choice
**Système Hybride Custom (Native-Powered)**. Nous utiliserons SwiftUI comme moteur de rendu pur, sans bibliothèque de composants tierce, pour garantir une performance maximale.

### Rationale for Selection
- **Performance :** L'utilisation de composants SwiftUI natifs garantit la fluidité (<16ms) demandée par Amelia.
- **Identité :** Une interface sur mesure est nécessaire pour créer le sentiment d'utiliser un "instrument de précision" plutôt qu'une application classique.
- **Maintenabilité :** Pas de dépendance externe, ce qui assure la pérennité du projet.

### Implementation Approach
- **Tokens :** Palette de couleurs technique, échelle typographique optimisée pour la lecture de chiffres.
- **Composants :** Développement d'un pavé numérique spécifique ("Pro-Pad") et d'un système de rendu de texte optimisé pour les longs streaks.

### Customization Strategy
- Focus sur le **Dark Mode** comme expérience par défaut.
- Typographie **Monospaced** pour les alignements parfaits.
- Utilisation des **SF Symbols** retravaillés pour une esthétique technique.

## 2. Core User Experience

### 2.1 Defining Experience : The Streak Flow
L'expérience centrale est le "Streak Flow", une interaction fluide où la saisie des décimales déclenche une progression sensorielle (visuelle et haptique). Ce n'est plus une récitation, c'est une performance rythmique.

### 2.2 User Mental Model
L'utilisateur perçoit les constantes comme des mélodies numériques découpées en mesures de 10 chiffres. Le design doit supporter cette segmentation mentale sans briser la continuité de la frappe.

### 2.3 Success Criteria
- **Instant Reponse :** <16ms de latence perçue.
- **Rhythmic Feedback :** La sensation physique de la frappe doit aider à maintenir la cadence.
- **Visual Gratification :** L'intensité visuelle doit être proportionnelle au mérite (longueur du streak).

### 2.4 Novel UX Patterns
- **The "Athlete Mode" Toggle :** Un pattern de réduction d'interface poussé à l'extrême pour le focus.
- **Gradual Haptic :** Un retour haptique dont l'intensité ou la texture évolue dynamiquement.

### 2.5 Experience Mechanics
- **Init :** Première saisie = Départ automatique.
- **Loop :** Saisie -> Validation -> Feedback Visuel/Haptic -> Incrémentation Score/Streak.
- **Fail :** Haptique d'erreur -> Freeze visuel -> Affichage de la solution correcte -> Replay prompt.

## Visual Design Foundation

### Color System (Dark & Sharp)
- **Background :** Noir OLED (`#000000`) pour une immersion totale et zéro distraction.
- **Accent Primary :** Cyan Électrique (`#00F2FF`) utilisé avec parcimonie pour le chiffre actif et les moments de flow.
- **Negative Space :** Utilisation massive du vide pour diriger l'attention.
- **Semantic Mapping :** Blanc pur pour la validité, Cyan pour le flow, Rouge profond pour l'erreur fatale.

### Typography System (Technical Monospace)
- **Primary Typeface :** SF Mono (ou JetBrains Mono) pour tous les chiffres. La chasse fixe est cruciale pour la prévisibilité visuelle des blocs de 10.
- **Secondary Typeface :** SF Pro pour les métadonnées (CPS, Streak) en petite taille (Captions).
- **Hierarchy :** Fokus massif sur le chiffre central, métadonnées désaturées en périphérie.

### Spacing & Layout Foundation (Zen-Athlete)
- **Density :** Ultra-épurée. Suppression de tout "chrome" (bordures, conteneurs, ombres).
- **Core Layout :** Un axe central vertical pour les chiffres, clavier borderless en bas.
- **Safe Areas :** Respect strict des marges iOS pour une utilisation confortable à une ou deux mains.

### Accessibility Considerations
- **High Contrast :** Respect des ratios WCAG pour le texte blanc/cyan sur fond noir.
- **Dynamic Type :** Support des tailles de police système tout en préservant l'alignement monospace.
- **Reduced Motion :** Option pour désactiver les auras de flow pour les utilisateurs sensibles.

## Design Direction Decision

### Design Directions Explored
Nous avons exploré 4 directions basées sur le minimalisme extrême (**Zen-Athlete**) :
1. **The Ghost (D1) :** Clavier invisible/fantôme, focus horizontal.
2. **Pure Focus (D2) :** Chiffre unique au centre.
3. **Terminal Flow (D3) :** Blocs verticaux techniques (Monkeytype style).
4. **Data Block (D4) :** Grille dense (Matrix style).

### Chosen Direction : The Hybrid Ghost Terminal
L'approche finale est une fusion de **D1** et **D3**.
- **Structure (D3) :** Affichage par blocs verticaux de 10 chiffres (comme un terminal de code).
- **Interaction (D1) :** Pavé numérique "fantôme" qui s'efface au profit de la zone de saisie.

### Design Rationale
- **Lisibilité :** Le découpage vertical par 10 (Terminal) respecte parfaitement le modèle mental de segmentation des constantes.
- **Concentration :** Le retrait du clavier visuel (Ghost) force l'utilisateur à se fier à sa mémoire musculaire, renforçant l'identité d'athlète.
- **Esthétique :** Un look pro, technique et épuré qui évite tout aspect "jouet".

### Implementation Approach
- Utilisation de colonnes SwiftUI avec `Text` monospaced.
- Le clavier sera rendu avec une opacité très faible (5-10%) ou uniquement via un feedback haptique au toucher.
- Le focus se déplace verticalement par bloc de 10, créant un rythme de "scan" efficace.

## User Journey Flows

### 1. Le "Sprint Immersif" (Le coeur du produit)
Parcours de pratique pure où le **Ghost Terminal** prend tout son sens.
- **Entrée :** Tap sur "START" ou sur le premier chiffre.
- **Action :** Saisie ultra-rapide par blocs de 10. Le clavier s'estompe progressivement.
- **Pivot Flow :** À 20 chiffres sans faute, l'interface passe en mode "Focus Néon" (désactivation de tout élément périphérique).
- **Sortie :** Erreur ou Fin de bloc décidée par l'utilisateur.

### 2. Le "Restart Instantané" (Effet "One More Try")
Pour maintenir l'adrénaline, l'échec est une opportunité de rebond immédiat.
- **Trigger :** Saisie d'un chiffre incorrect.
- **Feedback :** Shake discret de l'écran + mise en évidence rouge de l'erreur.
- **Action :** Bouton de redémarrage prioritaire permettant de relancer une session en <500ms.

### 3. Consultation des Records
- **Action :** Accès rapide aux statistiques CPS et Streaks depuis l'écran de fin.
- **Visualisation :** Graphiques épurés montrant la progression de la "vitesse d'athlète".

### Journey Diagram
```mermaid
graph TD
    A[Écran d'Accueil / Zen] -->|Tap Start| B(Mode Entraînement)
    B --> C{Saisie Chiffre}
    C -->|Correct| D[Feedback Cyan + Haptic Sec]
    D -->|Streak > 20| E[Mode Ghost: Clavier s'efface]
    E --> C
    C -->|Erreur| F[Feedback Rouge + Shake]
    F --> G[Écran de Fin Éclair]
    G -->|Tap Retry| B
    G -->|Swipe Up| H[Stats & Records]
```

### Flow Optimization Principles
1. **Zero Intermediate Screens :** Aucun écran de chargement entre l'accueil et la session.
2. **Haptic Sync :** Chaque étape de la journey est confirmée par une signature haptique unique.
3. **Immersive Persistence :** Le mode "Zen" persiste tant que l'utilisateur n'a pas consciemment quitté la session.

## Component Strategy

### Design System Components
Nous utilisons les fondations de **SwiftUI** sans bibliothèque externe pour préserver une latence <16ms. Les composants standards (List, Button) seront stylisés via des `Style` personnalisés pour correspondre à l'esthétique Zen-Athlete.

### Custom Components

#### 1. Le "Terminal-Grid" (Affichage des chiffres)
- **Purpose :** Affichage vertical rythmé par blocs de 10.
- **Anatomy :** Texte Monospaced, indicateur de ligne (ex: `150 >`) pour le repérage spatial.
- **Behavior :** Défilement fluide vers le haut à mesure que les lignes sont complétées.

#### 2. Le "Pro-Pad" (Le Pavé Numérique "Ghost")
- **Purpose :** Saisie sans friction visuelle.
- **Interaction :** Opacité dynamique de 20% (repos) à 5% (flow intense). 
- **Feedback :** Chaque touche déclenche un micro-flash Cyan et un retour haptique sec.

#### 3. Le "Flow-O-Meter" (Tableau de bord de performance)
- **Purpose :** Monitoring en temps réel de la performance.
- **Content :** 
    - **Position Tracker :** Affichage de l'index de la décimale en cours (ex: `#156`). La valeur s'incrémente instantanément à chaque saisie correcte.
    - **CPS :** Vitesse de frappe actuelle.
    - **Streak :** Compteur de succès consécutifs.
- **Visual :** Typographie technique désaturée, s'intègre en haut de l'écran sans créer de "barre" visuelle.

### Component Implementation Strategy
- **Zéro Dépendance :** Tous les composants sont des `View` SwiftUI pure.
- **Atomic Design :** Création d'un `DigitView` atomique gérant ses propres états d'animation (active, error, ghost).
- **Haptic Engine Service :** Un service centralisé pour déclencher les signatures haptiques selon le composant.

### Implementation Roadmap
- **Phase 1 (Core Engine) :** Terminal-Grid + Pro-Pad basique.
- **Phase 2 (Experience) :** Flow-O-Meter avec incrémentation en temps réel et Position Tracker.
- **Phase 3 (Polissage) :** Opacité dynamique (Ghost Mode) et animations de transition Flow.

## UX Consistency Patterns

### Feedback Patterns
- **Standard Success :** Chaque saisie correcte déclenche un feedback haptique discret (16ms) et un éclat visuel Cyan éphémère.
- **Aggressive Failure :** L'erreur déclenche un "Shake" horizontal de la ligne en cours, une vibration double, et affiche immédiatement la solution correcte pour minimiser la frustration.

### Navigation Patterns (Invisible Navigation)
- **Navigation Lock :** Une fois la session lancée, tous les gestes de navigation (suipes) sont verrouillés pour éviter toute interruption accidentelle.
- **Contextual Discovery :** Des "hints" visuels subtils (flèches estompées) guident les premiers gestes (Swipe Up pour les records) lors de la phase d'onboarding.
- **Exit Trigger :** Le bouton "Quit" n'apparaît qu'en cas d'inactivité prolongée (>3s) ou après une erreur.

### Button Hierarchy
- **Action Pivot (Retry) :** Un bouton massif occupe l'espace central après un échec, incitant au redémarrage immédiat.
- **Secondary Actions :** Les réglages de constante ou d'affichage sont relégués à des taps longs ou des swipes depuis l'accueil, préservant la pureté de l'interface principale.

### Empty States
- **Onboarding Zen :** En l'absence de records, l'application affiche un message invitant au premier sprint : *"Prêt à devenir un athlète de la mémoire ?"*.

## Responsive Design & Accessibility

### Responsive Strategy
- **Mobile-First (Performance) :** Optimisation pour la latence et l'utilisation à une main sur iPhone. L'expérience est taillée pour des sessions courtes et intenses en mobilité.
- **iPad Support :** Layout étendu permettant de voir jusqu'à 100 décimales simultanément (vision panoramique) tout en conservant le Terminal-Grid.
- **Orientation :** Verrouillage en mode Portrait pour la saisie active (optimisation ergonomie clavier).

### Accessibility Strategy
- **Visual :** Thème high-contrast par défaut (OLED Black / Cyan). Support du Dynamic Type pour l'interface de statistiques et d'onboarding.
- **Motion :** Toggle "Zen-Mode Plus" pour supprimer toutes les animations non indispensables (reduction of motion).
- **Haptic :** Feedback physique redondant pour chaque action critique (Saisie/Erreur) pour les utilisateurs ayant des troubles de l'attention ou de la vision.
- **VoiceOver :** Chaque bloc de 10 sera annoncé comme une unité logique lors de la relecture.

### Testing Strategy
- Validation sur VoiceOver pour le flux de saisie active.
- Tests d'ergonomie "One-Hand" sur les différents formats d'iPhone.
- Vérification du contraste WCAG sur les zones d'opacité du Ghost Mode.
