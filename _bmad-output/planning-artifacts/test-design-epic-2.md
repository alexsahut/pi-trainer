# Test Design: Epic 2 - Expérience "Ghost Terminal" & Visualisation

**Date:** 2026-01-16
**Author:** Alex
**Status:** Draft
**Epic**: 2
**Scope**: Epic-Level (Phase 4)

---

## Executive Summary

**Scope:** Test design complet pour Epic 2 - Interface visuelle Ghost Terminal

**Risk Summary:**
- Risques totaux identifiés: 6
- Risques haute priorité (≥6): 2
- Catégories principales: PERF, BUS, TECH

**Coverage Summary:**
- P0 scenarios: 8 tests (~4 heures)
- P1 scenarios: 12 tests (~3 heures)
- P2 scenarios: 6 tests (~1 heure)
- **Total effort**: ~8 heures (~1 jour)

---

## Risk Assessment

### High-Priority Risks (Score ≥6)

| Risk ID | Catégorie | Description | Prob. | Impact | Score | Mitigation | Owner | Timeline |
|---------|-----------|-------------|-------|--------|-------|------------|-------|----------|
| R-201 | PERF | Chute de FPS lors du rendu Terminal-Grid avec 100+ chiffres | 2 | 3 | **6** | Utilisation `.drawingGroup()`, rendu Metal, lazy loading | Dev | Sprint 2 |
| R-202 | BUS | Ghost Mode réduit trop l'opacité rendant l'interface inutilisable | 2 | 3 | **6** | Seuil minimum d'opacité à 5%, tests manuels d'utilisabilité | Dev | Sprint 2 |

### Medium-Priority Risks (Score 3-4)

| Risk ID | Catégorie | Description | Prob. | Impact | Score | Mitigation | Owner |
|---------|-----------|-------------|-------|--------|-------|------------|-------|
| R-203 | TECH | Désynchronisation Position Tracker vs index réel PracticeEngine | 2 | 2 | 4 | Binding direct @Observable, tests unitaires | Dev |
| R-204 | PERF | Animations Streak Flow causant des stutters sur anciens devices | 2 | 2 | 4 | Animations simples, `.withAnimation(.linear)`, profiling | Dev |
| R-205 | BUS | Transition d'opacité Ghost Mode non fluide (saccadée) | 2 | 2 | 4 | Animation de 1s avec courbe easeInOut, tests visuels | Dev |

### Low-Priority Risks (Score 1-2)

| Risk ID | Catégorie | Description | Prob. | Impact | Score | Action |
|---------|-----------|-------------|-------|--------|-------|--------|
| R-206 | TECH | Calcul incorrect du streak count (off-by-one) | 1 | 2 | 2 | Tests unitaires sur les cas limites (0, 1, 10, 20) |

### Risk Category Legend

- **TECH**: Technical/Architecture (flaws, integration, scalability)
- **SEC**: Security (access controls, auth, data exposure)
- **PERF**: Performance (SLA violations, degradation, resource limits)
- **DATA**: Data Integrity (loss, corruption, inconsistency)
- **BUS**: Business Impact (UX harm, logic errors, revenue)
- **OPS**: Operations (deployment, config, monitoring)

---

## Test Coverage Plan

### P0 (Critical) - Run on every commit

**Criteria**: Core functionality + High risk (≥6) + Blocks user experience

| Requirement (Story) | Test Level | Risk Link | Test Count | Owner | Notes |
|---------------------|------------|-----------|------------|-------|-------|
| **2.1** Terminal-Grid rendering | Unit | R-201 | 3 | Dev | Verify grid layout, 10-column grouping |
| **2.1** Terminal-Grid performance | Performance | R-201 | 1 | Dev | Benchmark 60 FPS with 500+ digits |
| **2.2** Position Tracker sync | Unit | R-203 | 2 | Dev | Index matches PracticeEngine state |
| **2.4** Ghost Mode opacity bounds | Unit | R-202 | 2 | Dev | Min/max opacity thresholds |

**Total P0**: 8 tests, ~4 heures

### P1 (High) - Run on PR to main

**Criteria**: Important features + Medium risk (3-4) + Visual feedback

