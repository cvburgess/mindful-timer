//
//  Mindful_TimerApp.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

@main
struct Mindful_TimerApp: App {
  @StateObject private var backgroundTimer = BackgroundTimer()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(backgroundTimer)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
          // App will go to background - timer will continue via date calculations
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
          // App came back from background - resume timer updates
          backgroundTimer.resumeFromBackground()
        }
    }
  }
}
