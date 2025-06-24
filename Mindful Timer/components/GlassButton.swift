//
//  GlassButton.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

struct GlassButton<Label: View>: View {
  let action: () -> Void
  let label: Label
  
  init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
    self.action = action
    self.label = label()
  }
  
  var body: some View {
    if #available(iOS 26.0, *) {
      Button(action: action) {
        label
      }
      .buttonStyle(.glass)
    } else {
      Button(action: action) {
        label
      }
      .buttonStyle(.bordered)
      .tint(Color(.systemBackground))
    }
  }
}

extension GlassButton where Label == Text {
  init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
    self.init(action: action) {
      Text(titleKey)
    }
  }
  
  init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
    self.init(action: action) {
      Text(title)
    }
  }
}
