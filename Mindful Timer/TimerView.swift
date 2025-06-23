//
//  TimerView.swift
//  Mindful Timer
//
//  Created by Charles Burgess on 6/22/25.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPaused = false
    
    var body: some View {
        VStack(spacing: 40) {
            // TODO: Replace this with a segmented radial progress bar
                
            Spacer()
            
            HStack(spacing: 30) {
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 30))
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                        .clipShape(Circle())
                }.buttonStyle(.glass)
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                        .clipShape(Circle())
                }.buttonStyle(.glass)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    TimerView()
}
