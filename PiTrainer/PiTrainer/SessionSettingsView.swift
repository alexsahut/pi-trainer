
import SwiftUI

struct SessionSettingsView: View {
    @ObservedObject var viewModel: SessionViewModel
    @ObservedObject var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var hapticsEnabled = HapticService.shared.isEnabled
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.blackOLED.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Configuration Section
                        VStack(spacing: 24) {
                            // Note: Constant selection is intentionally omitted to prevent changing it mid-session.
                            

                            
                            ZenSegmentedControl(
                                title: String(localized: "DISPOSITION CLAVIER"),
                                options: KeypadLayout.allCases,
                                selection: $viewModel.keypadLayout
                            )
                            
                            if viewModel.selectedMode.hasGhost {
                                ZenSegmentedControl(
                                    title: String(localized: "session.options.ghost_selection"),
                                    options: PRType.allCases,
                                    selection: $viewModel.selectedGhostType
                                )
                            }
                            
                            
                            // Haptics Toggle
                            Toggle(isOn: $hapticsEnabled) {
                                Text(String(localized: "RETOUR HAPTIQUE"))
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
                            
                            // Story 10.1 & User Request: Mode Indulgent Toggle
                            Toggle(isOn: $viewModel.isAutoAdvanceEnabled) {
                                Text(String(localized: "MODE INDULGENT"))
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
                        }
                        
                        // Action Section
                        VStack(spacing: 16) {
                            
                            Button(action: { 
                                Task {
                                    await viewModel.endSession(shouldDismiss: true)
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text(String(localized: "QUITTER LA SESSION"))
                                }
                                .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(String(localized: "OPTIONS DE SESSION"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "FERMER")) {
                        dismiss()
                    }
                    .font(DesignSystem.Fonts.monospaced(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.cyanElectric)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
