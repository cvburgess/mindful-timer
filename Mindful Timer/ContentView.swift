//
//  ContentView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showTimer = false
    @State private var showSettings = false
    @State private var rounds: Int = 5
    @State private var lengthSeconds: Int = 300
    @State private var breakSeconds: Int = 30
    @State private var showRoundsPicker = false
    @State private var showLengthPicker = false
    @State private var showBreakPicker = false
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    private func formatRounds(_ rounds: Int) -> String {
        if rounds == 0 {
            return "Infinite rounds"
        } else if rounds == 1 {
            return "1 round"
        } else {
            return "\(rounds) rounds"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Mindful Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Button(action: {
                            showRoundsPicker.toggle()
                        }) {
                            HStack {
                                Text(formatRounds(rounds))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .cornerRadius(8)
                        }
                        
                        if showRoundsPicker {
                            Picker("Rounds", selection: $rounds) {
                                Text("∞").tag(0)
                                ForEach(1...100, id: \.self) { round in
                                    Text("\(round)").tag(round)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 120)
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            showLengthPicker.toggle()
                        }) {
                            HStack {
                                Text("Length: \(formatTime(lengthSeconds))")
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .cornerRadius(8)
                        }
                        
                        if showLengthPicker {
                            Picker("Length", selection: $lengthSeconds) {
                                ForEach(1...600, id: \.self) { totalSeconds in
                                    Text(formatTime(totalSeconds)).tag(totalSeconds)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 120)
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            showBreakPicker.toggle()
                        }) {
                            HStack {
                                Text("Break: \(formatTime(breakSeconds))")
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .cornerRadius(8)
                        }
                        
                        if showBreakPicker {
                            Picker("Break", selection: $breakSeconds) {
                                ForEach(0...60, id: \.self) { totalSeconds in
                                    Text(formatTime(totalSeconds)).tag(totalSeconds)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 120)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack(spacing: 30) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 30))
                            .frame(width: 80, height: 80)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        showTimer = true
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 30))
                            .frame(width: 80, height: 80)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showTimer) {
            TimerView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
