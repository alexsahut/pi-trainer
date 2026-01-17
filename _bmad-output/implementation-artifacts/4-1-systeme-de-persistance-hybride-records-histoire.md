# Story 4.1: Système de Persistance Hybride (Records & Histoire)

**Epic:** 4 - Records, Statistiques & Persistance  
**Story ID:** 4.1  
**Status:** done  
**Created:** 2026-01-16  

---

## User Story

**As a** athlète de la mémoire,  
**I want** que mes records soient accessibles instantanément et mes sessions sauvegardées sur le long terme,  
**So that** ne jamais perdre mon progrès.

---

## Acceptance Criteria

**Given** une fin de session  
**When** le score est enregistré  
**Then** les Records Personnels (PB) sont stockés dans `UserDefaults`  
**And** l'historique complet est sauvegardé dans des fichiers JSON de manière asynchrone via `Core/Persistence`  
**And** l'enregistrement n'impacte pas la fluidité de l'interface de fin de session.

---

## Context from Epic

### Epic 4 Objectives
**Epic 4: Records, Statistiques & Persistance** vise à sauvegarder les performances, afficher les records personnels (Personal Best) et l'historique détaillé.

**FRs Covered by Epic 4:**
- FR7: Historique des 200 dernières performances (Story 4.3)
- FR10: Record personnel (PB) par constante (Story 4.2)
- FR13: Persistance locale complète (Story 4.1 - **THIS STORY**)

### Related Stories in Epic 4
- **Story 4.2:** Dashboard des Records Personnels (PB) - Affichage UI
- **Story 4.3:** Historique Détaillé des Performances - Visualisation 200 sessions

---

## Developer Context & Implementation Guide

### 🎯 CRITICAL MISSION
This story is the **foundation** of Epic 4. You are implementing the persistence layer that Stories 4.2 and 4.3 will consume. **DO NOT** implement the UI for displaying records or history - that comes in Stories 4.2 and 4.3.

### 📁 Existing Code Analysis

#### Current State: `StatsStore.swift`
**Location:** `/PiTrainer/PiTrainer/StatsStore.swift`

**What Already Exists:**
```swift
class StatsStore: ObservableObject {
    @Published private(set) var stats: [Constant: ConstantStats] = [:]
    
    // ALREADY IMPLEMENTED:
    // - UserDefaults persistence for stats (JSON encoded)
    // - 200-session history limit (maxHistoryCount = 200)
    // - Per-constant statistics (ConstantStats)
    // - SessionRecord struct with all required fields
    // - Migration from legacy keys
    
    // KEY METHODS:
    // - addSessionRecord(_ record: SessionRecord) // Adds to history, updates PB
    // - updateBestStreakIfNeeded(_ streak: Int, for constant: Constant)
    // - history(for constant: Constant) -> [SessionRecord]
    // - bestStreak(for constant: Constant) -> Int
}
```

**What This Story Adds:**
1. **Async File Persistence** for session history (currently in UserDefaults)
2. **Separation of Concerns:** UserDefaults for PB only, JSON files for history
3. **Background Thread Operations** to prevent UI blocking

#### Current Persistence Structure
```swift
// Core/Persistence/PracticePersistence.swift (38 bytes - minimal)
// This file exists but is minimal - you will extend it

// StatsStore.swift uses:
private let statsKey = "com.alexandre.pitrainer.stats"
private func persistStats() {
    if let encoded = try? JSONEncoder().encode(stats) {
        userDefaults.set(encoded, forKey: statsKey)
    }
}
```

---

## Architecture Requirements

### From `architecture.md`

#### Hybrid Persistence Strategy (Lines 55-58)
```markdown
- **UserDefaults:** Stockage atomique pour les records critiques (Best Streak, Progress Index) 
  afin de garantir un accès instantané (<1ms) au démarrage.
- **Custom File Storage (JSON/CSV):** Déportation de l'historique massif des sessions sur le disque. 
  Lecture et écriture asynchrones pour ne jamais impacter le thread de pratique.
```

#### Project Structure (Lines 100-113)
```
PiTrainer/
├── Core/
│   ├── Engine/
│   ├── Haptics/
│   └── Persistence/      # ← YOUR WORK HERE
├── Features/
│   ├── Practice/
│   ├── Home/
│   └── Stats/            # ← Will consume your persistence layer
```

#### Architectural Boundaries (Lines 116-119)
- **Isolation Core:** Les services de `Core/` sont agnostiques de l'UI
- **Data Access:** **Seul `Core/Persistence` a le droit de manipuler le disque**
- **Feature Encapsulation:** ViewModels utilisent le service Persistence

---

## Technical Requirements

### 1. File Structure Requirements

