
import Foundation
import Combine

/// Manages the learning segment (Story 8.1)
@MainActor
public class SegmentStore: ObservableObject {
    public static let shared = SegmentStore()
    
    private let userDefaults: UserDefaults
    private let startKey = "learnSegmentStart"
    private let endKey = "learnSegmentEnd"
    
    @Published public var segmentStart: Int {
        didSet {
            // Enforce granularity of 10
            let aligned = (segmentStart / 10) * 10
            if segmentStart != aligned { segmentStart = aligned }
            userDefaults.set(segmentStart, forKey: startKey)
        }
    }
    
    @Published public var segmentEnd: Int {
        didSet {
            // Enforce granularity of 10
            let aligned = (segmentEnd / 10) * 10
            if segmentEnd != aligned { segmentEnd = aligned }
            userDefaults.set(segmentEnd, forKey: endKey)
        }
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Load persisted values or use defaults (0-50 as per Story 8.1 AC3)
        self.segmentStart = userDefaults.object(forKey: startKey) != nil ? userDefaults.integer(forKey: startKey) : 0
        self.segmentEnd = userDefaults.object(forKey: endKey) != nil ? userDefaults.integer(forKey: endKey) : 50
    }
    
    public func reset() {
        segmentStart = 0
        segmentEnd = 50
    }
    
    deinit {
        print("DEBUG: SegmentStore deinit start")
    }
}