| Requirement (Story) | Test Level | Risk Link | Test Count | Owner | Notes |
|---------------------|------------|-----------|------------|-------|-------|
| **2.1** Terminal-Grid bloc separation | Component | R-201 | 2 | Dev | Visual spacing between 10-digit groups |
| **2.2** Position Tracker UI update | UI | R-203 | 2 | Dev | Label updates instantly on digit entry |
| **2.3** Streak Flow activation at 10 | Unit | R-204 | 2 | Dev | Aura Cyan activates at threshold |
| **2.3** Streak Flow intensity at 20 | Unit | R-204 | 2 | Dev | Glow increases correctly |
| **2.4** Ghost Mode transition timing | Unit | R-205 | 2 | Dev | 1s transition, inactivity reset |
| **2.4** Ghost Mode visibility on pause | Manual | R-202 | 2 | QA | Keypad returns to 20% after 3s |

**Total P1**: 12 tests, ~3 heures

### P2 (Medium) - Run nightly/weekly

**Criteria**: Secondary features + Low risk + Edge cases

| Requirement (Story) | Test Level | Risk Link | Test Count | Owner | Notes |
|---------------------|------------|-----------|------------|-------|-------|
| **2.1** Terminal-Grid empty state | Unit | - | 1 | Dev | No crash on 0 digits |
| **2.3** Streak Flow disabled state | Unit | R-206 | 2 | Dev | No aura at streak < 10 |
| **2.4** Ghost Mode edge cases | Unit | R-206 | 2 | Dev | Streak reset behavior |
| General accessibility | Manual | - | 1 | QA | VoiceOver support |

**Total P2**: 6 tests, ~1 heure

---

## Execution Order

### Smoke Tests (<5 min)

**Purpose**: Fast feedback, catch build-breaking issues

- [ ] Terminal-Grid renders without crash (30s)
- [ ] Position Tracker displays correctly (30s)
- [ ] Streak Flow visual elements load (1min)

**Total**: 3 scenarios

### P0 Tests (<10 min)

**Purpose**: Critical path validation

- [ ] Terminal-Grid 10-column layout (Unit)
- [ ] Terminal-Grid performance benchmark (Performance)
- [ ] Position Tracker sync with engine (Unit)
- [ ] Ghost Mode opacity bounds (Unit)

**Total**: 8 scenarios

### P1 Tests (<30 min)

**Purpose**: Important feature coverage

- [ ] Streak Flow thresholds (10/20) (Unit)
- [ ] Ghost Mode transitions (Unit)
- [ ] Position Tracker UI updates (UI)
- [ ] Manual visual verification (QA)

**Total**: 12 scenarios

### P2/P3 Tests (<60 min)

**Purpose**: Full regression coverage

- [ ] Edge cases and accessibility
- [ ] Empty states and resets

**Total**: 6 scenarios

---

## Resource Estimates

### Test Development Effort

| Priority | Count | Hours/Test | Total Hours | Notes |
|----------|-------|------------|-------------|-------|
| P0 | 8 | 0.5 | 4 | Core rendering and sync logic |
| P1 | 12 | 0.25 | 3 | Visual feedback and transitions |
| P2 | 6 | 0.17 | 1 | Edge cases |
| **Total** | **26** | - | **8 heures** | **~1 jour** |

### Prerequisites

**Test Data:**
- MockDigitsProvider fixture (existing from Epic 1)
- StreakState factory for testing thresholds

**Tooling:**
- XCTest for unit and performance tests
- XCUITest for UI validation tests
- Instruments (GPU profiler) for 60 FPS verification

**Environment:**
- iOS Simulator (iPhone 15 Pro)
- Physical device for performance validation (optional)

---

## Quality Gate Criteria

### Pass/Fail Thresholds

- **P0 pass rate**: 100% (no exceptions)
- **P1 pass rate**: ≥95% (waivers required for failures)
- **P2 pass rate**: ≥90% (informational)
- **High-risk mitigations**: 100% complete

### Coverage Targets

- **Critical paths (Terminal-Grid, Position Tracker)**: ≥90%
- **Animation logic (Streak Flow, Ghost Mode)**: ≥80%
- **Edge cases**: ≥50%

### Non-Negotiable Requirements

- [ ] All P0 tests pass
- [ ] No high-risk (≥6) items unmitigated
- [ ] 60 FPS maintained with 500+ digits in Terminal-Grid
- [ ] Ghost Mode minimum opacity ≥ 5%

