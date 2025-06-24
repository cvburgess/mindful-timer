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
    
    private var isInfiniteMode: Bool {
        rounds == 0
    }
    
    private var segmentAngle: Double {
        isInfiniteMode ? 0 : 360.0 / Double(rounds)
    }
    
    var body: some View {
        ZStack {
            // Background wedges
            if !isInfiniteMode {
                ForEach(0..<rounds, id: \.self) { index in
                    let spacingRatio = 0.15 // 15% spacing between wedges
                    let wedgeSize = (1.0 / Double(rounds)) * (1.0 - spacingRatio)
                    let wedgeStart = Double(index) / Double(rounds) + (spacingRatio / 2.0) / Double(rounds)
                    
                    Circle()
                        .trim(
                            from: wedgeStart,
                            to: wedgeStart + wedgeSize
                        )
                        .stroke(
                            Color.gray.opacity(0.3),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
            } else {
                // Background circle for infinite mode
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
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
            } else {
                // Individual wedges for each round with spacing
                ForEach(0..<rounds, id: \.self) { index in
                    let isCompleted = index < currentRound - 1
                    let isCurrent = index == currentRound - 1
                    let segmentProgress = isCurrent ? (progress - Double(index) / Double(rounds)) * Double(rounds) : (isCompleted ? 1.0 : 0.0)
                    
                    let spacingRatio = 0.15 // 15% spacing between wedges
                    let wedgeSize = (1.0 / Double(rounds)) * (1.0 - spacingRatio)
                    let wedgeStart = Double(index) / Double(rounds) + (spacingRatio / 2.0) / Double(rounds)
                    
                    Circle()
                        .trim(
                            from: wedgeStart,
                            to: wedgeStart + (segmentProgress * wedgeSize)
                        )
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: segmentProgress)
                }
            }
            
                Text(formatTime(timeRemaining))
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(.primary)
                .opacity(0.8)
            
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
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
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
                .frame(width: 200, height: 200)
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
        .background(Color(.systemBackground))
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
        updateProgress() // Update progress immediately when starting
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
    TimerView(rounds: 5, lengthSeconds: 300, breakSeconds: 30)
}
