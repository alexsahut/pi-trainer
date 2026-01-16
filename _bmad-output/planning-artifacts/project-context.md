# Project Context: PiTrainer

## Critical Development Rules

### 📁 Project Structure & Xcode 16 Sync
> [!IMPORTANT]
> This project uses **Xcode 16 Synchronized Groups**.
> **ALL new source files (.swift)** must be placed inside the `PiTrainer/PiTrainer/` directory.
> Sibling directories like `PiTrainer/Core` or `PiTrainer/Features` are NOT automatically synced and will lead to build failures or missing links.

### 🏗️ Architecture
- **Features**: Located in `PiTrainer/PiTrainer/Features/` (e.g., `Practice/`)
- **Core**: Located in `PiTrainer/PiTrainer/Core/` (e.g., `Haptics/`, `Engine/`)
- **Observable**: Use the `@Observable` macro for ViewModels and Engines.
- **Value Types**: Prefer `struct` for logic (e.g., `PracticeEngine`) to ensure memory stability.

### 🧪 Quality Gates
1. **Build**: Run `xcodebuild build` for the `PiTrainer` scheme before completing any story.
2. **Regression**: Run the UI test `RegressionTests.testFirstDigitVisibility` if any changes affect the `SessionView` or `TerminalGridView`.
3. **Tests**: All unit tests must pass. Use `xcodebuild test`.

## Technology Stack
- **UI**: SwiftUI (GPU Accelerated via `.drawingGroup()`)
- **Engine**: Swift (Core Engine uses `FileDigitsProvider`)
- **Haptics**: Core Haptics via `HapticService`
- **Minimum iOS**: 18.0