**CRITICAL:** All files MUST be placed in `PiTrainer/PiTrainer/Core/Persistence/`

**Files to Create/Modify:**
```
Core/Persistence/
├── PracticePersistence.swift     # Extend (currently 38 bytes)
├── SessionHistoryStore.swift     # NEW - Async file operations
└── PersistenceError.swift        # NEW - Error handling
```

**DO NOT** create files outside this directory. Xcode 16 uses `PBXFileSystemSynchronizedRootGroup` - files in `PiTrainer/PiTrainer/` are automatically synced.

### 2. Data Models (Already Exist in `StatsStore.swift`)

```swift
struct SessionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let constant: Constant
    let mode: PracticeEngine.Mode
    let attempts: Int
    let errors: Int
    let bestStreakInSession: Int
    let durationSeconds: TimeInterval
    let digitsPerMinute: Double
}

struct ConstantStats: Codable, Equatable {
    var bestStreak: Int
    var lastSession: SessionRecord?
    var sessionHistory: [SessionRecord]
}
```

**DO NOT** recreate these structs. They are already defined in `StatsStore.swift`.

### 3. Persistence Strategy

#### UserDefaults (Synchronous - for PB only)
```swift
// Store ONLY critical records:
// - bestStreak per constant
// - selectedConstant
// - keypadLayout
// - lastSession metadata (optional)

// Key format: "com.alexandre.pitrainer.{key}"
```

#### JSON File Storage (Asynchronous - for history)
```swift
// File location: Application Support directory
// File naming: "session_history_{constant}.json"
// Example: "session_history_pi.json", "session_history_e.json"

// Operations:
// - Write: Background thread, non-blocking
// - Read: Background thread with completion handler
// - Limit: 200 sessions per constant (FIFO)
```

### 4. Threading Requirements

**From `architecture.md` (Line 33):**
> Threading dédié (User Interactive priority) pour la validation afin de ne jamais bloquer le Main Thread.

**For Persistence:**
- **Write Operations:** Use `DispatchQueue.global(qos: .utility)` for file writes
- **Read Operations:** Use `DispatchQueue.global(qos: .userInitiated)` for file reads
- **UI Updates:** Always dispatch back to `DispatchQueue.main`

### 5. Error Handling

```swift
enum PersistenceError: Error {
    case fileNotFound
    case encodingFailed
    case decodingFailed
    case writePermissionDenied
}
```

---

## Implementation Tasks

### Task 1: Create `SessionHistoryStore.swift`
**Subtask 1.1:** Define `SessionHistoryStore` class with `@Observable` macro  
**Subtask 1.2:** Implement async `saveHistory(_ records: [SessionRecord], for constant: Constant)`  
**Subtask 1.3:** Implement async `loadHistory(for constant: Constant) -> [SessionRecord]`  
**Subtask 1.4:** Add FIFO logic to maintain 200-session limit  
**Subtask 1.5:** Handle file system errors gracefully

### Task 2: Refactor `StatsStore.swift`
**Subtask 2.1:** Remove `sessionHistory` from UserDefaults persistence  
**Subtask 2.2:** Keep only `bestStreak` and `lastSession` in UserDefaults  
**Subtask 2.3:** Inject `SessionHistoryStore` dependency  
**Subtask 2.4:** Update `addSessionRecord()` to call async file save  
**Subtask 2.5:** Update `history(for:)` to load from file asynchronously

### Task 3: Create `PersistenceError.swift`
**Subtask 3.1:** Define error enum with all cases  
**Subtask 3.2:** Add localized error descriptions

### Task 4: Update `PracticePersistence.swift`
**Subtask 4.1:** Document the persistence architecture  
**Subtask 4.2:** Add protocol for testability (if needed)

### Task 5: Write Unit Tests
**Subtask 5.1:** Test `SessionHistoryStore` async operations  
**Subtask 5.2:** Test FIFO 200-session limit  
**Subtask 5.3:** Test error handling (file not found, decode errors)  
**Subtask 5.4:** Test `StatsStore` integration with `SessionHistoryStore`

---

## Testing Requirements

### Unit Tests to Create

**File:** `PiTrainerTests/SessionHistoryStoreTests.swift`

```swift
// Test Cases:
// 1. testSaveAndLoadHistory_Success
// 2. testFIFO_200SessionLimit
// 3. testMultipleConstants_SeparateFiles
// 4. testConcurrentWrites_ThreadSafety
// 5. testFileNotFound_ReturnsEmptyArray
// 6. testCorruptedJSON_HandlesGracefully
```

**File:** `PiTrainerTests/StatsStoreTests.swift` (extend existing)

```swift
// New Test Cases:
// 1. testAddSessionRecord_UpdatesFileAsync
// 2. testBestStreak_LoadedFromUserDefaults
// 3. testHistory_LoadedFromFile
```

