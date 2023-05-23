//
//  CircleProgressBar.swift
//  NaNo2
//
//  Created by William Kindlien Gunawan on 18/05/23.
//

import SwiftUI

struct CircularProgressBarView: View {
    var timeUntilBreak: TimeInterval
    let progressLineWidth: CGFloat = 10.0
    let progressColor: Color
    var totalTime: TimeInterval
    private var progress: Double {
        
        let remainingTime = max(0, timeUntilBreak)
        let progress = (totalTime - remainingTime) / totalTime
        return max(0, min(progress, 1))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: progressLineWidth))

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(progressColor, style: StrokeStyle(lineWidth: progressLineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3))
        }
        .padding()
    }
}


