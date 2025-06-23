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
    @State private var lengthSeconds: Int = 0
    @State private var breakMinutes: Int = 0
    @State private var breakSeconds: Int = 30

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Mindful Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Rounds:")
                            .frame(width: 80, alignment: .leading)
                        Stepper(value: $rounds, in: 0...100) {
                            HStack {
                                Text(rounds == 0 ? "∞" : "\(rounds)")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minWidth: 30, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                    
                    HStack {
                        Text("Length:")
                            .frame(width: 80, alignment: .leading)
                        HStack {
                            Stepper(value: $lengthMinutes, in: 0...10) {
                                Text("\(lengthMinutes)m")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minWidth: 30, alignment: .leading)
                            }
                            .onChange(of: lengthMinutes) { _, newValue in
                                if newValue == 0 && lengthSeconds == 0 {
                                    lengthSeconds = 1
                                } else if newValue == 10 {
                                    lengthSeconds = 0
                                }
                            }
                            
                            Stepper(value: $lengthSeconds, in: 0...(lengthMinutes == 10 ? 0 : 59)) {
                                Text("\(lengthSeconds)s")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minWidth: 30, alignment: .leading)
                            }
                            .onChange(of: lengthSeconds) { _, newValue in
                                if lengthMinutes == 0 && newValue == 0 {
                                    lengthSeconds = 1
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Text("Break:")
                            .frame(width: 80, alignment: .leading)
                        HStack {
                            Stepper(value: $breakMinutes, in: 0...1) {
                                Text("\(breakMinutes)m")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minWidth: 30, alignment: .leading)
                            }
                            .onChange(of: breakMinutes) { _, newValue in
                                if newValue == 1 {
                                    breakSeconds = 0
                                }
                            }
                            
                            Stepper(value: $breakSeconds, in: 0...(breakMinutes == 1 ? 0 : 59)) {
                                Text("\(breakSeconds)s")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minWidth: 30, alignment: .leading)
                            }
                        }
                        Spacer()
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
