//
//  QuickWorkoutsApp.swift
//  QuickWorkoutsWatch WatchKit Extension
//
//  Created by Tsonev Ivaylo on 26.02.21.
//

import SwiftUI
//import QuickWorkoutsList

@main
struct QuickWorkoutsApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
