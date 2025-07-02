//
//  SettingsView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("vibrationEnabled") private var vibrationEnabled = true
  @AppStorage("roundStartSound") private var roundStartSound = "ding"
  @AppStorage("breakStartSound") private var breakStartSound = "none"
  @AppStorage("sessionEndSound") private var sessionEndSound = "bowl"
  @AppStorage("selectedTheme") private var selectedTheme = Theme.waves.rawValue
  @State private var audioPlayer: AVAudioPlayer?
  @State private var showingAttributions = false

  private let soundOptions = ["none", "bell", "bowl", "ding", "gong"]

  private var currentTheme: Theme {
    Theme(rawValue: selectedTheme) ?? .waves
  }

  private func playSound(_ soundName: String) {
    guard soundName != "none" else { return }

    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
      print("Could not find \(soundName).wav file")
      return
    }

    do {
      // Configure audio session to mix with other apps and duck their audio
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, options: [.mixWithOthers, .duckOthers])
      try audioSession.setActive(true)
      
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.play()
    } catch {
      print("Error playing sound: \(error)")
    }
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {

        Form {

          Picker("Theme", selection: $selectedTheme) {
            ForEach(Theme.allCases, id: \.self) { theme in
              Text(theme.displayName).tag(theme.rawValue)
            }
          }

          Toggle("Vibration", isOn: $vibrationEnabled)

          Picker("Round Start", selection: $roundStartSound) {
            ForEach(soundOptions, id: \.self) { sound in
              Text(sound.capitalized).tag(sound)
            }
          }
          .onChange(of: roundStartSound) { _, newValue in
            playSound(newValue)
          }

          Picker("Break Start", selection: $breakStartSound) {
            ForEach(soundOptions, id: \.self) { sound in
              Text(sound.capitalized).tag(sound)
            }
          }
          .onChange(of: breakStartSound) { _, newValue in
            playSound(newValue)
          }

          Picker("Session End", selection: $sessionEndSound) {
            ForEach(soundOptions, id: \.self) { sound in
              Text(sound.capitalized).tag(sound)
            }
          }
          .onChange(of: sessionEndSound) { _, newValue in
            playSound(newValue)
          }

          Section {
            HStack {
              Button("Source on GitHub") {
                if let url = URL(string: "https://github.com/cvburgess/mindful-timer/") {
                  UIApplication.shared.open(url)
                }
              }
              .foregroundColor(.primary)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.footnote)
            }
            HStack {
              Button("Attributions") {
                showingAttributions = true
              }
              .foregroundColor(.primary)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.footnote)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemBackground))
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .sheet(isPresented: $showingAttributions) {
        AttributionsView()
      }
    }
  }
}

#Preview {
  SettingsView()
}
