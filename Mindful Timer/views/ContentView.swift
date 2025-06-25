//
//  ContentView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftData
import SwiftUI

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
