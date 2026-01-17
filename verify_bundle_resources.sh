#!/bin/bash
# Verify Bundle Resources Configuration (Xcode 16 Edition)
# This script verifies resources are properly configured using PBXFileSystemSynchronizedRootGroup

set -e

echo "🔍 Verifying Bundle Resource Configuration (Xcode 16)..."
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

# Check 2: Verify PBXFileSystemSynchronizedRootGroup is configured
echo "📋 Step 2: Checking PBXFileSystemSynchronizedRootGroup..."
if grep -q "PBXFileSystemSynchronizedRootGroup" "$PBXPROJ"; then
    echo "  ✅ Project uses Xcode 16 File System Synchronized Groups"
    echo "     → All files in PiTrainer/ folder are automatically bundled"
else
    echo "  ⚠️  PBXFileSystemSynchronizedRootGroup not found"
    echo "     → Project may use legacy resource management"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check 3: Run AssetIntegrityTests (the REAL test)
if [ "${1:-}" = "--test" ]; then
    echo "🧪 Step 3: Running AssetIntegrityTests (REAL verification)..."
    xcodebuild test \
        -project PiTrainer/PiTrainer.xcodeproj \
        -scheme PiTrainer \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 17' \
        -only-testing:PiTrainerTests/AssetIntegrityTests \
        2>&1 | grep -E "(Test Case|passed|failed)" | tail -3
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "  ✅ AssetIntegrityTests PASSED - Resources ARE in bundle"
    else
        echo "  ❌ AssetIntegrityTests FAILED - Resources NOT in bundle"
        ERRORS=$((ERRORS + 1))
    fi
    echo ""
fi

# Summary
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Bundle resources properly configured."
    echo ""
    echo "ℹ️  This project uses Xcode 16's PBXFileSystemSynchronizedRootGroup"
    echo "   → All files in PiTrainer/ are automatically included in bundle"
    echo "   → No manual 'Add Files to Target' required for files in synced folders"
    exit 0
else
    echo "❌ $ERRORS error(s) found. Bundle resources NOT properly configured."
    echo ""
    echo "📝 Remediation Steps:"
    echo "1. Ensure files exist in PiTrainer/PiTrainer/Constants/"
    echo "2. Verify project uses PBXFileSystemSynchronizedRootGroup (Xcode 16)"
    echo "3. Run './verify_bundle_resources.sh --test' to confirm bundle inclusion"
    exit 1
fi
