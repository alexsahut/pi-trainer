---
project_name: 'pi-trainer'
user_name: 'Alex'
date: '2026-01-23'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'code_quality', 'workflow_rules', 'anti_patterns']
status: 'complete'
rule_count: 24
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## 🔴 DANGER ZONE: V2 MIGRATION IN PROGRESS
This workspace is dedicated to the V2 development branch (`v2-development`).
The V1 (`main`) codebase is fundamentally incompatible with the files here.

### CRITICAL RULES FOR AGENTS
1.  **NO RESET**: NEVER execute `git reset --hard` without explicit user confirmation and a backup.
2.  **NO CHECKOUT**: DO NOT checkout `main` or `master` in this directory. If V1 access is needed, request a separate worktree.
3.  **ATOMIC COMMITS**: Commit changes frequently. Do not leave the workspace in a dirty state for long periods.
4.  **TEST BEFORE COMMIT**: Run `xcodebuild test` or at least `xcodebuild build` before committing complex changes.
5.  **V2_MARKER**: The presence of the file `PiTrainer/V2_MARKER` confirms this is the protected V2 environment.

---

## Technology Stack & Versions

- **OS/SDK**: iOS 17.0+ / Swift 5.10+
- **Frameworks**: Vanilla SwiftUI, Core Haptics
- **State Management**: Swift 5.10+ `@Observable` macros
- **Persistence**: Hybrid (UserDefaults for settings/records, Custom JSON for session history)
- **UI Engine**: GPU-accelerated rendering (`.drawingGroup()`) for dense terminal grids

## Critical Implementation Rules

### Language-Specific Rules (Swift)

- **Naming**: PascalCase for types (`DigitsProvider`), camelCase for variables/properties (`currentStreak`).
- **Suffixes**: MANDATORY: `[Nom]View`, `[Nom]ViewModel`, `[Nom]Service`, `[Nom]Manager`.
- **Injection**: Systematic Dependency Injection via initializer for testability.
- **Performance**: High-speed input (10+ Hz) must use direct callbacks or light notifications; avoid heavy `@Published` streams.
- **Concurrency**: Engine validation logic must use high-priority threads (User Interactive) to ensure sub-16ms latency.

### Framework-Specific Rules (SwiftUI)

- **State Management**: Exclusive use of `@Observable`. Avoid `ObservableObject` in new code.
- **GPU Rendering**: Systematically use `.drawingGroup()` for performance-critical views (e.g., `TerminalGrid`).
- **Haptics**: Always use the "pre-warmed" `HapticService` to eliminate latency.
- **Navigation**: Use `.interactiveDismissDisabled(true)` during active sessions to protect user records.

### Testing Rules

- **RGR Cycle**: Follow Red-Green-Refactor for all core logic changes.
- **Performance Benchmarks**: Use `measure` in XCTest to ensure critical validation paths remain sub-1ms.
- **Isolation**: Services must be injectable or protocol-based to allow for robust mocking in unit tests.
- **Strategy**: Prioritize unit tests for `PracticeEngine` and logic; use UI tests sparingly for critical user flows only.

### Code Quality & Style Rules

- **Feature-Sliced Architecture**: Organize code by business domain in `/Features` (e.g., `Practice/`, `Home/`). 
- **Core Separation**: Keep performance-critical infrastructure in `/Core`.
- **Latency Control**: Zero high-frequency logging (`print`) in render loops; use `os_log` for mandatory debugging.
- **Design System**: Use predefined constants in `/Shared/UI` for all colors and typography; no hard-coded style values.

### Development Workflow Rules (V2 Environment)

- **Environment Integrity**: Never execute destructive git operations (`reset`, `checkout main`) without backup.
- **Continuous Validation**: Systematic build or unit test verification before any commit.
- **Task Granularity**: Commit on each completed task/subtask to maintain a clean history.
- **Authority**: The active Story File is the single source of truth for implementation sequence and requirements.

## Critical Don't-Miss Rules

- **Zero Tolerance for Jitter**: Any code path adding >2ms to the main thread during practice is forbidden.
- **Haptic Pre-warming**: Forgetting to pre-warm `Core Haptics` results in high user-perceived input lag.
- **State Isolation**: Never let `PracticeEngine` state leak directly into other features without passing through `StatsStore`.

---

## Usage Guidelines

**For AI Agents:**

- Read this file before implementing any code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Update this file if new patterns emerge

**For Humans:**

- Keep this file lean and focused on agent needs
- Update when technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

Last Updated: 2026-01-23
