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
    
    private var isInfiniteMode: Bool {
        rounds == 0
    }
    
    private var segmentAngle: Double {
        isInfiniteMode ? 0 : 360.0 / Double(rounds)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
            
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
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            } else {
                // Segmented progress for finite rounds
                ForEach(0..<rounds, id: \.self) { index in
                    let isCompleted = index < currentRound - 1
                    let isCurrent = index == currentRound - 1
                    let segmentProgress = isCurrent ? progress : (isCompleted ? 1.0 : 0.0)
                    
                    Circle()
                        .trim(
                            from: Double(index) / Double(rounds),
                            to: Double(index) / Double(rounds) + (segmentProgress / Double(rounds))
                        )
                        .stroke(
                            isCompleted ? Color.green :
                            isCurrent ? Color.blue : Color.clear,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: segmentProgress)
                }
                
                // Segment dividers
                ForEach(0..<rounds, id: \.self) { index in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: 20)
                        .offset(y: -100)
                        .rotationEffect(.degrees(Double(index) * segmentAngle - 90))
                }
            }
            
            // Center text
            HStack {
                if isInfiniteMode {
                    Text("∞")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                } else {
                    Text("\(currentRound)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Text("/ \(rounds)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPaused = false
    
    let rounds: Int
    let lengthSeconds: Int
    let breakSeconds: Int
    @State private var currentRound = 1
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            SegmentedRadialProgressView(
                rounds: rounds,
                currentRound: currentRound,
                progress: progress
            )
            .frame(width: 200, height: 200)
                
            Spacer()
            
            HStack(spacing: 30) {
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
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
    }
}

#Preview {
    TimerView(rounds: 5, lengthSeconds: 300, breakSeconds: 30)
}
