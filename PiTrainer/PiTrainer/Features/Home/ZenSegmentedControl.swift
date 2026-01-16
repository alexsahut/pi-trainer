
import SwiftUI

struct ZenSegmentedControl<T: Hashable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
            
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    }) {
                        Text(option.description)
                            .font(DesignSystem.Fonts.monospaced(size: 16, weight: .bold))
                            .foregroundColor(selection == option ? DesignSystem.Colors.blackOLED : DesignSystem.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                selection == option ? DesignSystem.Colors.cyanElectric : Color.clear
                            )
                    }
                    .overlay(
                        Rectangle()
                            .stroke(DesignSystem.Colors.textSecondary.opacity(0.3), lineWidth: 0.5)
                    )
                }
            }
            .background(DesignSystem.Colors.blackOLED)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(DesignSystem.Colors.cyanElectric.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(4)
        }
    }
}
