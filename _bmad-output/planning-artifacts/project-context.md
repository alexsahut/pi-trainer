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

### ⚠️ Mandatory Development Principles

> [!CAUTION]
> **These principles are MANDATORY. Violations will block PR approval.**

#### 1. Root Cause Investigation (CRITICAL)

**Rule:** EVERY problem MUST be investigated until the root cause is understood.

**Process:**
1. **Identify the Problem:** What is the observable symptom?
2. **Ask "Why?" 5 Times:** Dig deeper until you reach the fundamental cause
3. **Document the Root Cause:** Write it down in retrospective or project-context.md
4. **Create Prevention Plan:** How do we ensure this never happens again?
5. **Implement Prevention:** Update guidelines, add tests, create scripts

**Examples:**
- ❌ **WRONG:** "Bundle resources don't load → Use FallbackData" (shortcut)
- ✅ **CORRECT:** "Bundle resources don't load → Why? → Xcode 16 uses PBXFileSystemSynchronizedRootGroup → Document mechanism → Create verification script"

**No Shortcuts Allowed:**
- Workarounds must be justified and tracked as technical debt
- "It works now" is NOT acceptable without understanding why
- Recurring problems indicate failed root cause investigation

#### 2. UX/UI Compliance (CRITICAL)

**Rule:** ALL UX/UI decisions MUST comply with [ux-design-specification.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/_bmad-output/planning-artifacts/ux-design-specification.md).

**Zen-Athlete Principles:**
- **Écran Épuré:** No visible buttons/menus during performance
- **Hidden Gestures:** Long press, swipes for non-critical actions
- **Immersion:** Nothing distracts from decimal input

**Validation Process:**
1. **Before Implementation:** Review UX spec for guidance
2. **During Implementation:** Verify compliance with principles
3. **Before PR:** Check against UX spec checklist
4. **Any Deviation:** MUST be validated with product owner

**Validated Solutions (Epic 3):**
- ✅ **Options Button (⚙️):** Validated by product owner as primary exit mechanism
  - Rationale: Accessibility, discoverability, reliability
  - Long press 3s was tested and abandoned (gesture conflicts)
- ⚠️ **Lesson:** Test gesture interactions early, validate with PO before implementation

#### 3. Documentation Requirements

**Rule:** Every problem solved = lesson documented.

**What to Document:**
- Root cause of the problem
- Why it happened
- How it was fixed
- How to prevent recurrence
- Update project-context.md or retrospective

**Where to Document:**
- `project-context.md`: Permanent guidelines and patterns
- `epic-X-retrospective.md`: Lessons learned during epic
- Code comments: Complex logic or non-obvious solutions



### 🔒 Bundle Resources: Xcode 16 File System Synchronized Groups

> [!IMPORTANT]
> **This project uses Xcode 16's `PBXFileSystemSynchronizedRootGroup`.**
> ALL files in the `PiTrainer/` folder are automatically included in the bundle.

#### How It Works (Xcode 16 Mechanism)

**Automatic Synchronization:**
```xml
<!-- In project.pbxproj -->
<PBXFileSystemSynchronizedRootGroup>
    path = PiTrainer;
    sourceTree = "<group>";
</PBXFileSystemSynchronizedRootGroup>
```

When Xcode sees this:
1. **Scans the entire `PiTrainer/` directory** at build time
2. **Automatically includes ALL files** (.swift, .txt, .json, images, etc.)
3. **No manual "Add Files to Target" required** for files in synced folders
4. **PBXResourcesBuildPhase remains empty** (resources managed automatically)

**Why This is Better:**
- ✅ No need to manually add each resource file
- ✅ New files are automatically detected
- ✅ Simpler project file (no PBXFileReference clutter)
- ✅ Fewer merge conflicts in `project.pbxproj`

#### Verification

**Check if your project uses this mechanism:**
```bash
grep "PBXFileSystemSynchronizedRootGroup" PiTrainer/PiTrainer.xcodeproj/project.pbxproj
# Expected: Should find at least one match
```

**Verify resources are in bundle:**
```bash
./verify_bundle_resources.sh --test
# Runs AssetIntegrityTests to confirm bundle inclusion
```

#### Adding New Resources

**For files INSIDE `PiTrainer/` folder:**
1. Simply create the file in the filesystem
2. No Xcode action required
3. File is automatically included in next build

**For files OUTSIDE synced folders:**
1. Open Xcode
2. Right-click target folder → "Add Files to PiTrainer..."
3. ✅ Check "Copy items if needed"
4. ✅ Check "Add to targets: PiTrainer"

#### Defense in Depth: FallbackData

Even with automatic synchronization, ALWAYS use FallbackData:

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

**Why FallbackData is still needed:**
- Test bundle configuration issues
- Corrupted resource files
- File system permissions
- Defense in depth

#### Common Misconceptions

**❌ WRONG:** "PBXResourcesBuildPhase is empty, so resources aren't bundled"
**✅ CORRECT:** Xcode 16 uses `PBXFileSystemSynchronizedRootGroup` instead

**❌ WRONG:** "I need to manually add .txt files in Xcode"
**✅ CORRECT:** Files in synced folders are automatically included

**❌ WRONG:** "AI agents can't add resources because they can't modify project.pbxproj"
**✅ CORRECT:** With Xcode 16, just creating the file is enough (if in synced folder)

#### Troubleshooting

**If resources are missing from bundle:**
1. Verify file is in `PiTrainer/PiTrainer/` (synced folder)
2. Check file exists in filesystem
3. Run `./verify_bundle_resources.sh --test`
4. Clean build folder (Cmd+Shift+K in Xcode)
5. Rebuild project

**If using older Xcode (<16):**
- Project may use legacy `PBXFileReference` + `PBXResourcesBuildPhase`
- Manual "Add Files to Target" required
- See [XCODE16_DISCOVERY.md](file:///Users/alexandre/Dev/antigravity/pi-trainer/XCODE16_DISCOVERY.md) for migration guide




## Technology Stack
- **UI**: SwiftUI (GPU Accelerated via `.drawingGroup()`)
- **Engine**: Swift (Core Engine uses `FileDigitsProvider`)
- **Haptics**: Core Haptics via `HapticService`
- **Minimum iOS**: 18.0
