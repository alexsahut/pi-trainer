
import SwiftUI

@Observable class NavigationCoordinator {
    enum Destination: Hashable {
        case session(mode: PracticeEngine.Mode)
        case stats
    }
    
    var path = NavigationPath()
    
    func push(_ destination: Destination) {
        path.append(destination)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