---

## Mitigation Plans

### R-201: Chute de FPS lors du rendu Terminal-Grid (Score: 6)

**Mitigation Strategy:** 
- Utiliser `.drawingGroup()` pour le rendu GPU accéléré
- Implémenter lazy loading pour les groupes de 10 hors écran
- Profiler avec Instruments (Core Animation) pour valider 60 FPS

**Owner:** Dev
**Timeline:** Story 2.1
**Status:** Planned
**Verification:** Test de performance XCTest avec 500+ digits, mesure FPS

### R-202: Ghost Mode opacité trop faible (Score: 6)

**Mitigation Strategy:**
- Définir un seuil minimum d'opacité à 5% (jamais invisible)
- Tests manuels avec utilisateurs pour valider l'utilisabilité
- Retour à 20% après 3s d'inactivité

**Owner:** Dev
**Timeline:** Story 2.4
**Status:** Planned
**Verification:** Tests unitaires sur les valeurs d'opacité, test manuel QA

---

## Assumptions and Dependencies

### Assumptions

1. Le `PracticeEngine` et `HapticService` (Epic 1) sont complètement implémentés et testés
2. L'architecture SwiftUI `@Observable` est en place pour les bindings réactifs
3. Les devices cibles supportent Metal pour le rendu GPU accéléré

### Dependencies

1. **PracticeEngine.currentIndex** - Requis pour Position Tracker (Story 2.2)
2. **PracticeEngine.streakCount** - Requis pour Streak Flow et Ghost Mode (Stories 2.3, 2.4)
3. **Design System (Cyan color, SF Mono)** - Requis pour Terminal-Grid (Story 2.1)

### Risks to Plan

- **Risk**: Epic 1 pas complètement stable
  - **Impact**: Retards sur les tests d'intégration Epic 2
  - **Contingency**: Mock complet du PracticeEngine si nécessaire

---

## Specific Test Cases

### Story 2.1: Terminal-Grid Tests

```swift
// TerminalGridTests.swift
func testGridLayout_DisplaysDigitsIn10Columns() { ... }
func testGridLayout_SeparatesGroupsVisually() { ... }
func testGridLayout_HandlesEmptyState() { ... }
func testGridPerformance_60FPSWith500Digits() { ... }
```

### Story 2.2: Position Tracker Tests

```swift
// PositionTrackerTests.swift
func testPositionTracker_DisplaysCorrectIndex() { ... }
func testPositionTracker_UpdatesOnDigitEntry() { ... }
```

### Story 2.3: Streak Flow Tests

```swift
// StreakFlowTests.swift
func testStreakFlow_ActivatesAt10Successes() { ... }
func testStreakFlow_IncreasesIntensityAt20() { ... }
func testStreakFlow_NoAnimationBelow10() { ... }
```

### Story 2.4: Ghost Mode Tests

```swift
// GhostModeTests.swift
func testGhostMode_OpacityDecreasesWithStreak() { ... }
func testGhostMode_MinimumOpacityIs5Percent() { ... }
func testGhostMode_ReturnsTo20PercentAfterInactivity() { ... }
func testGhostMode_TransitionDurationIs1Second() { ... }
```

---

## Follow-on Workflows (Manual)

- Run `*atdd` to generate failing P0 tests (separate workflow; not auto-run).
- Run `*automate` for broader coverage once implementation exists.

---

## Approval

**Test Design Approved By:**

- [ ] Product Manager: ________________ Date: ____________
- [ ] Tech Lead: ________________ Date: ____________
- [ ] QA Lead: ________________ Date: ____________

**Comments:**

---

## Appendix

### Knowledge Base References

- `risk-governance.md` - Risk classification framework
- `probability-impact.md` - Risk scoring methodology
- `test-levels-framework.md` - Test level selection
- `test-priorities-matrix.md` - P0-P3 prioritization

### Related Documents

- PRD: [prd.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/prd.md)
- Epic: [epics.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md)
- Architecture: [architecture.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md)
- Test Design Epic 1: [test-design-epic-1.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/test-design-epic-1.md)

---

**Generated by**: BMad TEA Agent - Test Architect Module
**Workflow**: `_bmad/bmm/testarch/test-design`
**Version**: 4.0 (BMad v6)
