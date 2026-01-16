#!/bin/bash
# Bundle Resource Integrity Check
# Run this before every commit or build to ensure resources are properly configured

set -e

echo "🔍 Checking bundle resource integrity..."

# Check 1: Files exist in filesystem
REQUIRED_FILES=(
    "PiTrainer/PiTrainer/Constants/pi_digits.txt"
    "PiTrainer/PiTrainer/Constants/e_digits.txt"
    "PiTrainer/PiTrainer/Constants/phi_digits.txt"
    "PiTrainer/PiTrainer/Constants/sqrt2_digits.txt"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ MISSING FILE: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo "❌ $MISSING_FILES file(s) missing from filesystem"
    exit 1
fi

echo "✅ All resource files exist in filesystem"

# Check 2: Run AssetIntegrityTests to verify bundle inclusion
echo "🧪 Running AssetIntegrityTests..."
xcodebuild test \
    -project PiTrainer/PiTrainer.xcodeproj \
    -scheme PiTrainer \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -only-testing:PiTrainerTests/AssetIntegrityTests \
    2>&1 | grep -E "(Test Case|passed|failed)" | tail -3

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ AssetIntegrityTests FAILED"
    echo "⚠️  Resources are not properly included in bundle"
    echo "📝 Action: Open Xcode and verify .txt files are added to PiTrainer target"
    exit 1
fi

echo "✅ All bundle resources properly configured"
exit 0
