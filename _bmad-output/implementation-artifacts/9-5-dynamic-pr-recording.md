# Story 9.5: Dynamic PR Recording & Rules

**Parent:** Epic 9 - Mode Game (Ghost System & Atmospheric Feedback)
**Status:** done

## User Story

**As a** gamer,
**I want** que le système certifie mes sessions et mette à jour mes records personnels dynamiquement,
**So that** mes fantômes représentent mes meilleures performances réelles et respectent les règles de compétition.

## Acceptance Criteria

- [ ] **Certification Logic:** Une session est certifiée si `sessionMode != .learn`, `revealsUsed == 0` et `errors == 0`.
- [ ] **Twin-Shadows Recording:**
    - [ ] **Crown PR (Distance):** Enregistre le record de distance. Si distances égales, le temps le plus court l'emporte.
    - [ ] **Lightning PR (Speed):** Enregistre le record de vitesse (CPS) si distance > 50 chiffres.
- [ ] **Timestamps Strategy:** Enregistre `Date().timeIntervalSince(startTime)` à chaque input correct pour l'interpolation du Ghost.
- [ ] **Uncertified Exclusion:** Les sessions avec erreurs ou révélations sont sauvegardées dans l'historique mais JAMAIS utilisées comme Ghosts.
- [ ] **Ghost Selection:** Le système choisit le Ghost approprié (Marathon vs Sprint) selon le dernier mode joué ou préférence.

## Tasks
- [x] Implement certification logic in `SessionViewModel` (Property `isCertified`).
- [x] Update `PracticeEngine` to track timestamps and support certification data.
- [x] Implement `PersonalBestStore` logic for Crown vs Lightning records.
- [x] Update `endSession` to trigger PR checks and persistence.
- [x] Add unit tests for `PersonalBestStore` (Crown/Lightning logic).
- [x] Verify `SessionViewModel` certification integration via tests.
- [x] **Review Follow-ups (AI)**
    - [x] [AI-Review][HIGH] Correction de la logique de certification (`errors == 0`) dans `SessionViewModel.swift` [L110]
    - [x] [AI-Review][MEDIUM] Implémentation de la sélection dynamique du Ghost (Crown vs Lightning) dans `SessionViewModel.swift` [L142]
    - [x] [AI-Review][MEDIUM] Mise à jour de la `File List` avec les fichiers manquants (`SessionViewModel+Game.swift`, `DesignSystem.swift`)
    - [x] [AI-Review][LOW] Sécurisation de la persistence dans `endSession` (gestion du cycle de vie de la Task)
    - [x] [AI-Review][LOW] Ajout de tests d'intégration pour le cycle de vie de la certification dans `SessionViewModel`

## Technical Notes

### 1. Engine Updates (`PracticeEngine.swift`)
- Assurer que `cumulativeTimes` est correctement rempli à chaque input validé.
- Ajouter un flag `isCertified` calculé lors de l'enregistrement.

### 2. Persistence Layer (`PersonalBestStore.swift`)
- Gérer les deux slots de records (Crown vs Lightning).
- Implémenter la logique de comparaison pour les nouveaux records.

### 3. ViewModel Integration (`SessionViewModel.swift`)
- Mettre à jour `endSession` pour invoquer la certification et la sauvegarde sélective.

## Dev Agent Record

### File List
- `PiTrainer/PiTrainer/Core/Features/Practice/PracticeEngine.swift`
- `PiTrainer/PiTrainer/Core/Persistence/PersonalBestStore.swift`
- `PiTrainer/PiTrainer/SessionViewModel.swift`
- `PiTrainer/PiTrainer/SessionViewModel+Game.swift`
- `PiTrainer/PiTrainer/DesignSystem.swift`
- `PiTrainer/PiTrainer/Shared/Models/PersonalBestRecord.swift`
- `PiTrainer/PiTrainerTests/PersonalBestStoreTests.swift` [NEW]
- `PiTrainer/PiTrainerTests/SessionViewModelIntegrationTests.swift` [NEW]

### Change Log
- **2026-01-20:** Initialized Story 9.5 to handle certification and dynamic PR updates.
- **2026-01-21:** Added Tasks section. Implemented core logic for certification and PR types. Created comprehensive unit tests for PersonalBestStore covering all PR scenarios. Verified GhostEngine regressions fixed. Marked ready for review.
- **2026-01-21:** Addressed adversarial code review findings. Enforced strict certification (0 errors). Implemented Smart Ghost Selection (Crown > Lightning). Secured persistence tasks. Validated with `SessionViewModelIntegrationTests`. Verified by user via Walkthrough. Marked Done.
- **2026-01-21:** Fixed Sudden Death paradox where error while ahead prevented certification. Added `isNewPR` flag for accurate UI feedback. Improved ghost selection with robust fallback and added boundary tests for Lightning PR.
