//
//  ContentView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftData
import SwiftUI

struct TimePicker: View {
  @Binding var minutes: Int
  @Binding var seconds: Int
  let maxMinutes: Int
  let preventZeroTime: Bool

  var body: some View {
    HStack(spacing: 0) {
      Picker("Minutes", selection: $minutes) {
        ForEach(0...maxMinutes, id: \.self) { minute in
          Text("\(minute)m").tag(minute)
        }
      }
      .pickerStyle(WheelPickerStyle())
      .frame(width: 100, height: 120)
      .onChange(of: minutes) { _, newValue in
        if preventZeroTime && newValue == 0 && seconds == 0 {
          seconds = 1
        } else if newValue == maxMinutes && maxMinutes == 10 {
          seconds = 0
        } else if newValue == maxMinutes && maxMinutes == 1 {
          seconds = 0
        }
      }

      Picker("Seconds", selection: $seconds) {
        let maxSeconds = (minutes == maxMinutes && (maxMinutes == 10 || maxMinutes == 1)) ? 0 : 59
        ForEach(0...maxSeconds, id: \.self) { second in
          Text("\(second)s").tag(second)
        }
      }
      .pickerStyle(WheelPickerStyle())
      .frame(width: 100, height: 120)
      .onChange(of: seconds) { _, newValue in
        if preventZeroTime && minutes == 0 && newValue == 0 {
          seconds = 1
        }
      }
    }
  }
}

struct TimerConfigurationView: View {
  @Environment(\.colorScheme) private var colorScheme

  private func applyGlassStyleIfAvailable<T: View>(_ view: T) -> some View {
    if #available(iOS 26.0, *) {
      return view.buttonStyle(.glass)
    } else {
      return view.buttonStyle(.bordered).tint(Color(.systemBackground))
    }
  }
  @Binding var showTimer: Bool
  @Binding var showSettings: Bool
  @Binding var rounds: Int
  @Binding var lengthMinutes: Int
  @Binding var lengthSecondsOnly: Int
  @Binding var breakMinutes: Int
  @Binding var breakSecondsOnly: Int
  @Binding var showRoundsPicker: Bool
  @Binding var showLengthPicker: Bool
  @Binding var showBreakPicker: Bool

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
    } else if seconds > 0 {
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
    VStack(spacing: 30) {

      Spacer()

      VStack(spacing: 30) {
        VStack(spacing: 10) {
          applyGlassStyleIfAvailable(
            Button(action: {
              showLengthPicker = false
              showBreakPicker = false
              showRoundsPicker.toggle()
            }) {
              Text(formatRounds(rounds))
                .foregroundColor(.primary).padding(10)
                .frame(width: 200)
            }
          )

          if showRoundsPicker {
            Picker("Rounds", selection: $rounds) {
              Text("∞").tag(0)
              ForEach(1...100, id: \.self) { round in
                Text("\(round)").tag(round)
              }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 200, height: 120)
          }
        }

        VStack(spacing: 10) {
          applyGlassStyleIfAvailable(
            Button(action: {
              showRoundsPicker = false
              showBreakPicker = false
              showLengthPicker.toggle()
            }) {
              Text("\(formatTime(lengthTotalSeconds)) each")
                .foregroundColor(.primary).padding(10)
                .frame(width: 200)
            }
          )

          if showLengthPicker {
            TimePicker(
              minutes: $lengthMinutes,
              seconds: $lengthSecondsOnly,
              maxMinutes: 10,
              preventZeroTime: true
            )
          }
        }

        VStack(spacing: 10) {
          applyGlassStyleIfAvailable(
            Button(action: {
              showRoundsPicker = false
              showLengthPicker = false
              showBreakPicker.toggle()
            }) {
              Text("\(formatTime(breakTotalSeconds)) breaks")
                .foregroundColor(.primary).padding(10)
                .frame(width: 200)
            }
          )

          if showBreakPicker {
            TimePicker(
              minutes: $breakMinutes,
              seconds: $breakSecondsOnly,
              maxMinutes: 1,
              preventZeroTime: false
            )
          }
        }
      }
      .padding(.horizontal, 20)

      Spacer()

      HStack(spacing: 30) {
        applyGlassStyleIfAvailable(
          Button(action: {
            showSettings = true
          }) {
            Image(systemName: "gearshape.fill")
              .font(.system(size: 30))
              .frame(width: 80, height: 80)
              .clipShape(Circle())
          }
        )

        applyGlassStyleIfAvailable(
          Button(action: {
            showTimer = true
          }) {
            Image(systemName: "play.fill")
              .font(.system(size: 30))
              .frame(width: 80, height: 80)
              .foregroundColor(.blue)
              .clipShape(Circle())
          }
        )

      }

    }
    .padding()
    .background(
      Image("waves-\(colorScheme == .dark ? "dark" : "light")")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
    )
    .navigationTitle("")
    .navigationBarHidden(true)
  }

  var lengthTotalSecondsPublic: Int {
    lengthTotalSeconds
  }

  var breakTotalSecondsPublic: Int {
    breakTotalSeconds
  }
}

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var showTimer = false
  @State private var showSettings = false
  @AppStorage("rounds") private var rounds: Int = 5
  @AppStorage("lengthMinutes") private var lengthMinutes: Int = 0
  @AppStorage("lengthSecondsOnly") private var lengthSecondsOnly: Int = 30
  @AppStorage("breakMinutes") private var breakMinutes: Int = 0
  @AppStorage("breakSecondsOnly") private var breakSecondsOnly: Int = 3
  @State private var showRoundsPicker = false
  @State private var showLengthPicker = false
  @State private var showBreakPicker = false

  private var lengthSecondsBinding: Binding<Int> {
    Binding(
      get: { lengthMinutes * 60 + lengthSecondsOnly },
      set: { _ in }
    )
  }

  private var breakSecondsBinding: Binding<Int> {
    Binding(
      get: { breakMinutes * 60 + breakSecondsOnly },
      set: { _ in }
    )
  }

  var body: some View {
    NavigationStack {
      TimerConfigurationView(
        showTimer: $showTimer,
        showSettings: $showSettings,
        rounds: $rounds,
        lengthMinutes: $lengthMinutes,
        lengthSecondsOnly: $lengthSecondsOnly,
        breakMinutes: $breakMinutes,
        breakSecondsOnly: $breakSecondsOnly,
        showRoundsPicker: $showRoundsPicker,
        showLengthPicker: $showLengthPicker,
        showBreakPicker: $showBreakPicker
      )
    }
    .fullScreenCover(isPresented: $showTimer) {
      TimerView(
        rounds: $rounds,
        lengthSeconds: lengthSecondsBinding,
        breakSeconds: breakSecondsBinding
      )
    }
    .sheet(isPresented: $showSettings) {
      SettingsView()
    }
  }
}

#Preview {
  ContentView()
}
