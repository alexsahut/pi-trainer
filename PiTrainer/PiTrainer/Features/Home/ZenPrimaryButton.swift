
import SwiftUI

struct ZenPrimaryButton: View {
    enum Style {
        case standard
        case compact
        case secondary
        case zen
    }
    
    let title: String
    var style: Style = .standard
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Fonts.monospaced(size: fontSize, weight: .black))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(strokeColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: shadowColor, radius: shadowRadius, y: 0)
        .accessibilityIdentifier(accessibilityIdentifier ?? title)
    }
    
    // Helper Layout & Color Properties
    private var height: CGFloat {
        switch style {
        case .standard, .zen: return 80
        case .compact, .secondary: return 50
        }
    }
    
    private var fontSize: CGFloat {
        switch style {
        case .standard, .zen: return 24
        case .compact, .secondary: return 18
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard, .zen: return 20
        case .compact, .secondary: return 25
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard, .zen, .compact: return DesignSystem.Colors.cyanElectric
        case .secondary: return DesignSystem.Colors.surface
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .standard, .zen, .compact: return DesignSystem.Colors.blackOLED
        case .secondary: return DesignSystem.Colors.textPrimary
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .standard, .zen, .compact: return Color.white.opacity(0.3)
        case .secondary: return Color.white.opacity(0.1)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .standard, .zen, .compact: return DesignSystem.Colors.cyanElectric.opacity(0.4)
        case .secondary: return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .standard, .zen: return 10
        case .compact: return 5
        case .secondary: return 0
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ZenPrimaryButton(title: "START SESSION") {}
            .padding()
    }
}
