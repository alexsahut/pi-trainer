# Sprint Change Proposal: FR9/FR15 Logic Clarification

## Section 1: Issue Summary
L'analyse de préparation à l'implémentation a révélé une ambiguïté logique entre la **FR9** (Game Mode : non-bloquant) et la **FR15** (Mode Indulgent : auto-advance optionnel). Sans clarification, une session de jeu pourrait se retrouver bloquée par une erreur si l'utilisateur désactive l'option globale correspondante.

## Section 2: Impact Analysis
- **PRD Impact :** Clarification des liens de dépendance entre FR9 et FR15.
- **Epic Impact :** Stories 9.4 et 10.1 mises à jour pour spécifier le comportement forcé.
- **Architecture Impact :** Le `PracticeEngine` devient responsable du forçage de l'auto-advance en Game Mode.
- **Technical Impact :** Changement mineur de logique dans le moteur de validation.

## Section 3: Recommended Approach
**Direct Adjustment (Option 1) :** Les modifications ont été appliquées directement aux artefacts existants. Cette approche est la plus efficace car elle ne change pas le périmètre global mais sécurise l'implémentation.

## Section 4: Detailed Change Proposals

### PRD Modifications
- **FR9 :** Ajout de la dépendance forcée à FR15.
- **FR15 :** Précision sur le caractère obligatoire pour le Game Mode.

### Epic Modifications
- **Story 9.4 :** AC ajoutée pour forcer l'auto-advance.
- **Story 10.1 :** AC modifiée pour limiter le toggle au mode Practice.

### Architecture Modifications
- **PracticeEngine :** Responsabilité explicite pour le forçage de la logique.

## Section 5: Implementation Handoff
- **Classification :** Minor (Ajustement de logique métier).
- **Handoff :** Équipe de développement (Dev Agent).
- **Success Criteria :** Les tests unitaires du `PracticeEngine` valident que l'auto-advance est actif en Game Mode même si l'option utilisateur est désactivée.
