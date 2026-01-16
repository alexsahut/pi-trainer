import SwiftUI

struct ProPadView: View {
    @State private var viewModel = ProPadViewModel()
    
    var layout: KeypadLayout = .phone
    
    // Current streak from PracticeEngine (passed from SessionView)
    var currentStreak: Int = 0
    
    // Current session state
    var isActive: Bool = true
    
    // Callbacks
    var onDigit: (Int) -> Void
    var onBackspace: () -> Void
    var onOptions: () -> Void
    
    // Grid Setup
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    private var digits: [Int] {
        switch layout {
        case .phone: return [1, 2, 3, 4, 5, 6, 7, 8, 9]
        case .pc: return [7, 8, 9, 4, 5, 6, 1, 2, 3]
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // Digits 1-9 (Ordered by Layout)
            ForEach(digits, id: \.self) { digit in
                ProPadButton(content: "\(digit)") {
                    viewModel.digitPressed(digit)
                    onDigit(digit)
                }
            }
            
            // Options (Bottom Left)
            ProPadButton(content: "⚙️", isAction: true) {
                viewModel.actionPressed(.options)
                onOptions()
            }
            
            // Digit 0
            ProPadButton(content: "0") {
                viewModel.digitPressed(0)
                onDigit(0)
            }
            
            // Backspace (Bottom Right)
            ProPadButton(content: "⌫", isAction: true) {
                viewModel.actionPressed(.backspace)
                onBackspace()
            }
        }
        .padding()
        .opacity(isActive ? viewModel.opacity : 0.3)
        .disabled(!isActive)
        .onAppear {
            viewModel.onPrepare()
        }
        .onChange(of: currentStreak) { _, newStreak in
            viewModel.updateStreak(newStreak)
        }
        .animation(.easeInOut(duration: 1.0), value: viewModel.opacity)
        // Optimization: Render as texture if complex
        // .drawingGroup() // POTENTIAL BUG CAUSE WITH LAZYVGRID
    }
}

struct ProPadButton: View {
    let content: String
    var isAction: Bool = false
    let action: () -> Void
    
    @State private var isFlashing = false
    
    var body: some View {
        Button(action: {
            triggerFlash()
            action()
        }) {
            ZStack {
                // Background Frame
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.blackOLED.opacity(0.3)) // Use DesignSystem token
                    .frame(height: 60)
                    .frame(minWidth: 44, minHeight: 44) // NFR5: Touch Target
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Label
                Text(content)
                    .font(DesignSystem.Fonts.monospaced(size: 28, weight: .bold))
                    .foregroundColor(isAction ? .gray : .white)
                
                // Flash Overlay (Cyan)
                if isFlashing {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.cyanElectric)
                        .opacity(0.6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle()) // Remove default fade to handle instant flush
    }
    
    private func triggerFlash() {
        // Immediate ON
        isFlashing = true
        
        // Fast OFF (<100ms)
        withAnimation(.easeOut(duration: 0.1)) {
            isFlashing = false
        }
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        ProPadView(
            onDigit: { print("Digit: \($0)") },
            onBackspace: { print("Backspace") },
            onOptions: { print("Options") }
        )
    }
}
