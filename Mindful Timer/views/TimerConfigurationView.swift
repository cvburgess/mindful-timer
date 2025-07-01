//
//  TimerConfigurationView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

struct TimerConfigurationView: View {
  @Environment(\.colorScheme) private var colorScheme
  @AppStorage("selectedTheme") private var selectedTheme = Theme.waves.rawValue
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

  private var currentTheme: Theme {
    Theme(rawValue: selectedTheme) ?? .waves
  }

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
          GlassButton(action: {
            showLengthPicker = false
            showBreakPicker = false
            showRoundsPicker.toggle()
          }) {
            Text(formatRounds(rounds))
              .foregroundColor(.primary).padding(10)
              .frame(width: 200)
          }

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
          GlassButton(action: {
            showRoundsPicker = false
            showBreakPicker = false
            showLengthPicker.toggle()
          }) {
            Text("\(formatTime(lengthTotalSeconds)) each")
              .foregroundColor(.primary).padding(10)
              .frame(width: 200)
          }

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
          GlassButton(action: {
            showRoundsPicker = false
            showLengthPicker = false
            showBreakPicker.toggle()
          }) {
            Text("\(formatTime(breakTotalSeconds)) breaks")
              .foregroundColor(.primary).padding(10)
              .frame(width: 200)
          }

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
        GlassButton(action: {
          showSettings = true
        }) {
          Image(systemName: "gearshape.fill")
            .font(.system(size: 30))
            .foregroundColor(.primary)
            .padding(10)
            .frame(width: 80, height: 80)
        }

        GlassButton(action: {
          showTimer = true
        }) {
          Image(systemName: "play.fill")
            .font(.system(size: 30))
            .foregroundColor(.orange)
            .padding(10)
            .frame(width: 80, height: 80)
        }

      }

    }
    .padding()
    .background(
      Image(currentTheme.imageName(for: colorScheme))
        .resizable()
        .aspectRatio(contentMode: .fill)
        .ignoresSafeArea()
    )
    .navigationTitle("")
    .navigationBarHidden(true)
  }

}
