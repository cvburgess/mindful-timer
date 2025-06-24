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

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {

        Form {
          Toggle("Vibration", isOn: $vibrationEnabled)
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
