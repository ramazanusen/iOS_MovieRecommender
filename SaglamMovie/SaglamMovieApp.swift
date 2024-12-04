//
//  MovieRecommenderApp.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 1.12.2024.
//

import SwiftUI

@main
struct MovieRecommenderApp: App {
    @StateObject private var launchScreenCoordinator = LaunchScreenCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                if launchScreenCoordinator.showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                }
            }
        }
    }
}