### Integration Test

**File:** `PiTrainerUITests/PersistenceIntegrationTests.swift`

```swift
// Test Case:
// 1. Complete session → Verify PB in UserDefaults
// 2. Complete session → Verify history file created
// 3. Restart app → Verify data persists
```

---

## Previous Story Intelligence

### From Epic 3 (Most Recent)

**Story 3.4:** Intégrité du Build & Vérification des Ressources
- **Lesson:** Always use FallbackData for critical resources
- **Pattern:** Defensive programming for file operations
- **Relevance:** Apply same defensive approach to session history files

**Story 3.3:** Mode Strict
- **Pattern:** `SessionViewModel` manages session lifecycle
- **Relevance:** Your persistence layer will be called from `SessionViewModel.endSession()`

**Story 3.1:** Sélection de la Constante
- **Pattern:** `StatsStore.selectedConstant` already exists
- **Relevance:** Use this to determine which history file to load/save

### Git History Insights (Last 10 Commits)

```
ba61175 refactor: remove non-functional long press gesture code
ce8ebc7 fix: remove duplicate long press gesture causing conflict
a01dbca docs: validate UX deviation - Options button approved
7235291 docs: CRITICAL - mandatory root cause investigation
9a54336 docs: comprehensive Xcode bundle resource mechanism
c2f2929 docs: comprehensive bundle resource prevention strategy
5fba698 fix: integrate FallbackData to prevent resource loading failures
```

**Key Patterns:**
- **Defensive Coding:** FallbackData pattern for critical resources
- **Documentation:** Root cause investigation is mandatory
- **Testing:** UI tests added after bugs discovered

**Apply to This Story:**
- Add fallback for missing history files (return empty array)
- Document why async file operations are necessary
- Write comprehensive tests BEFORE implementation

---

## UX/UI Requirements

### From `ux-design-specification.md`

**Line 232:** "Immersive Persistence: Le mode 'Zen' persiste tant que l'utilisateur n'a pas consciemment quitté la session."

**Implication for This Story:**
- Persistence operations MUST be non-blocking
- User should never see loading spinners during session end
- File writes happen in background, UI updates immediately

**Line 46:** "Zéro Latence: Persistance locale immédiate via UserDefaults/StatsStore."

**Implication:**
- PB updates via UserDefaults = instant (<1ms)
- History file writes = async, non-blocking

---

## Project Context Compliance

### From `project-context.md`

#### 1. Root Cause Investigation (Lines 22-41)
**Rule:** EVERY problem MUST be investigated until the root cause is understood.

**For This Story:**
- If file writes fail, investigate WHY (permissions, disk space, encoding)
- Document the root cause in code comments
- Create prevention plan (error handling, fallbacks)

#### 2. UX/UI Compliance (Lines 42-60)
**Validated Solution:** Options Button (⚙️) for session exit

**For This Story:**
- Persistence is triggered when user exits via Options button
- Ensure async operations don't block the exit flow

#### 3. Documentation Requirements (Lines 62-76)
**Rule:** Every problem solved = lesson documented.

**For This Story:**
- Document why hybrid strategy (UserDefaults + Files)
- Document threading choices (utility vs userInitiated)
- Add inline comments for non-obvious async patterns

---

## Definition of Done

- [ ] `SessionHistoryStore.swift` created with async file operations
- [ ] `StatsStore.swift` refactored to use `SessionHistoryStore`
- [ ] `PersistenceError.swift` created with all error cases
- [ ] Unit tests written and passing (100% coverage for new code)
- [ ] Integration test verifies end-to-end persistence
- [ ] No UI blocking during session end (verified manually)
- [ ] Code review completed
- [ ] Documentation updated (inline comments + architecture notes)

---

## Next Steps After This Story

**Story 4.2:** Dashboard des Records Personnels (PB)
- Will consume `StatsStore.bestStreak(for:)` method
- Will display PB for each constant on Home screen

**Story 4.3:** Historique Détaillé des Performances
- Will consume `SessionHistoryStore.loadHistory(for:)` method
- Will display 200 most recent sessions in Stats screen

---

## References

- [Epic 4 Definition](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/epics.md#L277-L320)
- [Architecture: Hybrid Persistence](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/architecture.md#L55-L58)
- [PRD: FR13 Persistence](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/prd.md#L142)
- [UX Spec: Immersive Persistence](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md#L232)
- [Project Context: Mandatory Guidelines](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/project-context.md)
- [Existing StatsStore](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsStore.swift)

---

**Story Created:** 2026-01-16  
**Ready for Development:** ✅  
**Estimated Complexity:** Medium (Async file operations + refactoring)
