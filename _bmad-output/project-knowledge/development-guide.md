# Development Guide - pi-trainer

## Prerequisites
- **Xcode**: 16.0 or later.
- **iOS**: Target deployment 18.0.
- **Hardware**: iPhone 16 range (recommended for Core Haptics testing).

## Environment Setup
1. Clone the repository.
2. Open `PiTrainer.xcodeproj` in Xcode.
3. Ensure the active scheme is set to `PiTrainer`.
4. (Optional) Check `project-context.md` for specific rules related to the `v2-development` branch.

## Build and Run
- **Standard Run**: Cmd + R in Xcode to run on a simulator or connected physical device.
- **Production Archive**: Product -> Archive in Xcode.

## Testing
The project uses a comprehensive test suite (XCTest) to ensure mathematical validity and UI stability.

### Unit Tests
- **Target**: `PiTrainerTests`
- **Cmd**: Cmd + U in Xcode.
- **Areas Covered**:
  - `PracticeEngine`: Core validation logic.
  - `DigitsProvider`: File loading and fallback.
  - `StatsStore`: Persistence and migration logic.
  - `SessionViewModel`: State management and flow.
  - `GhostEngine`: Interpolation and progress tracking.

### UI Tests
- **Target**: `PiTrainerUITests`
- **Purpose**: Regression testing for critical UI flows (Home, Practice, Settings).

## Project Rules (V2)
- **File Location**: All new source files MUST be placed inside `PiTrainer/PiTrainer/` to ensure proper synchronization.
- **Deployment Target**: Do not bump the target beyond iOS 18.0 without explicit confirmation.
- **Safety**: Prefer value types (`struct`, `enum`) over classes to avoid complex memory management issues in concurrent environments.

## Deployment & Operations
- No external CI/CD pipeline is currently configured.
- Deployment is manual via TestFlight/Xcode.
- **Resources**: Resource integrity is verified via `check_bundle_resources.sh` before release.
