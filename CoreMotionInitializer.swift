//
//  CoreMotionInitializer.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//

import SwiftUI
import CoreMotion
import WatchConnectivity
import UserNotifications
import WatchKit
import HealthKit
extension WatchView{
    public func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available.")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // Update rate of 60 Hz
        let manager = motionManager // Capture motionManager in a local variable
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [manager] data, error in
            guard let data = data else { return }

            let isSitting = self.isSittingFromDeviceMotion(data)

            DispatchQueue.main.async {
                self.updateSittingStatus(isSitting: isSitting)
            }
        }
    }

    public func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
 
}
