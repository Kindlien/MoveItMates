//
//  NotificationFunction.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//

import SwiftUI
import UserNotifications
import SwiftUI
import CoreMotion
import WatchConnectivity
import UserNotifications
import WatchKit
import HealthKit
extension WatchView{
   

    public func registerLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Failed to request authorization for local notifications: \(error.localizedDescription)")
            }
        }
    }

    public func showBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a Break"
        content.body = "It's time to stand up and stretch! Recommended time of 5 minutes"
       
        if enableSound == true{ content.sound = UNNotificationSound.default}
        if enableVibration == true { WKInterfaceDevice.current().play(.success)
        }
        
        let request = UNNotificationRequest(identifier: "breakNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Failed to schedule break notification: \(error.localizedDescription)")
            }
        }
    }
}
