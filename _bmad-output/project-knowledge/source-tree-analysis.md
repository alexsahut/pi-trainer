# Source Tree Analysis - pi-trainer

## Project Structure Overview

The `pi-trainer` project is a standalone SwiftUI application for iOS, following a feature-sliced architecture (Hybrid MVVM). The codebase is organized into core services, persistent storage, and feature-specific modules.

### Root Directory
- `README.md`: Project landing page (minimal).
- `DEVLOG.md`: Detailed history of development milestones and fixes.
- `project-context.md`: Critical rules and context for AI agents (V2 development).
- `AGENTS.md`: Agent-specific documentation and instructions.
- `PiTrainer/`: Main source directory.

### PiTrainer/ (iOS Application Root)
```text
PiTrainer/
├── PiTrainer/                 # Main Source Code
│   ├── App/                   # App Entry Point & Lifecycle
│   ├── Core/                  # Shared Business Logic & Services
│   │   ├── Engine/            # Validation & Ghost Logic (PracticeEngine, GhostEngine)
│   │   ├── Haptics/           # Sensory Feedback (HapticService)
│   │   └── Persistence/       # Data Access Layer (StatsStore, PersonalBestStore)
│   ├── Features/              # UI & Feature Logic
│   │   ├── Home/              # Main landing & Mode selection
│   │   └── Practice/          # Active session UI (SessionView, TerminalGridView)
│   ├── Shared/                # Reusable UI components & Utilities
│   ├── Constants/             # Mathematical constant data
│   ├── Assets.xcassets/       # Visual resources & Design System colors
│   └── Localizable.xcstrings/ # String catalogs (21+ languages)
├── PiTrainerTests/            # Unit Tests
└── PiTrainer.xcodeproj/       # Xcode Project Configuration
```

## Critical Folders & Files

| Path | Purpose | Key Files |
| :--- | :--- | :--- |
| `PiTrainer/App/` | Application bootstrapping. | `PiTrainerApp.swift` |
| `PiTrainer/Core/Engine/` | Core logic for practice and ghost competition. | `PracticeEngine.swift`, `GhostEngine.swift` |
| `PiTrainer/Core/Persistence/` | Management of stats, PB, and history. | `StatsStore.swift`, `PersonalBestStore.swift` |
| `PiTrainer/Features/Practice/` | The heart of the app: digits input and visualization. | `SessionView.swift`, `TerminalGridView.swift` |
| `PiTrainer/Constants/` | Raw digit data and metadata for Pi, e, etc. | `Constant.swift`, `digits.txt` |
| `PiTrainer/Localizable.xcstrings` | Multilingual support and pluralization rules. | |

## Entry Points
1. **Application**: `PiTrainerApp.swift` initializes the `StatsStore` and sets up the root `HomeView`.
2. **Session**: `SessionViewModel.swift` manages the lifecycle of a practice session, orchestrating the `PracticeEngine` and `GhostEngine`.

## Data Flow
- **Input**: User taps on `ProPadView` -> `SessionViewModel.processInput()` -> `PracticeEngine.input()`.
- **Validation**: `PracticeEngine` compares input against `DigitsProvider`.
- **Persistence**: `StatsStore` saves results to `UserDefaults` (records) and `JSON` (history).
- **Feedback**: `HapticService` provides sensory response; `TerminalGridView` updates visual state.
