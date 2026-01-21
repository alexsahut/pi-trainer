import Foundation

enum PRType: String, Codable, CaseIterable, CustomStringConvertible {
    case crown     // Distance (Marathon)
    case lightning // Speed (Sprint)
    
    var description: String {
        switch self {
        case .crown: return String(localized: "rules.crown.title")
        case .lightning: return String(localized: "rules.lightning.title")
        }
    }
}

struct PersonalBestRecord: Codable, Equatable {
    let constant: Constant
    let type: PRType
    let digitCount: Int
    let totalTime: TimeInterval
    let cumulativeTimes: [TimeInterval]
    let date: Date
    
    var digitsPerMinute: Double {
        guard totalTime > 0 else { return 0 }
        return Double(digitCount) / (totalTime / 60.0)
    }
    
    init(constant: Constant, type: PRType = .crown, digitCount: Int, totalTime: TimeInterval, cumulativeTimes: [TimeInterval], date: Date = Date()) {
        self.constant = constant
        self.type = type
        self.digitCount = digitCount
        self.totalTime = totalTime
        self.cumulativeTimes = cumulativeTimes
        self.date = date
    }
}
