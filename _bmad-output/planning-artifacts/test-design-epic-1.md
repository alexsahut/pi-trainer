# Test Design: Epic 1 - Fondations de Pratique & Feedback Sensoriel

**Epic**: 1
**Scope**: Epic-Level (Phase 4)
**Version**: 1.0

## Risk Assessment

| Risk ID | Category | Description | Probability | Impact | Score | Mitigation |
| ------- | -------- | ----------- | ----------- | ------ | ----- | --------------- |
| R-101   | BUS      | Latence haptique/visuelle > 16ms brisant le "Flow" | 2 (Possible) | 3 (Critical) | **6** | Optimisation Main Thread, Haptics Pre-warming, Instrument-based testing |
| R-102   | DATA     | Perte de données de records (PB) ou historique | 1 (Unlikely) | 3 (Critical) | 3 | Sauvegarde atomique UserDefaults + Fichiers asynchrones |
| R-103   | TECH     | Race condition entre saisie rapide (>10Hz) et validation | 2 (Possible) | 2 (Degraded) | 4 | Queue série dédiée pour la validation, @Observable state |
| R-104   | PERF     | Chute de FPS sur anciens appareils lors des animations | 2 (Possible) | 2 (Degraded) | 4 | Utilisation de `.drawingGroup()` et Metal |
| R-105   | BUS      | Validation incorrecte d'une décimale (Faux négatif) | 1 (Unlikely) | 3 (Critical) | 3 | Tests unitaires exhaustifs sur le dataset de validation |

## Coverage Matrix

| Requirement (Story) | Test Level | Priority | Risk Link | Test Count | Owner |
| ------------------- | ---------- | -------- | --------- | ---------- | ----- |
| **Story 1.1** (Init/Arch) | Component  | P1       | R-104     | 2          | Dev   |
| **Story 1.2** (Haptics)   | Unit       | P0       | R-101     | 4          | Dev   |
| **Story 1.2** (Haptics)   | Manual     | P0       | R-101     | 1          | QA    |
| **Story 1.3** (Pro-Pad)   | UI/Component | P1     | R-101     | 3          | Dev   |
| **Story 1.4** (Engine)    | Unit       | P0       | R-103, R-105 | 10+    | Dev   |
| **Story 1.4** (Engine)    | Integration| P0       | R-103     | 5          | Dev   |

## Execution Order

### Smoke Tests (<5 min)
- Lancement de l'application (Story 1.1)
- Démarrage d'une session (Story 1.4)
- Saisie de quelques chiffres avec retour visuel (Story 1.3)

### P0 Tests (Critical Path - <10 min)
- **Validation Engine**: Test de séquences correctes et incorrectes (Pi, e).
- **Haptics**: Vérification que le service est appelé (Mock).
- **Performance**: Benchmark de la boucle de validation (<1ms).

### P1 Tests (Important - <30 min)
- **Layout**: Vérification des Safe Areas sur différents devices.
- **Settings**: Activation/Désactivation des Haptics.
- **Persistence**: Sauvegarde et rechargement de l'index de progression.

## Test Effort Estimates

- **P0 scenarios**: 20 tests × 10 mins (dev) = ~3 hours
- **P1 scenarios**: 10 tests × 15 mins = ~2.5 hours
- **Manual Verification**: Haptics feeling & Latency check = 1 hour
- **Total**: ~6.5 hours

## Quality Gate Criteria

- **Unit Tests Pass Rate**: 100%
- **Critical Path Coverage**: >90% (Engine & Haptics logic)
- **Performance**: Pas de drop de frame visible (>55 FPS) sur device de test.
- **Haptics**: Ressenti "instantané" validé manuellement.

