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

### 🔒 Resource Loading Pattern (CRITICAL)
> [!CAUTION]
> **ALWAYS use FallbackData for bundle resources.**
> Bundle resources (`.txt` files) may fail to load in tests or certain build configurations.

**Mandatory Pattern:**
```swift
// ✅ CORRECT: Use FallbackData as fallback
if let url = bundle.url(forResource: name, withExtension: "txt") {
    do {
        // Try to load from bundle
        self.data = try load(from: url)
        return
    } catch {
        print("⚠️ Bundle load failed: \(error). Using FallbackData.")
    }
}
// FALLBACK: Use embedded data
self.data = FallbackData.digits(for: constant)
```

**Why:** Bundle resources can fail due to:
- Xcode project file sync issues
- Test bundle configuration
- Missing file references in `.pbxproj`

**Prevention Checklist:**
- [ ] Every resource loader has a FallbackData fallback
- [ ] Error logs use emoji prefixes (✅/⚠️/❌) for visibility
- [ ] `AssetIntegrityTests` pass before closing stories


## Technology Stack
- **UI**: SwiftUI (GPU Accelerated via `.drawingGroup()`)
- **Engine**: Swift (Core Engine uses `FileDigitsProvider`)
- **Haptics**: Core Haptics via `HapticService`
- **Minimum iOS**: 18.0
