# Source Tree Analysis

## Directory Structure

```
pi-trainer/
├── PiTrainer/               # Main Xcode project folder
│   ├── PiTrainer/           # Source code
│   │   ├── Constants/       # Digit data files (.txt)
│   │   ├── Assets.xcassets  # UI Assets & App Icon
│   │   ├── Localizable.xcstrings # String Catalog (21+ languages)
│   │   ├── PiTrainerApp.swift  # App Entry Point
│   │   ├── ContentView.swift    # Root View
│   │   ├── HomeView.swift       # Dashboard
│   │   ├── SessionView.swift    # Practice Mode
│   │   ├── StatsView.swift      # Statistics & History
│   │   ├── LearningHomeView.swift # Learning Dashboard
│   │   ├── LearningSessionView.swift # Learning Mode
│   │   ├── PracticeEngine.swift  # Core Logic
│   │   ├── DigitsProvider.swift  # Digit Loading Logic
│   │   ├── StatsStore.swift      # Persistence Layer (UserDefaults)
│   │   └── ...
│   ├── PiTrainerTests/      # Unit Tests
│   └── PiTrainerUITests/    # UI Tests
├── generate_constants.py    # Script to generate digit files
└── generate_icon.swift      # Script to generate App Icon
```

## Key Components

- **Entry Point:** `PiTrainerApp.swift`
- **Core Logic:** `PracticeEngine.swift` (State machine for digit entry)
- **Data Provider:** `DigitsProvider.swift` (Loads digits from text files)
- **Persistence:** `StatsStore.swift` (Manages user stats and settings)
- **UI:** SwiftUI based, using MVVM pattern via ViewModels.
