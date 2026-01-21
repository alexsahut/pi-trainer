import SwiftUI

enum DesignSystem {
    enum Colors {
        static let blackOLED = Color("blackOLED")
        static let cyanElectric = Color(red: 0.0, green: 0.95, blue: 1.0) // #00F2FF
        static let orangeElectric = Color(red: 1.0, green: 0.42, blue: 0.0) // #FF6B00
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
    }
    
    enum Fonts {
        static func monospaced(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            return Font.system(size: size, weight: weight, design: .monospaced)
        }
    }
}
