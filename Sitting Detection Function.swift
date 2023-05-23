//
//  Sitting Detection Function.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//

import SwiftUI
import CoreMotion
extension WatchView{
    public func isSittingFromDeviceMotion(_ motionData: CMDeviceMotion) -> Bool {
        let pitchThreshold: Double = 0.2 // Adjust this threshold as needed
        let rollThreshold: Double = 0.2 // Adjust this threshold as needed
        let gravityThreshold: Double = 0.8 // Adjust this threshold as needed
        let accelerationThreshold: Double = 0.5 // Adjust this threshold as needed

        let pitch = motionData.attitude.pitch
        let roll = motionData.attitude.roll
        let gravity = motionData.gravity
        let acceleration = motionData.userAcceleration

        let isPitchWithinThreshold = abs(pitch) < pitchThreshold
        let isRollWithinThreshold = abs(roll) < rollThreshold
        let isGravityWithinThreshold = gravity.z < gravityThreshold
        let isAccelerationWithinThreshold = acceleration.z < accelerationThreshold

        return isPitchWithinThreshold && isRollWithinThreshold && isGravityWithinThreshold && isAccelerationWithinThreshold
    }
}
