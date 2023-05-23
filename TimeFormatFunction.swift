//
//  TimeFormatFunction.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//

import SwiftUI
extension WatchView{
    
    public func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: duration) ?? "00:00:00:00"
    }
}
