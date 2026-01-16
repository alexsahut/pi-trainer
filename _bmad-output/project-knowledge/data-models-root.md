# Data Models - root

## Core Models

### `Constant` (Enum)
Represents the mathematical constants supported by the app.
- **Cases:** `pi`, `e`, `sqrt2`, `phi`
- **Properties:**
  - `symbol`: The mathematical symbol (π, e, √2, φ)
  - `integerPart`: The integer part of the constant.
  - `resourceName`: Filename of the digit resource.

### `SessionRecord` (Struct)
Detailed record of a practice session, persisted via `StatsStore`.
- **Properties:**
  - `id`: Unique identifier (UUID).
  - `date`: Timestamp of the session.
  - `constant`: The `Constant` practiced.
  - `mode`: practice mode (`strict` or `learning`).
  - `attempts`: Total digits entered.
  - `errors`: Total errors made.
  - `bestStreakInSession`: Highest streak during the session.
  - `durationSeconds`: Total time spent.
  - `digitsPerMinute`: Calculated speed.

### `ConstantStats` (Struct)
Summarized stats and history for a specific constant.
- **Properties:**
  - `bestStreak`: Lifetime best streak.
  - `lastSession`: Most recent `SessionRecord`.
  - `sessionHistory`: List of recent `SessionRecord` (FIFO, max 200).

## Persistence

Statistics are managed by `StatsStore` and persisted using **UserDefaults** under the key `com.alexandre.pitrainer.stats`. Data is encoded/decoded using `JSONEncoder`/`JSONDecoder`.
