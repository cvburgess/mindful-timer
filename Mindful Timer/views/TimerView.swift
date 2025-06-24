//
//  TimerView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import AVFoundation
import SwiftUI

struct SegmentedRadialProgressView: View {
  @Environment(\.colorScheme) private var colorScheme
  let rounds: Int
  let currentRound: Int
  let progress: Double
  let timeRemaining: Int
  let isCompleted: Bool
  let isBreak: Bool
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

  private var progressGradient: LinearGradient {
    if colorScheme == .dark {
      return LinearGradient(
        colors: [.purple, .blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    } else {
      return LinearGradient(
        colors: [.pink, .orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
  }

  private var progressColor: Color {
    colorScheme == .dark ? .blue : .orange
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
            progressGradient,
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
          let dotColor: Color = (isCompleted || isCurrent) ? progressColor : .clear

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
              progressColor,
              style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1.0), value: segmentProgress)
        }
      }

    }
  }
}

struct TimerView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @AppStorage("selectedTheme") private var selectedTheme = Theme.waves.rawValue

  @StateObject private var timerController = TimerController()

  @Binding var rounds: Int
  @Binding var lengthSeconds: Int
  @Binding var breakSeconds: Int

  private var currentTheme: Theme {
    Theme(rawValue: selectedTheme) ?? .waves
  }

  var body: some View {
    VStack(spacing: 40) {

      Spacer()

      Timer(
        rounds: rounds,
        roundLength: lengthSeconds,
        breakLength: breakSeconds,
        controller: timerController
      )

      Spacer()

      HStack(spacing: 30) {
        GlassButton(action: {
          if timerController.isCompleted {
            timerController.reset()
            timerController.start()
          } else if timerController.isRunning {
            timerController.pause()
          } else {
            timerController.start()
          }
        }) {
          Image(
            systemName: (timerController.isRunning && !timerController.isCompleted)
              ? "pause.fill" : "play.fill"
          )
          .font(.system(size: 30))
          .foregroundColor(.orange)
          .padding(10)
          .frame(width: 80, height: 80)
        }

        GlassButton(action: {
          dismiss()
        }) {
          Image(systemName: "stop.fill")
            .font(.system(size: 30))
            .foregroundColor(.red)
            .padding(10)
            .frame(width: 80, height: 80)
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      Image(currentTheme.imageName(for: colorScheme))
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
    )
  }

}

#Preview {
  TimerView(rounds: .constant(21), lengthSeconds: .constant(5), breakSeconds: .constant(0))
}
