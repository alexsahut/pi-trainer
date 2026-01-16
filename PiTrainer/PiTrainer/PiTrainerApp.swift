//
//  PiTrainerApp.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import SwiftUI

@main
struct PiTrainerApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationCoordinator.path) {
                HomeView()
                    .environment(navigationCoordinator)
            }
            .background(DesignSystem.Colors.blackOLED.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }
}
