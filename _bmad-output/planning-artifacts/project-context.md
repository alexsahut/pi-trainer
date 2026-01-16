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

### 🔒 Bundle Resources: CRITICAL Prevention Strategy

> [!CAUTION]
> **Non-Swift files (.txt, .json, images) are NOT auto-synced by Xcode 16.**
> They MUST be manually added to the Xcode project target.

#### Root Cause of Resource Loading Failures
1. **Files created via script/code** are not automatically detected by Xcode
2. **Xcode Synchronized Groups** only work for `.swift` files
3. **Missing from `project.pbxproj`** → Not included in app bundle → `bundle.url()` returns `nil`

#### Mandatory Process for Adding Resources

**When adding ANY non-Swift resource file:**
1. Open `PiTrainer.xcodeproj` in Xcode
2. Right-click on target folder → "Add Files to PiTrainer..."
3. Select the file(s)
4. ✅ **CHECK:** "Copy items if needed"
5. ✅ **CHECK:** "Add to targets: PiTrainer"
6. Click "Add"

#### Prevention Checklist (BEFORE every commit/PR)

Run the automated check:
```bash
./check_bundle_resources.sh
```

This script:
- ✅ Verifies files exist in filesystem
- ✅ Runs `AssetIntegrityTests` to confirm bundle inclusion
- ❌ Fails if resources are missing from bundle

#### Fallback Pattern (Defense in Depth)

Even with proper Xcode configuration, ALWAYS use FallbackData:

```swift
// ✅ CORRECT: Try bundle first, fallback to embedded data
if let url = bundle.url(forResource: name, withExtension: "txt") {
    do {
        self.data = try load(from: url)
        print("✅ Loaded from bundle")
        return
    } catch {
        print("⚠️ Bundle load failed: \(error)")
    }
}
// FALLBACK: Use embedded data
self.data = FallbackData.digits(for: constant)
print("✅ Using FallbackData")
```

#### Why This Keeps Happening
- **AI agents create files programmatically** but can't modify Xcode project files
- **Manual Xcode step required** for non-Swift resources
- **Easy to forget** when working quickly

#### Long-Term Solution (Future Epic)
- [ ] Add Xcode Build Phase to auto-verify resources
- [ ] Create pre-commit git hook running `check_bundle_resources.sh`
- [ ] Consider moving to SwiftGen for resource management


## Technology Stack
- **UI**: SwiftUI (GPU Accelerated via `.drawingGroup()`)
- **Engine**: Swift (Core Engine uses `FileDigitsProvider`)
- **Haptics**: Core Haptics via `HapticService`
- **Minimum iOS**: 18.0
