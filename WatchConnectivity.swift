//
//  WatchConnectivity.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//
//For future updates includong IOS companion app
import SwiftUI
import CoreMotion
import WatchConnectivity
import UserNotifications
import WatchKit
import HealthKit

class WatchDelegate: NSObject, WCSessionDelegate {
    
    public var session: WCSession?

    init(session: WCSession) {
        self.session = session
        super.init()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }

    func sendSittingStatus(isSitting: Bool, sittingDuration: TimeInterval) {
        let message: [String: Any] = [
            "isSitting": isSitting,
            "sittingDuration": sittingDuration
        ]

        session?.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
}

extension WatchView{
    public func setupWatchConnectivity() {
        if WCSession.isSupported() {
            delegate = WatchDelegate(session: session)
            session.delegate = delegate
            session.activate()
        }
    }
}
