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
    @State private var lengthMinutes: Int = 5
    @State private var lengthSecondsOnly: Int = 0
    @State private var breakMinutes: Int = 0
    @State private var breakSecondsOnly: Int = 30
    @State private var showRoundsPicker = false
    @State private var showLengthPicker = false
    @State private var showBreakPicker = false
    
    private var lengthTotalSeconds: Int {
        lengthMinutes * 60 + lengthSecondsOnly
    }
    
    private var breakTotalSeconds: Int {
        breakMinutes * 60 + breakSecondsOnly
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else if seconds > 0{
            return "\(seconds)s"
        } else {
            return "no"
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
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Button(action: {
                            showRoundsPicker.toggle()
                        }) {
                                Text(formatRounds(rounds))
                                .foregroundColor(.primary).padding(10)
                                .frame(width: 200)
                        }.buttonStyle(.glass)
                        
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
                                Text("\(formatTime(lengthTotalSeconds)) each")
                                .foregroundColor(.primary).padding(10)
                                .frame(width: 200)
                        }.buttonStyle(.glass)
                        
                        if showLengthPicker {
                            HStack(spacing: 20) {
                                Picker("Minutes", selection: $lengthMinutes) {
                                    ForEach(0...10, id: \.self) { minute in
                                        Text("\(minute)m").tag(minute)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                                .onChange(of: lengthMinutes) { _, newValue in
                                    if newValue == 0 && lengthSecondsOnly == 0 {
                                        lengthSecondsOnly = 1
                                    } else if newValue == 10 {
                                        lengthSecondsOnly = 0
                                    }
                                }
                                
                                Picker("Seconds", selection: $lengthSecondsOnly) {
                                    ForEach(0...(lengthMinutes == 10 ? 0 : 59), id: \.self) { second in
                                        Text("\(second)s").tag(second)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                                .onChange(of: lengthSecondsOnly) { _, newValue in
                                    if lengthMinutes == 0 && newValue == 0 {
                                        lengthSecondsOnly = 1
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            showBreakPicker.toggle()
                        }) {
                                Text("\(formatTime(breakTotalSeconds)) breaks")
                                .foregroundColor(.primary).padding(10)
                                .frame(width: 200)
                        }.buttonStyle(.glass)
                        
                        if showBreakPicker {
                            HStack(spacing: 20) {
                                Picker("Minutes", selection: $breakMinutes) {
                                    ForEach(0...1, id: \.self) { minute in
                                        Text("\(minute)m").tag(minute)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                                .onChange(of: breakMinutes) { _, newValue in
                                    if newValue == 1 {
                                        breakSecondsOnly = 0
                                    }
                                }
                                
                                Picker("Seconds", selection: $breakSecondsOnly) {
                                    ForEach(0...(breakMinutes == 1 ? 0 : 59), id: \.self) { second in
                                        Text("\(second)s").tag(second)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                            }
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
