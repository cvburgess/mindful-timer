//
//  Theme.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/24/25.
//

import SwiftUI

enum Theme: String, CaseIterable {
  case waves = "waves"
  case lake = "lake"
  case clouds = "clouds"

  var displayName: String {
    switch self {
    case .waves:
      return "Waves"
    case .lake:
      return "Lake"
    case .clouds:
      return "Clouds"
    }
  }

  func imageName(for colorScheme: ColorScheme) -> String {
    let mode = colorScheme == .dark ? "dark" : "light"
    return "\(rawValue)-\(mode)"
  }
}
