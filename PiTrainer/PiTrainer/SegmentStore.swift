
import Foundation
import Combine

/// Manages the learning segment (Story 8.1)
@MainActor
public class SegmentStore: ObservableObject {
    public static let shared = SegmentStore()
    
    @Published public var segmentStart: Int {
        didSet {
            // Enforce granularity of 10
            let aligned = (segmentStart / 10) * 10
            if segmentStart != aligned { segmentStart = aligned }
        }
    }
    
    @Published public var segmentEnd: Int {
        didSet {
            // Enforce granularity of 10
            let aligned = (segmentEnd / 10) * 10
            if segmentEnd != aligned { segmentEnd = aligned }
        }
    }
    
    public init() {
        self.segmentStart = 0
        self.segmentEnd = 50
    }
    
    public func reset() {
        segmentStart = 0
        segmentEnd = 50
    }
}
