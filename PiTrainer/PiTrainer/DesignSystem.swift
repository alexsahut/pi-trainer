import SwiftUI

enum DesignSystem {
    enum Colors {
        static let blackOLED = Color("blackOLED")
        static let cyanElectric = Color(red: 0.0, green: 0.95, blue: 1.0) // #00F2FF
    }
    
    enum Fonts {
        static func monospaced(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            return Font.system(size: size, weight: weight, design: .monospaced)
        }
    }
}
