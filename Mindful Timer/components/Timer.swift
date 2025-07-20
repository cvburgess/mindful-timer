//
//  Timer.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/24/25.
//

import AVFoundation
import Combine
import SwiftUI

class TimerController: ObservableObject {
  @Published var isRunning = false
  @Published var isCompleted = false

  var startTimer: (() -> Void)?
  var pauseTimer: (() -> Void)?
  var resetTimer: (() -> Void)?

  func start() {
    startTimer?()
  }

  func pause() {
    pauseTimer?()
  }

  func reset() {
    resetTimer?()
  }
}

struct Timer: View {
  @Environment(\.colorScheme) private var colorScheme
  @EnvironmentObject private var backgroundTimer: BackgroundTimer

  let rounds: Int
  let roundLength: Int
  let breakLength: Int
  let controller: TimerController

  @AppStorage("vibrationEnabled") private var vibrationEnabled = true
  @AppStorage("roundStartSound") private var roundStartSound = "bowl"
  @AppStorage("breakStartSound") private var breakStartSound = "bell"
  @AppStorage("sessionEndSound") private var sessionEndSound = "bell"

  // Persistent state for background operation
  @AppStorage("timerCurrentRound") private var currentRound = 1
  @AppStorage("timerProgress") private var progress: Double = 0.0
  @AppStorage("timerIsBreak") private var isBreak = false
  @AppStorage("timerIsCompleted") private var isCompleted = false
  @AppStorage("timerIsRunning") private var isRunning = false
  @AppStorage("timerIsResuming") private var isResuming = false

  @State private var timeRemaining: Int = 0
  @State private var showCircle = true
  @State private var showTimerText = true
  @State private var audioPlayer: AVAudioPlayer?
  @State private var circleID = UUID()

  private var isInfiniteMode: Bool {
    rounds == 0
  }

  private var totalRounds: Int {
    isInfiniteMode ? 1 : rounds
  }

  private var currentSessionLength: Int {
    isBreak ? breakLength : roundLength
  }

  private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60

