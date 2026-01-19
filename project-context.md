# Context of Project: V2 Development

## 🔴 DANGER ZONE: V2 MIGRATION IN PROGRESS
This workspace is dedicated to the V2 development branch (`v2-development`).
The V1 (`main`) codebase is fundamentally incompatible with the files here.

### CRITICAL RULES FOR AGENTS
1.  **NO RESET**: NEVER execute `git reset --hard` without explicit user confirmation and a backup.
2.  **NO CHECKOUT**: DO NOT checkout `main` or `master` in this directory. If V1 access is needed, request a separate worktree.
3.  **ATOMIC COMMITS**: Commit changes frequently. Do not leave the workspace in a dirty state for long periods.
4.  **TEST BEFORE COMMIT**: Run `xcodebuild test` or at least `xcodebuild build` before committing complex changes.
5.  **V2_MARKER**: The presence of the file `PiTrainer/V2_MARKER` confirms this is the protected V2 environment.

## Project Structure
-   **Core**: `PiTrainer/PiTrainer`
-   **Tests**: `PiTrainer/PiTrainerTests`
-   **Target**: `PiTrainer` (iOS 16+)
-   **Architecture**: MVVM + Coordinators (being introduced).
-   **Persistence**: `PracticePersistence` (UserDefaults) + `SessionStore` (File System).

## Key Components V2
-   `PracticeEngine`: Core logic for digit validation.
-   `SessionViewModel`: Manages UI state for sessions.
-   `SegmentStore`: Manages "learn mode" segments.
-   `StatsStore`: Central source of truth for statistics.
