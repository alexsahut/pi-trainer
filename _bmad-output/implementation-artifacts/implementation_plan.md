# Implementation Plan - Story 11.2: Système d'XP "Zero-Code" & Grades

This story introduces a "Zero-Code" XP system based on the total number of correct digits typed by the user, and a dynamic Grade system.

## User Review Required

> [!IMPORTANT]
> **StatsStore Refactoring:** `StatsStore` will be moved to `Core/Persistence/` and converted to a **Singleton** (`shared` instance). This is a structural change. `HomeView` and other views currently instantiating `StatsStore()` will need to be updated to use `StatsStore.shared` or inject the singleton.

## Proposed Changes

### Core Infrastructure

#### [MODIFY] [StatsStore.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/StatsStore.swift) (Move to `Core/Persistence/StatsStore.swift`)
-   **Move file** to `PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift`.
-   **Singleton:** Add `static let shared = StatsStore()`.
-   **XP Tracking:**
    -   Add `@Published var totalCorrectDigits: Int` (XP).
    -   Load `totalCorrectDigits` from `UserDefaults` (key: `stats.totalCorrectDigits`) in `loadStats()`.
    -   Update `addSessionRecord()` to increment `totalCorrectDigits` by `(record.attempts - record.errors)` and save to `UserDefaults`.
    -   Add `recalculateTotalXP()` method to scan all history and rebuild `totalCorrectDigits` (used in `repairStatsFromHistory()` or explicitly).

### Shared Models

#### [NEW] [Grade.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Shared/Models/Grade.swift)
-   Create `enum Grade` with cases: `.novice`, `.apprentice`, `.athlete`, `.expert`, `.grandmaster`.
-   Implement `static func from(xp: Int) -> Grade`.
-   Properties: `displayName`, `iconName`, `color`, `range`.

#### [MODIFY] [Views and ViewModels] (Refactor to use Singleton)
-   **HomeView.swift**: Replace `@StateObject` with `StatsStore.shared`.
-   **StatsView.swift**: Remove `init(statsStore:)`, use `StatsStore.shared`.
-   **SessionView.swift**: Remove `statsStore` injection, use `StatsStore.shared`.
-   **RecordDashboardView.swift**: Remove `statsStore` injection, use `StatsStore.shared`.
-   **SettingsView.swift**: Remove `statsStore` injection, use `StatsStore.shared`.
-   **SessionSettingsView.swift**: Remove `statsStore` injection, use `StatsStore.shared`.
-   **SessionViewModel.swift**: Update `syncSettings` signature to remove store parameter or default to shared.

### Features / UI

#### [NEW] [GradeBadge.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/Features/Home/Components/GradeBadge.swift)
-   Create a SwiftUI view displaying the current grade icon with a glow effect.
-   Use `DesignSystem` colors (Cyan/OLED Black).

#### [MODIFY] [HomeView.swift](file:///Users/alexandre/Dev/antigravity/pi-trainer/PiTrainer/PiTrainer/HomeView.swift)
-   **Refactoring:** Ensure `StatsStore.shared` is used as the source of truth.
-   **UI:** Add `GradeBadge` to the UI (at the top/header).
-   **Progress:** Display XP progress if space permits.

## Verification Plan

### Automated Tests
-   **StatsStoreTests:**
    -   Verify `totalCorrectDigits` defaults to 0.
    -   Verify `addSessionRecord` properly increments XP.
    -   Verify persistence (save/load matches).
    -   Verify singleton behavior.
-   **GradeTests:**
    -   Verify `Grade.from(xp)` returns correct grade for boundary values (boundary values 0, 999, 1000, 4999, etc.).

### Manual Verification
1.  **Launch App:** Verify no crash due to Singleton refactor.
2.  **Check Initial State:** Verify XP is displayed (likely 0 or migrated).
3.  **Complete Session:** Finish a session with correct digits.
4.  **Verify Update:** Check that XP increased by the correct amount.
5.  **Verify Persistence:** Kill and restart app, verify XP persists.
6.  **Verify Grade Change:** (Dev utility or long session) artificially boost XP to cross a threshold (e.g. 1000) and verify Badge update.
