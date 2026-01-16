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

### 🔒 Bundle Resources: Understanding Xcode's Mechanism

> [!CAUTION]
> **Non-Swift files (.txt, .json, images) require manual Xcode configuration.**
> They will NOT be included in the app bundle unless added via Xcode UI.

#### How Xcode Bundles Resources (Technical Explanation)

When you add a file via **Xcode UI** (File → Add Files to "PiTrainer"...):

1. **PBXFileReference** is created → File metadata (path, type)
2. **PBXBuildFile** is created → Links file to a build phase
3. **PBXResourcesBuildPhase.files** array is updated → File ID added
4. → At build time, file is **copied to app bundle**

When a file is created **programmatically** (script/AI):
- ❌ None of these steps happen
- ❌ `PBXResourcesBuildPhase` remains empty
- ❌ File exists in filesystem but **NOT in bundle**
- ❌ `bundle.url(forResource:)` returns `nil`

**Verification:**
```bash
# Check if files are in Copy Bundle Resources
grep -A 20 "PBXResourcesBuildPhase" PiTrainer/PiTrainer.xcodeproj/project.pbxproj | grep "pi_digits.txt"
# Expected: Should find at least one match
```

#### Correct Process for Adding Resources

**Step-by-Step (MUST be done in Xcode):**

1. Open `PiTrainer.xcodeproj` in Xcode
2. Right-click on `PiTrainer` folder in Project Navigator
3. Select "Add Files to 'PiTrainer'..."
4. Navigate to `PiTrainer/Constants/`
5. Select ALL `.txt` files (pi_digits, e_digits, phi_digits, sqrt2_digits)
6. ✅ **CHECK:** "Copy items if needed"
7. ✅ **CHECK:** "Add to targets: PiTrainer"
8. Click "Add"

**Verify in Xcode:**
1. Select `PiTrainer` target
2. Go to "Build Phases" tab
3. Expand "Copy Bundle Resources"
4. Confirm all 4 `.txt` files are listed

**Commit the changes:**
```bash
git add PiTrainer/PiTrainer.xcodeproj/project.pbxproj
git commit -m "fix: add resource files to Copy Bundle Resources build phase"
```

#### Automated Verification

**Before every commit, run:**
```bash
./verify_bundle_resources.sh
```

This script checks:
- ✅ Files exist in filesystem
- ✅ Files referenced in `project.pbxproj`
- ✅ Files in `PBXResourcesBuildPhase`
- ✅ `AssetIntegrityTests` pass (with `--test` flag)

**If verification fails:**
- Follow the "Correct Process" above
- Commit the updated `project.pbxproj`

#### Defense in Depth: FallbackData

Even with proper configuration, ALWAYS use FallbackData as a safety net:

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
print("⚠️ Using FallbackData (bundle resource missing)")
```

#### Why This Problem Occurs

**Root Cause:**
- AI agents create files programmatically
- Cannot safely modify `project.pbxproj` (complex, undocumented format)
- Manual Xcode step required

**Why it worked before (maybe):**
- FallbackData was always used
- Bundle resources never actually loaded
- App worked, but used embedded data

#### Long-Term Solutions

- [ ] Add Xcode Build Phase script to verify resources
- [ ] Create pre-commit git hook running `verify_bundle_resources.sh`
- [ ] Consider SwiftGen or R.swift for type-safe resource management
- [ ] Investigate `xcodeproj` Ruby gem for programmatic project modification



## Technology Stack
- **UI**: SwiftUI (GPU Accelerated via `.drawingGroup()`)
- **Engine**: Swift (Core Engine uses `FileDigitsProvider`)
- **Haptics**: Core Haptics via `HapticService`
- **Minimum iOS**: 18.0
