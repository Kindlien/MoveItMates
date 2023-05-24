//
//  WacthDelegate.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 24/05/23.
//
import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any necessary setup tasks when the app is launched
    }

    func applicationDidEnterBackground() {
        // Handle tasks when the app enters the background
        // For example, start motion updates and register local notifications
        // Make sure to call the corresponding methods from your WatchView
        WatchSessionManager.shared.startMotionUpdates()
        WatchSessionManager.shared.registerLocalNotifications()
    }

    func applicationWillEnterForeground() {
        // Handle tasks when the app enters the foreground
        // For example, stop motion updates
        // Make sure to call the corresponding methods from your WatchView
        WatchSessionManager.shared.stopMotionUpdates()
    }

    func applicationDidBecomeActive() {
        // Handle tasks when the app becomes active
        // For example, reset sitting time if it's a new day
        // Make sure to call the corresponding methods from your WatchView
        WatchSessionManager.shared.resetSittingTimeIfNewDay()
    }

    func applicationWillResignActive() {
        // Handle tasks when the app resigns active
    }

}


class WatchSessionManager: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
    }
    
    func startMotionUpdates() {
        // Implement your motion updates logic here
    }
    
    func stopMotionUpdates() {
        // Implement your stop motion updates logic here
    }
    
    func registerLocalNotifications() {
        // Implement your local notification registration logic here
    }
    
    func resetSittingTimeIfNewDay() {
        // Implement your reset sitting time logic here
    }
    
    // ... implement other necessary WCSessionDelegate methods ...
}
