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
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                // Digits based on layout
                ForEach(layout.digits, id: \.self) { digit in
                    KeypadButton(label: "\(digit)") {
                        onDigit(digit)
                    }
                }
                
                // Bottom row: Reset, 0, Backspace
                KeypadButton(label: String(localized: "keypad.reset"), color: .orange) {
                    onReset()
                }
                
                KeypadButton(label: "0") {
                    onDigit(0)
                }
                
                KeypadButton(label: "⌫", color: .gray) {
                    onBackspace()
                }
            }
            
            // Quit button
            Button(action: onQuit) {
                Text("keypad.quit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

struct KeypadButton: View {
    let label: String
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(color)
                .cornerRadius(12)
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
