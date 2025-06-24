//
//  SettingsView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("vibrationEnabled") private var vibrationEnabled = true
  @AppStorage("roundStartSound") private var roundStartSound = "bowl"
  @AppStorage("breakStartSound") private var breakStartSound = "bell"
  
  private let soundOptions = ["none", "bell", "bowl", "ding", "gong"]

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {

        Form {
          Toggle("Vibration", isOn: $vibrationEnabled)
          
          Section("Sound Effects") {
            Picker("Round Start", selection: $roundStartSound) {
              ForEach(soundOptions, id: \.self) { sound in
                Text(sound.capitalized).tag(sound)
              }
            }
            
            Picker("Break Start", selection: $breakStartSound) {
              ForEach(soundOptions, id: \.self) { sound in
                Text(sound.capitalized).tag(sound)
              }
            }
          }
        }

        //        Spacer()
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
