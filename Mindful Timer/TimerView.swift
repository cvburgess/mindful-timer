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
            Text("Timer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 30) {
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 30))
                        .frame(width: 80, height: 80)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TimerView()
}