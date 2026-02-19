# Story 15.2: Challenge Mode Cold Start Fix

Status: done

## Story

En tant qu'utilisateur sur une installation fraîche,
Je veux que le Challenge Mode fonctionne correctement dès le départ (ou affiche un pré-requis clair),
Afin de pouvoir utiliser les Défis Quotidiens sans rencontrer de bugs liés à un historique vierge.

## Acceptance Criteria (AC)

1. **AC1**: **Minimum viable `highestIndex`** ✅ — Si `highestIndex < 50`, le hub Challenge affiche un état verrouillé avec un message "Practice X digits to unlock".
2. **AC2**: **Validation MUS end-to-end** ✅ — `ChallengeService.createChallenge` valide que `referenceSequence + expectedNextDigits` correspond exactement aux bytes à `startIndex`.
3. **AC3**: **Recovery Bridge cohérent** ✅ — Le `startIndex` est maintenant garanti correct grâce à la validation E2E, donc le Recovery Bridge pointe automatiquement vers le bon segment.
4. **AC4**: **Tests unitaires** ✅ — Tests ajoutés pour `highestIndex = 0`, `highestIndex = 49` (nil), E2E sequence match, eligibility below/above threshold, trainNow ineligible.

## Tasks / Subtasks

- [x] **Task 1 — Garde-fous et blocage UI** (AC: #1)
  - [x] 1.1 `ChallengeHubViewModel` : ajout `isChallengeEligible`, `digitsRemainingToUnlock`, `minimumDigitsForChallenge = 50`
  - [x] 1.2 `ChallengeHubView` : état verrouillé avec icône cadenas + texte localisé
  - [x] 1.3 Tests du VM : `testChallengeEligibility_BelowThreshold`, `testChallengeEligibility_AboveThreshold`, `testTrainNow_NotEligible_ReturnsNil`

- [x] **Task 2 — Moteur de validation MUS End-to-End** (AC: #2, #3)
  - [x] 2.1 `ChallengeService` : ajout `minimumHighestIndex = 50` avec guard dans les deux méthodes generate
  - [x] 2.2 Remplacement de `max(1, highestIndex)` par un guard strict avec retour nil
  - [x] 2.3 Post-check E2E dans `createChallenge` : vérifie que `refSeq + expected` == `allDigits[startIndex...]`

- [x] **Task 3 — Vérification des tests existants** (AC: #4)
  - [x] 3.1 Test `testGenerateChallenge_HighestIndexTooLow_ReturnsNil` (index 0 et 49)
  - [x] 3.2 Test `testGenerateChallenge_E2E_SequenceMatchesProvider` (validation séquence réelle)
  - [x] 3.3 Mise à jour de tous les tests existants pour highestIndex >= 50

- [x] **Task 4 — Validation Finale**
  - [x] 4.1 BUILD SUCCEEDED
  - [x] 4.2 Tests ChallengeService + ChallengeHubViewModel : exit code 0

### Review Follow-ups (AI)
- [x] [AI-Review][HIGH] Add missing localization keys `challenge_locked_title` + `challenge_locked_body` to Localizable.xcstrings
- [x] [AI-Review][HIGH] Deduplicate threshold constant — VM now uses `ChallengeService.minimumHighestIndex`
- [x] [AI-Review][MEDIUM] Fix tautological E2E validation — now checks ASCII digit range + sequence length
- [x] [AI-Review][LOW] Remove redundant `let highestIndex = rawHighestIndex` assignment

## Dev Notes

### Décisions techniques

- **Seuil minimum = 50 digits** : Choisi empiriquement. Assez grand pour que le MUS ait un espace de recherche significatif, assez petit pour ne pas décourager les nouveaux utilisateurs.
- **Double garde-fou** : Le check d'éligibilité est fait à 2 niveaux — dans le ViewModel (UI) ET dans le Service (logique). Même si le UI est contourné, le service refuse de générer un challenge sous le seuil.
- **E2E Validation** : Comparaison byte-à-byte entre la séquence générée et les bytes réels à `startIndex`. Si la validation échoue, `createChallenge` retourne nil et le retry loop continue.

### References

- [Source: epic-15-consolidation.md#Story-15.2](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-15-consolidation.md)

## Dev Agent Record

### Agent Model Used

Claude (Antigravity)

### Completion Notes List

- ✅ AC1: Added `isChallengeEligible` + `digitsRemainingToUnlock` to `ChallengeHubViewModel`, locked UI in `ChallengeHubView`
- ✅ AC2: Added E2E post-validation in `ChallengeService.createChallenge` + minimum threshold guard in both generate methods
- ✅ AC3: Recovery Bridge now guaranteed correct via E2E-validated `startIndex`
- ✅ AC4: 5 new tests added, all existing test fixtures updated for minimum threshold

### File List

- `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubViewModel.swift` — eligibility check, persistence injection, @MainActor
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift` — locked state UI with lock icon
- `PiTrainer/PiTrainer/Features/Challenges/ChallengeService.swift` — minimumHighestIndex guard + E2E validation
- `PiTrainer/PiTrainerTests/ChallengeServiceTests.swift` — 5 new tests + all fixtures updated
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — status tracking
