//
//  ResetTotalnewday.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 24/05/23.
//

import Foundation
import SwiftUI
extension WatchView{
    public func resetSittingTimeIfNewDay() {
            let currentDate = Date()
            let lastActiveDate = lastUpdateTime ?? currentDate
            let calendar = Calendar.current
            let currentDay = calendar.component(.day, from: currentDate)
            let lastActiveDay = calendar.component(.day, from: lastActiveDate)
            
            if currentDay != lastActiveDay {
                totalSittingTimeToday = 0
            }
            
            lastUpdateTime = currentDate
        }
}
