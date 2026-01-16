# Story 3.4: Intégrité du Build & Vérification des Ressources (Technical)

**Epic**: Epic 3: Gestion des Sessions & Mode Strict
**Status**: in-progress

## Description
As a développeur / DevOps,
I want que le build échoue ou alerte si des ressources critiques (fichiers de constantes) sont manquantes,
So that ne jamais déployer une version cassée ("Broken Build").

## Acceptance Criteria
- [x] **Given** le projet Xcode, **When** je lance les tests unitaires (`AssetIntegrityTests`), **Then** le système vérifie la présence physique des fichiers `pi_digits.txt`, `e_digits.txt`, `phi_digits.txt` dans le bundle
- [x] **And** le `FileDigitsProvider` lève une erreur explicite si un fichier est manquant
- [x] **And** `SessionViewModel` gère gracieusement l'absence de données (pas de crash, pas d'état incohérent).

## Tasks
- [x] Create `AssetIntegrityTests.swift` and verify it fails if files missing
- [x] Refactor `FileDigitsProvider` to throw specific errors
- [x] Update `SessionViewModel` to handle initialization errors

## Dev Notes
- Context: Regression found where missing `pi_digits.txt` caused silent failure in SessionView.
- Architecture: `FileDigitsProvider` currently swallows errors or uses fallback. Needs to be strict.
- Testing: New test suite `AssetIntegrityTests` should be added to the Test Target.
- **Verification Finding**: `AssetIntegrityTests` successfully caught that `pi_digits.txt`, `e_digits.txt`, and `phi_digits.txt` were missing from the Xcode Target (project.pbxproj), confirming the regression root cause.
