import SwiftUI

struct GameModeRulesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.blackOLED
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title Section
                        headerSection
                        
                        // Rules Sections
                        VStack(spacing: 24) {
                            RuleCard(
                                icon: "crown.fill",
                                iconColor: .yellow,
                                title: String(localized: "rules.crown.title"),
                                description: String(localized: "rules.crown.desc")
                            )
                            
                            RuleCard(
                                icon: "bolt.fill",
                                iconColor: .orange,
                                title: String(localized: "rules.lightning.title"),
                                description: String(localized: "rules.lightning.desc")
                            )
                            
                            RuleCard(
                                icon: "checkmark.shield.fill",
                                iconColor: DesignSystem.Colors.cyanElectric,
                                title: String(localized: "rules.certification.title"),
                                description: String(localized: "rules.certification.desc")
                            )
                            
                            RuleCard(
                                icon: "checkmark.seal.fill",
                                iconColor: .green,
                                title: String(localized: "legend.victory.title"),
                                description: String(localized: "legend.victory.desc")
                            )
                            
                            RuleCard(
                                icon: "xmark.seal.fill",
                                iconColor: .orange,
                                title: String(localized: "legend.defeat.title"),
                                description: String(localized: "legend.defeat.desc")
                            )
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Close Button
                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: "common.close").uppercased())
                                .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DesignSystem.Colors.cyanElectric)
                                .cornerRadius(12)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(24)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "legend.title").uppercased())
                .font(DesignSystem.Fonts.monospaced(size: 24, weight: .black))
                .foregroundColor(DesignSystem.Colors.cyanElectric)
                .tracking(2)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(DesignSystem.Colors.cyanElectric.opacity(0.3))
        }
    }
}

struct RuleCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(DesignSystem.Fonts.monospaced(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(minHeight: 110)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    GameModeRulesView()
}