    if self.roundLength < 60 && self.breakLength < 60 {
      return "\(seconds)"
    } else {
      return String(format: "%d:%02d", minutes, remainingSeconds)
    }
  }

  private func playSound(_ soundName: String) {
    guard soundName != "none" else { return }

    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
      print("Could not find \(soundName).wav file")
      return
    }

    do {
      // Configure audio session to mix with other apps and duck their audio
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, options: [.mixWithOthers, .duckOthers])
      try audioSession.setActive(true)

      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.play()
    } catch {
      print("Error playing sound: \(error)")
    }
  }

  var body: some View {
    ZStack {
      SegmentedRadialProgressView(
        rounds: rounds,
        currentRound: currentRound,
        progress: progress,
        timeRemaining: timeRemaining,
        isCompleted: isCompleted,
        isBreak: isBreak,
        circleID: circleID
      )
      .opacity(showCircle ? 1.0 : 0.0)
      .animation(.easeOut(duration: 2.0), value: showCircle)

      Text(formatTime(timeRemaining))
        .font(.system(size: 48, weight: .black).monospaced())
        .foregroundStyle(.primary)
        .opacity(showTimerText ? (isBreak ? 0.25 : 0.75) : 0.0)
        .animation(.easeInOut(duration: 0.5), value: isBreak)
        .animation(.easeOut(duration: 2.0), value: showTimerText)
    }
    .frame(width: 250, height: 250)
    .onAppear {
      setupInitialTimer()
      setupController()
      startTimer()
    }
    .onChange(of: roundLength) { _, _ in
      setupInitialTimer()
    }
    .onChange(of: breakLength) { _, _ in
      setupInitialTimer()
    }
    .onChange(of: rounds) { _, _ in
      setupInitialTimer()
    }
    .onChange(of: backgroundTimer.timeRemaining) { _, newValue in
      timeRemaining = newValue
      updateProgress()

      if timeRemaining <= 0 && isRunning {
        completeCurrentSession()
      }
    }
  }

  private func setupController() {
    controller.startTimer = { [self] in
      startTimer()
    }
    controller.pauseTimer = { [self] in
      pauseTimer()
    }
    controller.resetTimer = { [self] in
      resetTimer()
    }
  }

  func startTimer() {
    isRunning = true
    controller.isRunning = true

    // Set the time remaining based on current session
    timeRemaining = currentSessionLength

    // Only play sound and haptic feedback when starting fresh, not resuming
    if !isResuming {
      // Haptic feedback for round start
      if vibrationEnabled {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
      }

      // Sound effect for round start
      playSound(roundStartSound)

      // Start the background timer for the current session duration
      backgroundTimer.startTimer(duration: timeRemaining)
    } else {
      // Resume the existing timer
      backgroundTimer.resumeTimer()
    }

    isResuming = false

    updateProgress()
  }

  func pauseTimer() {
    isRunning = false
    controller.isRunning = false
    isResuming = true

    // Pause the background timer
    backgroundTimer.pauseTimer()
  }

  func resetTimer() {
    stopTimer()
    setupInitialTimer()
    isCompleted = false
    controller.isCompleted = false
    showCircle = true
    showTimerText = true

    // Reset the background timer
    backgroundTimer.resetTimer()
  }

  private func setupInitialTimer() {
    timeRemaining = roundLength
    currentRound = 1
    progress = 0.0
    isBreak = false
    isCompleted = false
    isRunning = false
    isResuming = false
    showCircle = true
    showTimerText = true
    circleID = UUID()  // Generate new circle on reset
    stopTimer()
  }

  private func stopTimer() {
    isRunning = false
    controller.isRunning = false

    // Stop the background timer
    backgroundTimer.resetTimer()
  }

  private func updateProgress() {
    if isBreak {
      return
    }

    let elapsedTime = Double(roundLength - timeRemaining)
    let roundProgress = min(1.0, (elapsedTime + 1) / Double(roundLength))

    if isInfiniteMode {
      progress = roundProgress
    } else {
      let completedRounds = Double(currentRound - 1)
      progress = (completedRounds + roundProgress) / Double(rounds)
    }
  }

  private func completeCurrentSession() {
    if isBreak {
      isBreak = false
      timeRemaining = roundLength

      if vibrationEnabled {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
      }

      playSound(roundStartSound)

      if !isInfiniteMode {
        currentRound += 1
        if currentRound > rounds {
          completeAllRounds()
          return
        }
      }

      // Start timer for the next round
      backgroundTimer.startTimer(duration: timeRemaining)
    } else {
      updateProgress()

      if breakLength > 0 && (isInfiniteMode || currentRound < rounds) {
        isBreak = true
        timeRemaining = breakLength

        if vibrationEnabled {
          let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
          impactFeedback.impactOccurred()
        }

        playSound(breakStartSound)

        // Start timer for the break
        backgroundTimer.startTimer(duration: timeRemaining)
      } else if !isInfiniteMode {
        currentRound += 1
        if currentRound > rounds {
          completeAllRounds()
          return
        } else {
          timeRemaining = roundLength

          if vibrationEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
          }

          playSound(roundStartSound)

          // Start timer for the next round
          backgroundTimer.startTimer(duration: timeRemaining)
        }
      } else {
        timeRemaining = roundLength
        progress = 0.0  // Reset to 0 to show full circle for new infinite mode round
        circleID = UUID()  // Generate new circle for infinite mode

        if vibrationEnabled {
          let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
          impactFeedback.impactOccurred()
        }

        playSound(roundStartSound)

        // Start timer for the next infinite round
        backgroundTimer.startTimer(duration: timeRemaining)
      }
    }

    updateProgress()
  }

  private func completeAllRounds() {
    stopTimer()
    isCompleted = true
    controller.isCompleted = true
    progress = 1.0

    if vibrationEnabled {
      let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
      impactFeedback.impactOccurred()

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        impactFeedback.impactOccurred()
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        impactFeedback.impactOccurred()
      }
    }

    playSound(sessionEndSound)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      showTimerText = false
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      showCircle = false
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      resetProgressBars()
    }
  }

  private func resetProgressBars() {
    progress = 0.0
    currentRound = 1
    timeRemaining = roundLength
    isBreak = false
    showCircle = false
    showTimerText = false
  }
}

#Preview {
  Timer(
    rounds: 5,
    roundLength: 60,
    breakLength: 10,
    controller: TimerController()
  )
  .environmentObject(BackgroundTimer())
}
