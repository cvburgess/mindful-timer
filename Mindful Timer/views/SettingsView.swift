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
  @State private var audioPlayer: AVAudioPlayer?

  private let soundOptions = ["none", "bell", "bowl", "ding", "gong"]

  private func playSound(_ soundName: String) {
    guard soundName != "none" else { return }

    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
      print("Could not find \(soundName).wav file")
      return
    }

    do {
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
    }
  }
}

#Preview {
  SettingsView()
}
