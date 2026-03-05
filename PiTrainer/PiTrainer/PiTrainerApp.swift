//
//  PiTrainerApp.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import SwiftUI
import UserNotifications

@main
struct PiTrainerApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }

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
