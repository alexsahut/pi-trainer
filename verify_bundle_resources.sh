#!/bin/bash
# Verify Bundle Resources Configuration
# This script ensures .txt files are properly configured in Xcode project

set -e

echo "🔍 Verifying Bundle Resource Configuration..."
echo ""

PBXPROJ="PiTrainer/PiTrainer.xcodeproj/project.pbxproj"
REQUIRED_FILES=("pi_digits.txt" "e_digits.txt" "phi_digits.txt" "sqrt2_digits.txt")
ERRORS=0

# Check 1: Files exist in filesystem
echo "📁 Step 1: Checking filesystem..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "PiTrainer/PiTrainer/Constants/$file" ]; then
        echo "  ✅ $file exists"
    else
        echo "  ❌ $file MISSING from filesystem"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# Check 2: Files are referenced in project.pbxproj
echo "📋 Step 2: Checking project.pbxproj references..."
for file in "${REQUIRED_FILES[@]}"; do
    if grep -q "$file" "$PBXPROJ"; then
        echo "  ✅ $file referenced in project"
    else
        echo "  ❌ $file NOT in project.pbxproj"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# Check 3: Files are in PBXResourcesBuildPhase
echo "🔧 Step 3: Checking PBXResourcesBuildPhase..."
RESOURCE_COUNT=$(grep -A 20 "PBXResourcesBuildPhase" "$PBXPROJ" | grep -E "(pi_digits|e_digits|phi_digits|sqrt2_digits)" | wc -l | tr -d ' ')

if [ "$RESOURCE_COUNT" -ge 4 ]; then
    echo "  ✅ All files in Copy Bundle Resources ($RESOURCE_COUNT references found)"
else
    echo "  ❌ Only $RESOURCE_COUNT/4 files in Copy Bundle Resources"
    echo "  📝 Action: Open Xcode → Target → Build Phases → Copy Bundle Resources"
    echo "             Manually add missing .txt files"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 4: Run AssetIntegrityTests (if requested)
if [ "${1:-}" = "--test" ]; then
    echo "🧪 Step 4: Running AssetIntegrityTests..."
    xcodebuild test \
        -project PiTrainer/PiTrainer.xcodeproj \
        -scheme PiTrainer \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 17' \
        -only-testing:PiTrainerTests/AssetIntegrityTests \
        2>&1 | grep -E "(Test Case|passed|failed)" | tail -3
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "  ✅ AssetIntegrityTests PASSED"
    else
        echo "  ❌ AssetIntegrityTests FAILED"
        ERRORS=$((ERRORS + 1))
    fi
    echo ""
fi

# Summary
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Bundle resources properly configured."
    exit 0
else
    echo "❌ $ERRORS error(s) found. Bundle resources NOT properly configured."
    echo ""
    echo "📝 Remediation Steps:"
    echo "1. Open PiTrainer.xcodeproj in Xcode"
    echo "2. Select PiTrainer target → Build Phases tab"
    echo "3. Expand 'Copy Bundle Resources'"
    echo "4. Click '+' and add missing .txt files from Constants folder"
    echo "5. Ensure 'Copy items if needed' is checked"
    echo "6. Commit the updated project.pbxproj"
    exit 1
fi
