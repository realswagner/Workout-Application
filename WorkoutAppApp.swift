//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/01.
//

import SwiftUI

@main
struct WorkoutAppApp: App {
    @StateObject private var manager = HealthManager()
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(manager)
        }
    }
}
