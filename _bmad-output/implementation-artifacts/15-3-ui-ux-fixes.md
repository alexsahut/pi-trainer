# Story 15.3: UI & UX Fixes — Keypad, Navigation et Localisation

Status: done

## Story

En tant qu'utilisateur,
Je veux que l'interface soit cohérente, réactive et entièrement traduite,
Afin de ne pas rencontrer de problèmes visuels, de navigation fragile ou de textes non localisés.

## Acceptance Criteria (AC)

1. **AC1**: `KeypadButton` adapte sa font size ou utilise `.minimumScaleFactor` pour que les labels longs (ex: "Réinitialiser") ne débordent pas.
2. **AC2**: Remplacer `DispatchQueue.main.asyncAfter` par `Task.sleep` annulable dans `ChallengeSessionView` pour la navigation post-challenge.
3. **AC3**: Les textes visibles dans Challenge Hub/Session passent par `String(localized:)` : "CHALLENGES", "TRAIN NOW", "Unlimited practice…", "XP".
4. **AC4**: Supprimer le code mort identifié : `constantTitle` dans `HomeView`, commentaire dupliqué dans `ChallengeViewModel`.

## Tasks / Subtasks

- [x] **Task 1 — KeypadButton overflow fix** (AC: #1)
  - [x] 1.1 Ouvrir `KeypadView.swift` et localiser le composant `KeypadButton`
  - [x] 1.2 Ajouter `.minimumScaleFactor(0.5)` et `.lineLimit(1)` aux labels textuels (RESET, QUIT)
  - [x] 1.3 Vérifier visuellement que les textes FR ("Réinitialiser", "Quitter") ne débordent plus

- [x] **Task 2 — Navigation annulable** (AC: #2)
  - [x] 2.1 Ouvrir `ChallengeSessionView.swift`
  - [x] 2.2 Remplacer les 2 `DispatchQueue.main.asyncAfter` (2.5s et 0.3s) par `Task { try? await Task.sleep(for: .seconds(…)) }`
  - [x] 2.3 Stocker la `Task` dans une variable pour annulation au `onDisappear`

- [x] **Task 3 — Localisation des textes en dur** (AC: #3)
  - [x] 3.1 Dans `ChallengeHubView.swift` : localiser "CHALLENGES" (L33), "TRAIN NOW" (L81), "Unlimited practice…" (L93)
  - [x] 3.2 Dans `GradeBadge.swift` : localiser "XP" (L41)
  - [x] 3.3 Ajouter les clés correspondantes dans `Localizable.xcstrings` (en + fr)

- [x] **Task 4 — Suppression du code mort** (AC: #4)
  - [x] 4.1 Supprimer `constantTitle` dans `HomeView.swift` (L211-218)
  - [x] 4.2 Supprimer le commentaire dupliqué `// Derived properties` dans `ChallengeViewModel.swift`

- [x] **Task 5 — Validation Finale**
  - [x] 5.1 `xcodebuild build` — BUILD SUCCEEDED
  - [x] 5.2 Lancer les tests unitaires pertinents

### Review Follow-ups (AI)
- [x] [AI-Review][LOW] Nettoyage des commentaires exploratoires obsolètes dans `ChallengeSessionView` (shouldNavigateToPractice handler)

## Dev Notes

### Fichiers à modifier

| Fichier | Changement |
|:---|:---|
| `KeypadView.swift` | `.minimumScaleFactor` + `.lineLimit(1)` sur labels |
| `ChallengeSessionView.swift` | `asyncAfter` → `Task.sleep` annulable |
| `ChallengeHubView.swift` | Localisation des textes en dur |
| `GradeBadge.swift` | Localisation "XP" |
| `HomeView.swift` | Suppression `constantTitle` dead code |
| `ChallengeViewModel.swift` | Suppression commentaire dupliqué |
| `Localizable.xcstrings` | Nouvelles clés de traduction |

### Points d'attention

- **CR-5 (instanciation inline ChallengeService) et CR-6 (StatsStore.shared hardcodé)** sont des refactorings d'architecture plus profonds. Ils sont volontairement exclus de cette story pour limiter le scope et seront traités dans Story 15.5 (Polish technique).
- Le `KeypadButton` utilise probablement un `Text()` avec une taille fixe. L'ajout de `.minimumScaleFactor` est la solution la plus sûre sans changer le layout.

### References

- [Source: code-review-epics-9-14.md#CR-4, CR-8, CR-9, CR-10](file:///Users/alexandre/.gemini/antigravity/brain/6c7d47ce-6ce8-42fc-a5f7-de55a1f54817/code-review-epics-9-14.md)
- [Source: epic-15-consolidation.md#Story-15.3](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/implementation-artifacts/epic-15-consolidation.md)

## Dev Agent Record

### Agent Model Used

### Completion Notes List

### File List
