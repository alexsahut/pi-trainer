# Data Models - pi-trainer

The project utilizes a hybrid persistence approach, combining `UserDefaults` for lightweight metadata and the file system (JSON) for voluminous historical data.

## 1. Core Enumerations

### `Constant`
Defines the mathematical constants supported by the app.
- **Cases**: `pi`, `e`, `phi`.
- **Properties**: `id`, `symbol`, `resourceName` (for digit files), `integerPart`.

### `SessionMode`
Defines the operational rules for a practice session.
- **Cases**: `learn`, `practice`, `game`, `test` (Strict).
- **Behavior Flags**: `allowsReveal`, `hasGhost`, `showsPermanentOverlay`.

## 2. Persistence Models

### `PersonalBestRecord` (JSON)
Stored in `Application Support/PersonalBests/`.
- `constant`: The targeted constant.
- `type`: `.crown` (Distance) or `.lightning` (Speed).
- `digitCount`: Maximum digits reached.
- `totalTime`: Time taken to reach the score.
- `cumulativeTimes`: Array of `TimeInterval` representing the exact timestamp of every digit entered (critical for Ghost replay).

### `SessionRecord` (JSON)
Stored in `Application Support/session_history_{id}.json`.
- `id`: Unique session identifier.
- `date`: Completion timestamp.
- `score`: Number of correct digits.
- `errors`: Total errors committed.
- `durationSeconds`: Total active time.
- `digitsPerMinute`: Average speed.
- `revealsUsed`: Count of "reveal" assistance triggered.
- `wasVictory`: Boolean flag for Game Mode outcomes.

### `ConstantStats` (UserDefaults JSON)
Summary metrics per constant.
- `bestStreak`: Longest error-free run.
- `totalCorrectDigits`: Aggregate sum of all successful inputs (XP).
- `lastSessionDate`: Timestamp of most recent activity.

## 3. Metadata & Preferences

### Streak Data (UserDefaults)
- `zen_athlete_daily_streak`: Current consecutive day count.
- `zen_athlete_last_practice_date`: Last recorded activity timestamp.

### Preferences (UserDefaults)
- `selectedConstant`: Preferred starting constant.
- `selectedMode`: Preferred starting mode.
- `keypadLayout`: User preference for `.phone` vs `.calculator` layout.
- `autoAdvance`: Boolean for "Indulgent Mode" settings.
