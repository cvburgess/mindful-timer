//
//  TimerView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

struct SegmentedRadialProgressView: View {
  let rounds: Int
  let currentRound: Int
  let progress: Double
  let timeRemaining: Int
  let isCompleted: Bool
  let strokeWidth: CGFloat = 12

  private var isInfiniteMode: Bool {
    rounds == 0
  }

  private var useDots: Bool {
    !isInfiniteMode && rounds > 20
  }

  private var segmentAngle: Double {
    isInfiniteMode ? 0 : 360.0 / Double(rounds)
  }

  private var spacingRatio: Double {
    guard !isInfiniteMode else { return 0 }
    return 0.04 * Double(rounds)
  }

  private var wedgeSize: Double {
    guard !isInfiniteMode else { return 0 }
    return (1.0 / Double(rounds)) * (1.0 - spacingRatio)
  }

  var body: some View {
    ZStack {
      if isInfiniteMode {
        // Background circle for infinite mode
        Circle()
          .stroke(Color.secondary.opacity(0.3), lineWidth: 20)
      } else if useDots {
        // Background dots for many rounds
        ForEach(0..<rounds, id: \.self) { index in
          let angle = Double(index) * 360.0 / Double(rounds) - 90.0
          let radius: CGFloat = 125
          let x = cos(angle * .pi / 180) * radius
          let y = sin(angle * .pi / 180) * radius

          Circle()
            .fill(Color.secondary.opacity(0.3))
            .frame(width: strokeWidth, height: strokeWidth)
            .offset(x: x, y: y)
        }
      } else {
        // Background wedges for <= 10 rounds
        ForEach(0..<rounds, id: \.self) { index in
          let wedgeStart = Double(index) / Double(rounds) + (spacingRatio / 2.0) / Double(rounds)

          Circle()
            .trim(
              from: wedgeStart,
              to: wedgeStart + wedgeSize
            )
            .stroke(
              Color.secondary.opacity(0.3),
              style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
        }
      }

      if isInfiniteMode {
        // Continuous ring for infinite mode
        Circle()
          .trim(from: 0, to: progress)
          .stroke(
            LinearGradient(
              colors: [.blue, .purple],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            style: StrokeStyle(lineWidth: 20, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .animation(.linear(duration: 1.0), value: progress)
      } else if useDots {
        // Progress dots for many rounds
        ForEach(0..<rounds, id: \.self) { index in
          let angle = Double(index) * 360.0 / Double(rounds) - 90.0
          let radius: CGFloat = 125
          let x = cos(angle * .pi / 180) * radius
          let y = sin(angle * .pi / 180) * radius

          let isCompleted = index < currentRound - 1
          let isCurrent = index == currentRound - 1
          let dotColor: Color = isCompleted ? .blue : (isCurrent ? .orange : .clear)

          Circle()
            .fill(dotColor)
            .frame(width: strokeWidth, height: strokeWidth)
            .offset(x: x, y: y)
            .animation(.linear(duration: 0.3), value: dotColor)
        }
      } else {
        // Individual wedges for each round with spacing (<= 10 rounds)
        ForEach(0..<rounds, id: \.self) { index in
          let isCompleted = index < currentRound - 1
          let isCurrent = index == currentRound - 1
          let segmentProgress =
            isCurrent
            ? (progress - Double(index) / Double(rounds)) * Double(rounds)
            : (isCompleted ? 1.0 : 0.0)

          let wedgeStart = Double(index) / Double(rounds) + (spacingRatio / 2.0) / Double(rounds)

          Circle()
            .trim(
              from: wedgeStart,
              to: wedgeStart + (segmentProgress * wedgeSize)
            )
            .stroke(
              Color.blue,
              style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1.0), value: segmentProgress)
        }
      }

      Text(formatTime(timeRemaining))
        .font(.system(size: 48, weight: .black).monospaced())
        .foregroundStyle(.primary)
        .opacity(0.75)

    }
  }

  private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}

struct TimerView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPaused = false
  @State private var isRunning = false

  let rounds: Int
  let lengthSeconds: Int
  let breakSeconds: Int
  @State private var currentRound = 1
  @State private var progress: Double = 0.0
  @State private var timeRemaining: Int = 0
  @State private var isBreak = false
  @State private var isCompleted = false
  @State private var timer: Timer?

  private var isInfiniteMode: Bool {
    rounds == 0
  }

  private var totalRounds: Int {
    isInfiniteMode ? 1 : rounds
  }

  private var currentSessionLength: Int {
    isBreak ? breakSeconds : lengthSeconds
  }

  private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }

  var body: some View {
    VStack(spacing: 40) {

      Spacer()

      if isCompleted {
        VStack {
          Text("Done!")
            .font(.system(size: 48, weight: .bold).monospaced())
            .foregroundColor(.secondary)
        }
        .frame(width: 200, height: 200)
      } else {
        SegmentedRadialProgressView(
          rounds: rounds,
          currentRound: currentRound,
          progress: progress,
          timeRemaining: timeRemaining,
          isCompleted: isCompleted
        )
        .frame(width: 250, height: 250)
      }

      Spacer()

      HStack(spacing: 30) {
        Button(action: {
          if isRunning {
            pauseTimer()
          } else {
            startTimer()
          }
        }) {
          Image(systemName: isRunning ? "pause.fill" : "play.fill")
            .font(.system(size: 30))
            .frame(width: 80, height: 80)
            .foregroundColor(.orange)
            .clipShape(Circle())
        }.buttonStyle(.glass)

        Button(action: {
          dismiss()
        }) {
          Image(systemName: "stop.fill")
            .font(.system(size: 30))
            .frame(width: 80, height: 80)
            .foregroundColor(.red)
            .clipShape(Circle())
        }.buttonStyle(.glass)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      Image("waves-\(colorScheme == .dark ? "dark" : "light")")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
    )
    .onAppear {
      setupInitialTimer()
      startTimer()
    }
    .onDisappear {
      stopTimer()
    }
  }

  private func setupInitialTimer() {
    timeRemaining = lengthSeconds
    currentRound = 1
    progress = 0.0
    isBreak = false
    isCompleted = false
  }

  private func startTimer() {
    isRunning = true
    updateProgress()  // Update progress immediately when starting
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      timeRemaining -= 1
      updateProgress()

      if timeRemaining <= 0 {
        completeCurrentSession()
      }
    }
  }

  private func pauseTimer() {
    isRunning = false
    timer?.invalidate()
    timer = nil
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
    isRunning = false
  }

  private func updateProgress() {
    if isBreak {
      // Don't update progress during breaks - keep current progress
      return
    }

    // Calculate progress to start immediately and complete 1 second before text reaches 0
    let elapsedTime = Double(lengthSeconds - timeRemaining)
    let roundProgress = min(1.0, (elapsedTime + 1) / Double(lengthSeconds))

    if isInfiniteMode {
      progress = roundProgress
    } else {
      let completedRounds = Double(currentRound - 1)
      progress = (completedRounds + roundProgress) / Double(rounds)
    }
  }

  private func completeCurrentSession() {
    if isBreak {
      // Break completed, start next round
      isBreak = false
      timeRemaining = lengthSeconds

      if !isInfiniteMode {
        currentRound += 1
        if currentRound > rounds {
          // All rounds completed
          completeAllRounds()
          return
        }
      }
    } else {
      // Round completed - update progress immediately before break
      updateProgress()

      if breakSeconds > 0 && (!isInfiniteMode && currentRound < rounds) {
        // Start break
        isBreak = true
        timeRemaining = breakSeconds
      } else if !isInfiniteMode {
        // No break, move to next round or complete
        currentRound += 1
        if currentRound > rounds {
          completeAllRounds()
          return
        } else {
          timeRemaining = lengthSeconds
        }
      } else {
        // Infinite mode, restart
        timeRemaining = lengthSeconds
        progress = 0.0
      }
    }

    updateProgress()
  }

  private func completeAllRounds() {
    stopTimer()
    isCompleted = true
    progress = 1.0
  }
}

#Preview {
  TimerView(rounds: 21, lengthSeconds: 5, breakSeconds: 0)
}
