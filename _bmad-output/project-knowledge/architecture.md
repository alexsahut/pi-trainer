# Architecture Documentation - pi-trainer

## 1. Architectural Overview

The `pi-trainer` application is built using a modern **SwiftUI** architecture, evolving towards a **Feature-Sliced Hybrid MVVM** pattern. It prioritizes low-latency user interaction and robust mathematical validation.

### Design Principles
- **Performance First**: Core validation logic is designed for <16ms latency to ensure fluid typing at high speeds.
- **Sensory Immersion**: Core Haptics and dynamic visual feedback (Ghost Mode, Atmospheric colors) are integrated deeply into the user experience.
- **Safety & Stability**: Use of value-based state management (Observable structs) to avoid reference-related regressions.

## 2. Core Components

### PracticeEngine
The central logic engine for digit validation.
- **State**: Tracks the current index, streaks, errors, and session time.
- **Validation**: Performs direct comparison against preloaded digit data.
- **Mode Aware**: Supports Learn (segment-based), Practice (zen), Game (ghost), and Strict modes.

### SessionViewModel
The main orchestrator for a practice session.
- **Reactive State**: Uses `@Published` and `@Observable` to drive the UI.
- **Flow Control**: Manages the lifecycle of a session (Start, Input, End, Save).
- **Service Integration**: Communicates with `PracticeEngine`, `GhostEngine`, and `StatsStore`.

### GhostEngine
A specialized engine for replaying personal best performances.
- **Interpolation**: Calculates the "ghost's position" in real-time based on cumulative timestamps from previous best sessions.
- **Async Monitoring**: Runs a background task to check for victory/defeat transitions.

## 3. Persistence Strategy

The project uses a **Hybrid Persistence** model:
1. **UserDefaults (`PracticePersistence`)**: Used for high-frequency, low-volume data like current settings, personal best scores, and streak metadata.
2. **File System (`SessionStore` / JSON)**: Used for high-volume data like historical session records (limit: 200 items) and cumulative timestamps for ghost replays.
3. **Asynchronous Saving**: All persistent operations are performed off the main thread to prevent UI hitches during session completion.

## 4. Design System

The app utilizes a custom **Design System** (`DesignSystem.swift`) rather than standard iOS components to maintain a "Dark & Sharp" athlete-focused aesthetic.
- **Colors**: OLED-perfect blacks, Cyan Electric for success, Orange Electric for ghost lead.
- **Typography**: SF Mono for all digit displays to ensure perfect grid alignment.
- **Components**: Custom `KeypadView`, `TerminalGridView`, and `ZenPrimaryButton`.

## 5. Implementation Patterns

- **Observation**: Leverages the Swift 5.10+ `@Observable` macro for high-performance UI updates.
- **Swift Concurrency**: Uses `Task` and `MainActor` for managing asynchronous operations (ghost monitoring, persistence).
- **Protocol-Oriented**: Dependency injection is used for persistence and data providers to facilitate unit testing.
