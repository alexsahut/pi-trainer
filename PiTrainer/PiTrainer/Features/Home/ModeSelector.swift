//
//  ModeSelector.swift
//  PiTrainer
//
//  Created by Story 7.1 Implementation
//

import SwiftUI

/// A specialized segmented control for selecting the session mode
struct ModeSelector: View {
    @Binding var selectedMode: SessionMode
    @State private var showingGameAlert = false
    
    var body: some View {
        ZenSegmentedControl(
            title: "MODE",
            options: SessionMode.allCases,
            selection: Binding(
                get: { selectedMode },
                set: { newValue in
                    selectedMode = newValue
                }
            )
        )
        .accessibilityIdentifier("home.mode_selector")
    }
}

#Preview {
    @Previewable @State var mode: SessionMode = .learn
    
    ZStack {
        DesignSystem.Colors.blackOLED.ignoresSafeArea()
        
        ModeSelector(selectedMode: $mode)
            .padding()
    }
}
