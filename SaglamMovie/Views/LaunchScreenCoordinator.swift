import SwiftUI

class LaunchScreenCoordinator: ObservableObject {
    @Published var showLaunchScreen: Bool = true
    
    init() {
        // Dismiss the launch screen after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showLaunchScreen = false
            }
        }
    }
} 