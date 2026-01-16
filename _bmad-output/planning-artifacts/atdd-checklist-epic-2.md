# ATDD Checklist: Epic 2 - Ghost Terminal & Visualisation

**Date:** 2026-01-16
**Author:** Alex
**Story IDs:** 2.1, 2.2, 2.3, 2.4
**Status:** RED Phase ✅ (All tests failing)

---

## Acceptance Criteria Breakdown

### Story 2.1: Terminal-Grid
| AC | Description | Test Level | Test Count |
|----|-------------|------------|------------|
| AC-2.1.1 | Digits display in grid of 10 columns max | Unit | 2 |
| AC-2.1.2 | Groups of 10 separated by spacing | Unit | 2 |
| AC-2.1.3 | Uses .drawingGroup() for 60 FPS | Performance | 2 |

### Story 2.2: Position Tracker
| AC | Description | Test Level | Test Count |
|----|-------------|------------|------------|
| AC-2.2.1 | Displays index of next expected decimal | Unit | 1 |
| AC-2.2.2 | Increments instantly on correct validation | Unit | 3 |
| AC-2.2.3 | Handles reset on session restart | Unit | 2 |

### Story 2.3: Streak Flow
| AC | Description | Test Level | Test Count |
|----|-------------|------------|------------|
| AC-2.3.1 | Cyan aura activates at 10 successes | Unit | 2 |
| AC-2.3.2 | Glow intensifies at 20 successes | Unit | 2 |
| AC-2.3.3 | No framerate drops (<16ms) | Performance | 2 |

### Story 2.4: Ghost Mode
| AC | Description | Test Level | Test Count |
|----|-------------|------------|------------|
| AC-2.4.1 | Opacity decreases at streak > 20 | Unit | 3 |
| AC-2.4.2 | Minimum opacity is 5% | Unit | 2 |
| AC-2.4.3 | Returns to 20% after 3s inactivity | Unit | 2 |
| AC-2.4.4 | Transition duration ~1 second | Unit | 2 |
| AC-2.4.5 | Smooth easeInOut animation | Unit | 1 |

---

## Test Files Created

| File | Tests | Status |
|------|-------|--------|
| `TerminalGridTests.swift` | 6 | ❌ RED |
| `PositionTrackerTests.swift` | 6 | ❌ RED |
| `StreakFlowTests.swift` | 6 | ❌ RED |
| `GhostModeTests.swift` | 10 | ❌ RED |
| **Total** | **28** | **❌ RED** |

---

## Required ViewModels (To Implement)

### TerminalGridViewModel
```swift
class TerminalGridViewModel: ObservableObject {
    var groups: [[Int]] { get }
    var columnCount: Int { get }
    var rowCount: Int { get }
    var isEmpty: Bool { get }
}
```

### PositionTrackerViewModel
```swift
class PositionTrackerViewModel: ObservableObject {
    var displayIndex: Int { get } // currentIndex + 1
    var formattedDisplay: String { get } // "#156"
}
```

### StreakFlowViewModel
```swift
class StreakFlowViewModel: ObservableObject {
    var isAuraActive: Bool { get }
    var level: StreakLevel { get } // .none, .level1, .level2
    var auraColor: Color { get }
    var glowIntensity: Double { get }
    
    static func isActive(forStreak: Int) -> Bool
}
```

### GhostModeViewModel
```swift
class GhostModeViewModel: ObservableObject {
    var isActive: Bool { get }
    var currentOpacity: Double { get }
    var targetOpacity: Double { get }
    var minimumOpacity: Double { 0.05 }
    var transitionDuration: TimeInterval { 1.0 }
    
    static func calculateOpacity(forStreak: Int) -> Double
    func simulateInactivity(seconds: TimeInterval)
}
```

---

## Implementation Checklist

### Story 2.1: Terminal-Grid
- [ ] Create `TerminalGridViewModel.swift` in `Features/Practice/`
- [ ] Implement digit grouping logic (chunks of 10)
- [ ] Handle empty state
- [ ] Handle partial groups at end
- [ ] Create `TerminalGridView.swift` with `.drawingGroup()`
- [ ] Run tests: 6/6 passing ✅

### Story 2.2: Position Tracker
- [ ] Create `PositionTrackerViewModel.swift`
- [ ] Bind to `PracticeEngine.currentIndex`
- [ ] Implement display formatting (#N)
- [ ] Create `PositionTrackerView.swift`
- [ ] Run tests: 6/6 passing ✅

### Story 2.3: Streak Flow
- [ ] Create `StreakFlowViewModel.swift`
- [ ] Implement threshold logic (10, 20)
- [ ] Define `StreakLevel` enum
- [ ] Create glow animation with Metal/`.drawingGroup()`
- [ ] Create `StreakFlowView.swift`
- [ ] Run tests: 6/6 passing ✅

### Story 2.4: Ghost Mode
- [ ] Create `GhostModeViewModel.swift`
- [ ] Implement opacity calculation formula
- [ ] Implement inactivity timer (3s reset)
- [ ] Use `.animation(.easeInOut(duration: 1.0))`
- [ ] Integrate with ProPadView opacity binding
- [ ] Run tests: 10/10 passing ✅

---

## Red-Green-Refactor Workflow

### ❌ RED Phase (Complete)
- ✅ All 28 tests written and failing
- ✅ Tests define expected behavior
- ✅ Failures due to missing ViewModels

### 🟢 GREEN Phase (DEV Team)
1. Pick one failing test
2. Implement minimal code to pass
3. Run test to verify green
4. Repeat until all tests pass

### 🔄 REFACTOR Phase (DEV Team)
1. All tests passing
2. Extract duplications
3. Optimize performance
4. Ensure tests still pass

---

## Running Tests

```bash
# Run all Epic 2 failing tests
xcodebuild test -project PiTrainer/PiTrainer.xcodeproj \
  -scheme PiTrainer \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:PiTrainerTests/TerminalGridTests \
  -only-testing:PiTrainerTests/PositionTrackerTests \
  -only-testing:PiTrainerTests/StreakFlowTests \
  -only-testing:PiTrainerTests/GhostModeTests

# Run specific test file
xcodebuild test ... -only-testing:PiTrainerTests/TerminalGridTests

# Run in Xcode
# ⌘+U to run all tests
# Click test diamond next to specific test
```

---

## Quality Gate

- [ ] All 28 tests passing (GREEN)
- [ ] No performance regressions (60 FPS maintained)
- [ ] Code coverage ≥80% for new ViewModels
- [ ] No XCTFail() calls remaining in test files

---

**Generated by**: BMad TEA Agent - ATDD Workflow
**Workflow**: `_bmad/bmm/testarch/atdd`
**Version**: 4.0 (BMad v6)
