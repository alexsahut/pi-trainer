//
//  KeypadView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct KeypadView: View {
    
    let layout: KeypadLayout
    let onDigit: (Int) -> Void
    let onBackspace: () -> Void
    let onReset: () -> Void
    let onQuit: () -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                // Digits based on layout
                ForEach(layout.digits, id: \.self) { digit in
                    KeypadButton(label: "\(digit)") {
                        onDigit(digit)
                    }
                }
                
                // Bottom row: Reset, 0, Backspace
                KeypadButton(label: String(localized: "keypad.reset", defaultValue: "RESET"), color: DesignSystem.Colors.orangeElectric.opacity(0.1), strokeColor: DesignSystem.Colors.orangeElectric.opacity(0.5)) {
                    onReset()
                }
                
                KeypadButton(label: "0") {
                    onDigit(0)
                }
                
                KeypadButton(label: "⌫", color: DesignSystem.Colors.textSecondary.opacity(0.1), strokeColor: DesignSystem.Colors.textSecondary.opacity(0.5)) {
                    onBackspace()
                }
            }
            
            // Zen Quit button
            ZenPrimaryButton(
                title: String(localized: "keypad.quit", defaultValue: "QUIT"),
                style: .secondary,
                accessibilityIdentifier: "keypad.quit_button",
                action: onQuit
            )
            .padding(.top, 8)
        }
        .padding()
    }
}

struct KeypadButton: View {
    let label: String
    var color: Color = DesignSystem.Colors.blackOLED.opacity(0.3)
    var strokeColor: Color = Color.white.opacity(0.1)
    let action: () -> Void
    
    @State private var isFlashing = false
    
    var body: some View {
        Button(action: {
            triggerFlash()
            action()
        }) {
            ZStack {
                // Background Frame
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .frame(height: 60)
                    .frame(minWidth: 44, minHeight: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(strokeColor, lineWidth: 1)
                    )
                
                // Label
                Text(label)
                    .font(DesignSystem.Fonts.monospaced(size: 28, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                // Flash Overlay (Cyan)
                if isFlashing {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DesignSystem.Colors.cyanElectric)
                        .opacity(0.6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func triggerFlash() {
        isFlashing = true
        withAnimation(.easeOut(duration: 0.1)) {
            isFlashing = false
        }
    }
}

#Preview {
    KeypadView(
        layout: .phone,
        onDigit: { _ in },
        onBackspace: { },
        onReset: { },
        onQuit: { }
    )
    .preferredColorScheme(.dark)
}
