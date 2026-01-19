#!/bin/bash

# Configuration
OUTPUT_DIR="_bmad-output/release/screenshots"
mkdir -p "$OUTPUT_DIR"

echo "📸  Pi Trainer Screenshot Assistant"
echo "==================================="
echo "This script will help you capture the 5 required App Store screenshots."
echo "Images will be saved to: $OUTPUT_DIR"
echo ""
echo "⚠️  Ensure your Simulator (iPhone 17) is OPEN and VISIBLE."
echo ""

# Function to capture
capture() {
    NAME=$1
    echo "👉  ACTION: Navigate to **$2** on the Simulator."
    read -p "    Press ENTER when ready..."
    
    FILENAME="$OUTPUT_DIR/$NAME.png"
    xcrun simctl io booted screenshot "$FILENAME"
    
    if [ $? -eq 0 ]; then
        # Resize to App Store accepted 6.7" display (1284 x 2778)
        # Using iPhone 13/14 Pro Max resolution which is universally accepted.
        sips -z 2778 1284 "$FILENAME" > /dev/null 2>&1
        echo "✅  Captured & Resized: $FILENAME"
    else
        echo "❌  Failed to capture. Is the simulator running?"
    fi
    echo "-----------------------------------"
}

# 1. Home Screen
capture "01_Home" "Home Screen (Show Practice Mode selectable)"

# 2. Learn Mode
capture "02_Learn" "Learn Mode (Select 'Learn' mode + Drag slider to show segment)"

# 3. Practice Flow
capture "03_Practice" "Practice Mode (Type a few digits to show the flow/streak)"

# 4. Statistics
capture "04_Stats" "Statistics Page (Tap the Chart/Bars icon)"

# 5. Settings
capture "05_Constants" "Settings/Home (Show different constants or Stats Context)"

echo ""
echo "🎉  All screenshots captured!"
echo "    Check folder: $OUTPUT_DIR"
open "$OUTPUT_DIR"
