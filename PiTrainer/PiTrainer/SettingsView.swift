
import SwiftUI

struct SettingsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @ObservedObject var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var hapticsEnabled = HapticService.shared.isEnabled
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.blackOLED.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header with Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("RETOUR")
                        }
                        .font(DesignSystem.Fonts.monospaced(size: 12, weight: .black))
                        .foregroundColor(DesignSystem.Colors.cyanElectric)
                    }
                    
                    Spacer()
                    
                    Text("RÉGLAGES")
                        .font(DesignSystem.Fonts.monospaced(size: 16, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty placeholder for symmetry
                    Color.clear.frame(width: 60, height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 32) {

                        ZenSegmentedControl(
                            title: "DISPOSITION CLAVIER",
                            options: KeypadLayout.allCases,
                            selection: $statsStore.keypadLayout
                        )
                        
                        ZenSegmentedControl(
                            title: String(localized: "session.settings.ghost_type"),
                            options: [PRType.crown, PRType.lightning],
                            selection: $statsStore.selectedGhostType
                        )
                        
                        // Notifications & Haptics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRÉFÉRENCES")
                                .font(DesignSystem.Fonts.monospaced(size: 10, weight: .black))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .tracking(2)
                            
                            Toggle(isOn: bindingForNotifications) {
                                Text("RAPPELS JOURNALIERS")
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .tint(DesignSystem.Colors.cyanElectric)
                            .padding()
                            .background(DesignSystem.Colors.blackOLED.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            
                            Toggle(isOn: $hapticsEnabled) {
                                Text("RETOUR HAPTIQUE")
                                    .font(DesignSystem.Fonts.monospaced(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .tint(DesignSystem.Colors.cyanElectric)
                            .padding()
                            .background(DesignSystem.Colors.blackOLED.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .onChange(of: hapticsEnabled) { _, newValue in
                                HapticService.shared.isEnabled = newValue
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var bindingForNotifications: Binding<Bool> {
        Binding(
            get: { NotificationService.shared.isEnabled },
            set: { newValue in
                if newValue {
                    NotificationService.shared.requestAuthorization { granted in
                        NotificationService.shared.isEnabled = granted
                    }
                } else {
                    NotificationService.shared.isEnabled = false
                }
            }
        )
    }
}
