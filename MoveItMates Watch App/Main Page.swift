import SwiftUI
import CoreMotion
import WatchConnectivity
import UserNotifications
import WatchKit
import HealthKit

class WatchDelegate: NSObject, WCSessionDelegate {
    private var session: WCSession?

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

struct WatchView: View {
    @State private var isSitting = false
        @State private var sittingDuration: TimeInterval = 0
        @State private var timeBeforeBreak: TimeInterval = 0
        @State private var totalSittingTimeToday: TimeInterval = 0
        @State private var reminderInterval: TimeInterval = 3600 // Default reminder interval of 1 hour
        @State private var enableNotifications = true
        @State private var enableSound = true
        @State private var enableVibration = true

        private let motionManager = CMMotionManager()
        private let session = WCSession.default
        @State private var delegate: WatchDelegate?
        @State private var previousSittingDuration: TimeInterval = 0
    private let healthStore = HKHealthStore()
    private let newSittingTimeCategory = HKQuantityTypeIdentifier(rawValue: "newSittingTimeCategory")
       


    var body: some View {
        ScrollView {
            
            VStack {
                
                Text("Move It Mate")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                ZStack{
                    Circle()
                        .foregroundColor(.white)
                        .opacity(0.15)
                    CircularProgressBarView(timeUntilBreak: timeBeforeBreak, progressColor: Color(hex: "CB95F6"), totalTime: reminderInterval)
                    VStack {
                        Text("Next Break In")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("\(formattedDuration(timeBeforeBreak))")
                            .font(.title)
                            .padding()
                    }
                    .frame(width: 170) // Adjust the desired height for the rectangle
                }.frame(width: 185)
                VStack {
                    Text("Sitting Status")
                        .font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    Text(isSitting ? "Sitting" : "Not Sitting")
                        .font(.title)
                        .padding()
                }
                .frame(width: 170) // Adjust the desired height for the rectangle
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .padding(.horizontal)
                        .opacity(0.2)
                )
                .padding(.vertical)
                
                VStack {
                    Text("Sitting Duration")
                        .font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    
                    Text("\(formattedDuration(accumulatedSittingDuration))")
                        .font(.title)
                        .padding()
                }
                .frame(width: 170) // Adjust the desired height for the rectangle
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .padding(.horizontal)
                        .opacity(0.2)
                )
                .padding(.vertical)
                
                VStack {
                    Text("Time Before Break")
                        .font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    
                    Text("\(formattedDuration(timeBeforeBreak))")
                        .font(.title)
                        .padding()
                }
                .frame(width: 170) // Adjust the desired height for the rectangle
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .padding(.horizontal)
                        .opacity(0.2)
                )
                .padding(.vertical)
                
                VStack {
                    Text("Total Sitting Time Today")
                        .font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    
                    Text("\(formattedDuration(totalSittingTimeToday))")
                        .font(.title)
                        .padding()
                }
                .frame(width: 170) // Adjust the desired height for the rectangle
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .padding(.horizontal)
                        .opacity(0.2)
                )
                .padding(.vertical)
                
                VStack {
                                   Text("Settings")
                                       .font(.title2)
                                       .padding()
                                       .fontWeight(.bold)

                                   Toggle("Enable Notifications", isOn: $enableNotifications)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding()
                                       .background(Color(hex:"373434"))

                                   Toggle("Enable Sound", isOn: $enableSound)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding()
                                       .background(Color(hex:"373434"))
                                   Toggle("Enable Vibration", isOn: $enableVibration)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding()
                                       .background(Color(hex:"373434"))
                                   VStack() {
                                       Text("Reminder Interval")
                                           .font(.subheadline)
                                           .padding(.bottom, 2)

                                       VStack {
                                           Slider(value: $reminderInterval, in: 1800...7200, step: 1800)
                                               .accentColor(Color(hex: "CB95F6"))
                                           Text("\(Int(reminderInterval / 60)) minutes")
                                       }
                                       .padding(.leading)
                                       .padding(.trailing, 10)
                                   }
                                   .padding(.bottom)
                                   .background(Color(hex:"373434"))
                    
                }
                .frame(width: 200) // Adjust the desired height for the rectangle
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .padding(.horizontal)
                        .opacity(0.15)
                )
                .padding(.vertical)
            }
        
               }
        .onAppear {
            setupWatchConnectivity()
            startMotionUpdates()
            registerLocalNotifications()
            requestHealthKitAuthorization()
            
        }
        .onDisappear {
            stopMotionUpdates()
        }
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            delegate = WatchDelegate(session: session)
            session.delegate = delegate
            session.activate()
        }
    }
    private func requestHealthKitAuthorization() {
        guard let sittingType = HKObjectType.quantityType(forIdentifier: newSittingTimeCategory) else {
            print("Failed to retrieve quantity type for sitting time.")
            return
        }

        let typesToWrite: Set<HKSampleType> = [sittingType]

        healthStore.requestAuthorization(toShare: typesToWrite, read: nil) { success, error in
            if let error = error {
                print("Failed to request HealthKit authorization: \(error.localizedDescription)")
            }
        }
    }




    private func startMotionUpdates() {
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

    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
   



    private func isSittingFromDeviceMotion(_ motionData: CMDeviceMotion) -> Bool {
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




   @State  private var lastUpdateTime: Date?
    @State private var accumulatedSittingDuration: TimeInterval = 0

    private func updateSittingStatus(isSitting: Bool) {
        let currentTime = Date()
        
        if isSitting {
          
            let sittingDurationQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: totalSittingTimeToday)

                   let sampleType = HKObjectType.quantityType(forIdentifier: newSittingTimeCategory)!
                   let sample = HKQuantitySample(type: sampleType, quantity: sittingDurationQuantity, start: currentTime, end: currentTime)

                   healthStore.save(sample) { success, error in
                       if let error = error {
                           print("Failed to save sitting duration to HealthKit: \(error.localizedDescription)")
                       }
                   }
            if !self.isSitting {
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




    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: duration) ?? "00:00:00:00"
    }


    // MARK: - Local Notifications

    private func registerLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Failed to request authorization for local notifications: \(error.localizedDescription)")
            }
        }
    }

    private func showBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a Break"
        content.body = "It's time to stand up and stretch!"
       
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

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView()
    }
}


