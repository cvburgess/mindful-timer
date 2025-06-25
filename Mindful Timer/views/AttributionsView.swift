//
//  AttributionsView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/24/25.
//

import SwiftUI

struct AttributionsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var attributions: [String] = []

  var body: some View {
    NavigationView {
      List {
        ForEach(attributions, id: \.self) { attribution in
          Text(attribution)
            .font(.system(size: 14))
            .padding(.vertical, 4)
        }
      }
      .navigationTitle("Attributions")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .onAppear {
        loadAttributions()
      }
    }
  }

  private func loadAttributions() {
    guard let url = Bundle.main.url(forResource: "attributions", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let attributionsList = try? JSONDecoder().decode([String].self, from: data)
    else {
      print("Could not load attributions.json")
      return
    }

    attributions = attributionsList
  }
}

#Preview {
  AttributionsView()
}
