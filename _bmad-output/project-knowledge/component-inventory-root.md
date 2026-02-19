# Component Inventory - pi-trainer

## UI Components (Features/Shared)

| Component | Category | Purpose |
| :--- | :--- | :--- |
| `ProPadView` | Input | High-performance numeric keypad with haptic feedback. |
| `TerminalGridView` | Display | Specialized grid renderer for digits using `.drawingGroup()` for GPU acceleration. |
| `HomeView` | Navigation | Main dashboard for mode selection and constant selection. |
| `SessionView` | Navigation | Active practice session container with atmospheric feedback. |
| `HorizonLineView` | Visualization | Real-time progress bar showing player vs. ghost position. |
| `ZenPrimaryButton` | Common | Reusable styled button following the project's sharp design system. |
| `ModeSelector` | Control | High-level selection for Learn/Practice/Game/Strict modes. |
| `SegmentSlider` | Control | Dual-thumb slider for selecting learning segments. |

## Core Logic Components (Core/Engine)

| Component | Purpose |
| :--- | :--- |
| `PracticeEngine` | Validates user input against mathematical constants and manages session state. |
| `GhostEngine` | Interpolates previous best performances to simulate a real-time opponent. |
| `DigitsProvider` | Protocol for serving digits from various sources (files, fallback). |

## Services & Storage (Core/Persistence)

| Component | Purpose |
| :--- | :--- |
| `StatsStore` | Central state for user statistics, records, and preferences. |
| `PersonalBestStore` | Manages persistence of high scores and detailed ghost timing data. |
| `SessionHistoryStore` | Handles asynchronous JSON-based storage of session details. |
| `HapticService` | Manages the Core Haptics engine and delivers low-latency feedback. |
| `NotificationService` | Manages local reminders and permissions. |
