//
//  TimePicker.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

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