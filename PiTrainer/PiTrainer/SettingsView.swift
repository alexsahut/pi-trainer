
import SwiftUI

struct SettingsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @ObservedObject var statsStore: StatsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.blackOLED.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("RÉGLAGES")
                        .font(DesignSystem.Fonts.monospaced(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    VStack(spacing: 32) {
                        ZenSegmentedControl(
                            title: "MODE DE PRATIQUE",
                            options: [PracticeEngine.Mode.strict, PracticeEngine.Mode.learning],
                            selection: $sessionViewModel.selectedMode
                        )
                        
                        ZenSegmentedControl(
                            title: "DISPOSITION CLAVIER",
                            options: KeypadLayout.allCases,
                            selection: $statsStore.keypadLayout
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    ZenPrimaryButton(title: "OK") {
                        dismiss()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
