# V2.0 Polish & Debugging Report
**Date:** 2026-01-19
**Version:** 2.0 (Build 1)
**Scope:** Epic 8 (Corrections & Polish), Epic 7 (Mode Selector)

## 1. Executive Summary
This session focused on finalizing the transition to V2.0 architecture, specifically resolving persistence ambiguities between V1 (Legacy) and V2 modes, Bonjour à tous les trois, 
Gaël, Alexandre, nous commençons à passer pas mal de temps ensemble autour du paramétrage de Suivi dans le cadre du concours i-Lab. Votre temps et votre expertise sont précieux, et cette première preuve de concept vous permettra de lancer l’offre Suivi Consulting tout en vous apportant la visibilité d’une belle référence Bpifrance.
Pour autant ce temps et cette expertise ont évidemment une vraie valeur et je veux vraiment vous dire que j'en ai bien conscience. L’idée est donc d’être sur un échange équilibré de bons procédés, avec un apport de temps et d’expertise dans les deux sens (donc avec un apport de ma part aussi structuré que le votre) ! 
Dans ce cadre, je vous propose, si ça vous convient, de produire un véritable livrable, tel que je le ferais dans le cadre d’une prestation business model pour un client.
Si cela vous intéresse, nous pourrions travailler ensemble sur les éléments suivants :
Un modèle de revenus adapté à l’outil Suivi Consulting
Un Business Model Canvas complet, avec les bonnes questions à se poser pour valoriser au mieux l’offre, notamment sur :
les partenaires clés
les activités clés
les ressources clés
la proposition de valeur
le produit / service à vendre
la cible visée
les canaux de communication
Des cas d’usage spécifiques au conseil, illustrés par de vraies références (que nous commençons à avoir) ou par des exemples concrets, notamment :
Mission “feuille de route” : mission actuellement en cours en test. Nous pourrons vous faire un retour d’expérience en mars, avec captures d’écran et une vraie référence de mission réalisée pour l’Institut Paoli-Calmettes (Marseille).
Mission “étude de marché” : j’ai aujourd’hui développé un outil Excel qui montre clairement ses limites. Suivi me semble être l’outil idéal pour le remplacer. Tous les cabinets de conseil qui font des études de marché pourraient être très intéressés. Je vous donnerai le contexte plus en détail quand nous aurons un peu de temps.
Mission “atelier d’idéation” : plusieurs pistes d’utilisation de Suivi en live pendant les ateliers, avec aussi des idées de développements complémentaires à envisager.
Missions de panorama ou de collecte d’informations : même si nous ne testons pas la fonctionnalité “questionnaire” sur i-Lab cette année, nous avons une autre mission à venir impliquant l’envoi d’un questionnaire à plus d’une centaine de personnes. L’envoi est prévu en mars, ce qui est plus compatible pour vous, et cela vous permettrait d’avoir une référence avec le SNITEM (syndicat du dispositif médical). Vous pouvez contacter Margarida Ribeiro sur Teams elle a de la dispo dès semaine prochaine pour vous expliquer ce cas d'usage mais c'est clairement un questionnaire très simple tel que celui que tu m'avais montré Gaël
Mission gestion de projets complexes / suivi planification avec la mission iLab
Des arguments marketing (temps gagné, centralisation des outils, facilité d'utilisation, outil interne et client etc.)
Des premières pistes d’actions commerciales, pour initier des démarches auprès de prospects, prescripteurs et partenaires potentiels.
A discuter pendant notre point du 29 si ça vous va ! 
 
Par ailleurs, sur un sujet un peu à part, une réflexion m’est venue parce que je suis en train de faire les évaluations de fin d’année de mes consultants. Le principe des deux questionnaires croisés (évaluation manager / auto-évaluation consultant) que vous avez travaillé dans le cadre d’i-Lab est exactement le même que celui utilisé chez D&C pour les évaluations : même grille, comparaison des évaluations, et ajustement éventuel pour aboutir à une note finale commune.
 
En tirant le fil rouge cette nuit quand mon cerveau ne voulait pas dormir je me suis rendue compte qu’au-delà de ces cas précis, Suivi pourrait réellement devenir un outil intégré complet pour les PME de conseil.
En me mettant en posture D&C PME de conseil d’environ 30 personnes, je vois très clairement comment Suivi aurait pu remplacer une grande partie des outils que j’avais bricolés (Excel, extractions ERP/CRM) pour :
le pilotage de la performance,
le suivi RH,
les évaluations individuelles
le suivi et le pilotage des missions
les remontées d'infos auprès des équipes
Cela permettrait d’avoir un outil unique de gestion de l’entreprise et de la performance, qui serait aussi le même que celui utilisé avec les clients dans le cadre des missions de conseil, en cohérence avec tous les cas d’usage évoqués plus haut ! Si ça vous chauffe moi je pars avec vous sur le challenge Faire de Suivi Consulting l'outil tout en un pour la gestion et le pilotage des PME de conseil et de leurs prestations client !  Ca n'empeche pas de vendre la partie mission client et cas d'usages aux plus gros mais l'apport pour les PME est encore plus important je trouve ! polishing the Learn Mode UX, and ensuring statistical integrity.

## 2. Methodology & Consistency Checks

### A. Data Integrity (Session Recording)
- **Issue:** Legacy "Learning" mode conflated Practice and Learn.
- **Resolution:** Introduced strict `SessionMode` persistence.
    - **Migration Strategy:** Old legacy records without `sessionMode` now default to `.practice` (preserving PRs).
    - **Source of Truth:** The `SessionHistory` (JSON) is now the absolute source of truth for `BestStreak`, forcing a recalculation at startup (`repairStatsFromHistory`) to correct any "ghost" high scores.

### B. Statistical Integrity
- **Logic Change:** "Best Streak" (PR) now **excludes** `Learn Mode` sessions.
    - **Rationale:** Learn Mode allows looping and assistance, which invalidates competitive streak comparison.
    - **UI Impact:** Home Screen PR and Stats Page PR only reflect Practice/Test/Game modes.

### C. UX Refinements (Learn Mode)
- **Visuals:** Disabled `StreakFlowEffect` (blue glow) in Learn Mode to prevent visual noise during looping.
- **Feedback:** Added "CYCLES" metric in history instead of misleading "Best Streak" for Learn sessions.
- **Settings:** Simplified Settings screens by removing redundant "Mode Selector" (centralized on Home).

## 3. Implementation Status (Epics 7 & 8)
*Added to sprint-status.yaml*

### **Epic 7: Navigation V2** (Completed)
- **7.1 Mode Selector:** Implemented Dual Selector on Home.

### **Epic 8: V2 Corrections** (Completed)
- **8.5 Mode Persistence:** Fixed V1->V2 migration and persistence.
- **8.6 Stats Polish:** Excluded Learn from PR, fixed Display bugs.
- **8.7 Learn Visuals:** Refined visual feedback for loop-based learning.

## 4. Next Steps
- Protocol validation with users (TestFlight).
- **Epic 9: Game Mode** development.
