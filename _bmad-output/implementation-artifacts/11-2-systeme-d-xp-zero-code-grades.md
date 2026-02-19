# Story 11.2: Système d'XP "Zero-Code" & Grades

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a athlète de la mémoire,
I want que mon rang (Grade) reflète mon volume d'entraînement total,
so that afficher mon niveau d'expertise et visualiser ma progression à long terme.

## Acceptance Criteria

1.  [x] **XP System (Zero-Code) :** L'XP correspond strictement au `totalCorrectDigits` (somme de toutes les décimales correctes saisies depuis le début). Pas de base de données dédiée, calculé à volée ou via `StatsStore`.
2.  [x] **Grades Dynamiques :** Le Grade est déterminé instantanément par le total d'XP selon les paliers définis :
    -   **Novice** : 0 - 999
    -   **Apprenti** : 1,000 - 4,999
    -   **Athlète** : 5,000 - 19,999
    -   **Expert** : 20,000 - 99,999
    -   **Grandmaster** : 100,000+
3.  [x] **StatsStore :** Création d'un singleton `StatsStore` (Observable) qui agrège les statistiques globales (XP, Temps total) à partir de la persistance existante, optimisé pour l'accès instantané (cache UserDefaults pour le total).
4.  [x] **Modélisation :** Création de l'enum `Grade` avec logique de seuil et assets associés (SF Symbols).
5.  [x] **UI Feedback :** Affichage du Grade et de l'XP sur le Dashboard de l'écran d'accueil (ou Profile si existant) en respectant la charte "Zen-Athlete" (Badge + Glow).

## Tasks / Subtasks

-   [x] **Infrastructure Core (StatsStore)** (AC: 1, 3)
    -   [x] Créer `Core/Persistence/StatsStore.swift` (Singleton, @Observable).
    -   [x] Implémenter la persistence légère du `totalCorrectDigits` dans `UserDefaults` pour éviter de parser tout l'historique au lancement.
    -   [x] Connecter `PracticeEngine` pour incrémenter `StatsStore.totalCorrectDigits` à chaque fin de session réussie.

-   [x] **Modélisation des Grades** (AC: 2, 4)
    -   [x] Créer `Shared/Models/Grade.swift`.
    -   [x] Implémenter l'enum `Grade` avec propriétés : `range`, `displayName`, `iconName`, `color` (si applicable).
    -   [x] Implémenter la méthode statique `Grade.from(xp: Int) -> Grade`.

-   [x] **Intégration UI (Dashboard)** (AC: 5)
    -   [x] Créer/Mettre à jour `Features/Home/Components/GradeBadge.swift` (Pattern SF Symbol + Glow).
    -   [x] Créer `Features/Home/Components/XPProgressBar.swift` (Optionnel pour V1, voir UX Spec).
    -   [x] Intégrer les indicateurs dans `HomeView` ou le nouveau `DashboardView` (V2.1 Pattern).

## Dev Notes

### Architecture & Logic Compliance

-   **Zero-Code Principle :** "Zero-Code" signifie ici "Zero-Backend" et "Zero-Complex-DB". On utilise les données brutes existantes.
-   **StatsStore Responsibility :** Il doit devenir la source de vérité pour les métriques agrégées.
-   **Persistence Optimization :** Ne JAMAIS recalculer la somme de l'historique (fichiers JSON) au lancement. Stocker la somme courante dans `UserDefaults` et l'incrémenter. Re-scan complet uniquement en cas de "Recalculate Stats" (Maintenance).

### Design System Compliance

-   **Grade Badge :** Utiliser les SF Symbols monochromes avec un effet de "Glow" (Shadow colorée).
-   **Colors :**
    -   XP / Endurance : **Cyan Électrique** (`#00F2FF`).
    -   Grade Glow : Proportionnel au rang ou Cyan par défaut.

### References

-   [Architecture V2.8 Gamification](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#Section-V2.8-Gamification-Architecture-Simplified)
-   [UX Design Specification - Epic 11 Extension](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md#Section-V2-Feature-Extensions)
-   [Epics Definition](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)

## Dev Agent Record

### Agent Model Used

Antigravity (Claude 3.5 Sonnet)

### Completion Notes List

-   Analyzed Architecture V2.8 and UX Specs for Epic 11.
-   Identified missing `StatsStore.swift` as a critical dependency to be created.
-   Defined `Grade` logic based on specified thresholds.
-   Aligned UI tasks with "Zen-Athlete" design system requirements.

### File List

-   `PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift` (New)
-   `PiTrainer/PiTrainer/Shared/Models/Grade.swift` (New)
-   `PiTrainer/PiTrainer/Features/Home/Components/GradeBadge.swift` (New)
-   `PiTrainer/PiTrainer/Features/Home/HomeView.swift` (Update)
