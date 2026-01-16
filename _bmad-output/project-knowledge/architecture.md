# Architecture

## Executive Summary
Pi Trainer is a native iOS application built with **SwiftUI** and **Swift**. It follows an **MVVM (Model-View-ViewModel)** architectural pattern with specialized **Service** layers for digit management and persistence.

## Technology Stack
- **Language:** Swift 5.9+
- **Framework:** SwiftUI
- **Persistence:** UserDefaults (via `StatsStore`)
- **Localization:** String Catalog (`.xcstrings`) supporting 21+ languages.
- **Testing:** XCTest (Unit and UI tests).

## Architecture Pattern: MVVM + Services

### Models
- `Constant`: Represents π, e, etc.
- `SessionRecord`: Data structure for practiced sessions.
- `ConstantStats`: Aggregated stats for a constant.

### ViewModels
- `SessionViewModel`: Manages the state of a practice session, interacting with the `PracticeEngine`.
- `LearningSessionViewModel`: Manages the spaced-repetition learning flow.

### Views (SwiftUI)
- `HomeView`: Main navigation hub.
- `SessionView`: Interactive practice screen with keypad.
- `StatsView`: Visualization of progress and history.

### Services
- `PracticeEngine`: Core business logic for validating digit entry and tracking streaks.
- `DigitsProvider`: Handles loading of large digit sequences from text resources.
- `StatsStore`: Handles persistence and migration of user statistics.

## Data Architecture
The app uses a simple but robust persistence layer based on `UserDefaults`. Large digit sequences are stored in bundled `.txt` files to keep the binary size manageable while ensuring fast access.
