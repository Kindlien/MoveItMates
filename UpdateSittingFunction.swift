//
//  UpdateSittingFunction.swift
//  MoveItMates Watch App
//
//  Created by William Kindlien Gunawan on 23/05/23.
//
import CoreMotion
import SwiftUI
extension WatchView{
    
     public func updateSittingStatus(isSitting: Bool) {
         let currentTime = Date()
         
         if isSitting {
           
 //            if let sittingType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: newSittingTimeCategory.rawValue)) {
 //                let sittingDurationQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: totalSittingTimeToday)
 //                let sample = HKQuantitySample(type: sittingType, quantity: sittingDurationQuantity, start: currentTime, end: currentTime)
 //
 //                healthStore.save(sample) { success, error in
 //                    if let error = error {
 //                        print("Failed to save sitting duration to HealthKit: \(error.localizedDescription)")
 //                    }
 //                }
 //            } else {
 //                print("Failed to retrieve the sittingType for health authorization.")
 //            }

             if !self.isSitting {
//                 let storedTotalSittingTimeTodays = UserDefaults.standard.double(forKey: "TotalSittingTimeToday")
                 resetSittingTimeIfNewDay()
                 totalSittingTimeToday = totalSittingTimeToday + accumulatedSittingDuration
                 // Transition from not sitting to sitting
                 sittingDuration = 0 // Reset sitting duration when starting to sit
                 accumulatedSittingDuration = 0
             }
             self.isSitting = true
             
             // Calculate time since the last update
             if let lastUpdateTime = lastUpdateTime {
                 let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdateTime)
                 accumulatedSittingDuration += timeSinceLastUpdate
             }
             
         
             if timeBeforeBreak == 0 {
                      timeBeforeBreak = reminderInterval
                  }
             timeBeforeBreak = max(reminderInterval - accumulatedSittingDuration, 0)
             
             // Check if it's time for a break
             if timeBeforeBreak == 0 { // Assuming a break should be taken after 60 seconds of sitting
                 if enableNotifications == true{
                     showBreakNotification()
                 }
     //            sittingDuration = 0 // Reset sitting duration after the break notification is shown
                 
             }
             
             // Update total sitting time today
             let calendar = Calendar.current
             let today = calendar.startOfDay(for: currentTime)
             
             if let lastRecordedDate = UserDefaults.standard.object(forKey: "LastRecordedDate") as? Date {
                 // If there is a recorded date, check if it is the same day as today
                 if calendar.isDate(lastRecordedDate, inSameDayAs: today) {
                     // If it is the same day, update the total sitting time
                     let storedTotalSittingTimeToday = UserDefaults.standard.double(forKey: "TotalSittingTimeToday")
 //                    totalSittingTimeToday = totalSittingTimeToday + accumulatedSittingDuration
                 } else {
                     // If it is not the same day, reset the total sitting time
                     totalSittingTimeToday = accumulatedSittingDuration
                 }
             } else {
                 // If there is no recorded date, it means it is the first time running the app today
                 totalSittingTimeToday = accumulatedSittingDuration
             }
             
             // Store the updated total sitting time and the current date
             UserDefaults.standard.set(totalSittingTimeToday, forKey: "TotalSittingTimeToday")
             UserDefaults.standard.set(accumulatedSittingDuration, forKey: "TotalSittingTimeTodays")
             UserDefaults.standard.set(currentTime, forKey: "LastRecordedDate")
             
             // Update the previous sitting duration and last update time
             previousSittingDuration = sittingDuration
             lastUpdateTime = currentTime
         } else {
             self.isSitting = false
         }
         
         let sittingStatus: [String: Any] = [
             "isSitting": isSitting,
             "sittingDuration": sittingDuration
         ]
         
         delegate?.sendSittingStatus(isSitting: isSitting, sittingDuration: sittingDuration)
     }

}
