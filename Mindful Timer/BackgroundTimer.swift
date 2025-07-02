//
//  BackgroundTimer.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/24/25.
//

import Foundation
import SwiftUI

class BackgroundTimer: ObservableObject {
  @AppStorage("timerStartDate") private var timerStartDateData: Data?
  @AppStorage("timerDuration") private var timerDuration: Int = 0
  @AppStorage("isTimerRunning") private var isTimerRunning: Bool = false
  @AppStorage("isPaused") private var isPaused: Bool = false
  @AppStorage("pausedElapsed") private var pausedElapsed: Int = 0
  
  @Published var timeRemaining: Int = 0
  
  private var timer: Foundation.Timer?
  
  var startDate: Date? {
    get {
      guard let data = timerStartDateData else { return nil }
      return try? JSONDecoder().decode(Date.self, from: data)
    }
    set {
      if let date = newValue {
        timerStartDateData = try? JSONEncoder().encode(date)
      } else {
        timerStartDateData = nil
      }
    }
  }
  
  func startTimer(duration: Int) {
    timerDuration = duration
    timeRemaining = duration
    
    if !isPaused {
      startDate = Date()
      pausedElapsed = 0
    }
    
    isTimerRunning = true
    isPaused = false
    
    startUpdateTimer()
  }
  
  func pauseTimer() {
    isTimerRunning = false
    isPaused = true
    timer?.invalidate()
    timer = nil
    
    // Calculate elapsed time and store it
    if let start = startDate {
      let elapsed = Int(Date().timeIntervalSince(start))
      pausedElapsed = elapsed
    }
  }
  
  func resumeTimer() {
    if isPaused {
      startDate = Date() // Reset start date for resume
      isTimerRunning = true
      isPaused = false
      startUpdateTimer()
    }
  }
  
  func resetTimer() {
    isTimerRunning = false
    isPaused = false
    startDate = nil
    pausedElapsed = 0
    timerDuration = 0
    timeRemaining = 0
    timer?.invalidate()
    timer = nil
  }
  
  func resumeFromBackground() {
    if isTimerRunning && !isPaused {
      updateTimeRemaining()
      startUpdateTimer()
    }
  }
  
  private func startUpdateTimer() {
    timer?.invalidate()
    timer = Foundation.Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      self.updateTimeRemaining()
    }
  }
  
  private func updateTimeRemaining() {
    guard isTimerRunning, !isPaused, let start = startDate else { return }
    
    let elapsed = Int(Date().timeIntervalSince(start)) + pausedElapsed
    timeRemaining = max(0, timerDuration - elapsed)
    
    if timeRemaining <= 0 {
      // Timer has completed
      isTimerRunning = false
      timer?.invalidate()
      timer = nil
    }
  }
}