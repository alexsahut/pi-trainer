
import SwiftUI

struct ZenPrimaryButton: View {
    let title: String
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                .foregroundColor(DesignSystem.Colors.blackOLED)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(DesignSystem.Colors.cyanElectric)
                .cornerRadius(0)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: DesignSystem.Colors.cyanElectric.opacity(0.4), radius: 10, y: 0)
        .accessibilityIdentifier(accessibilityIdentifier ?? title)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ZenPrimaryButton(title: "START SESSION") {}
            .padding()
    }
}
