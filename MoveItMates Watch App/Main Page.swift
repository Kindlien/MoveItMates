import SwiftUI
import CoreMotion
import WatchConnectivity
import UserNotifications
import WatchKit
import HealthKit

struct WatchView: View {
    
    @State public var isSitting = false
        @State public var sittingDuration: TimeInterval = 0
        @State public var timeBeforeBreak: TimeInterval = 0
        @AppStorage(UserKeys.totalsitting.rawValue) public var totalSittingTimeToday: TimeInterval = 0
    
    @AppStorage("ReminderInterval") var reminderInterval: TimeInterval = 3600 // Default reminder interval of 1 hour
    @AppStorage("EnableNotifications") var enableNotifications = true
    @AppStorage("EnableSound") var enableSound = true
    @AppStorage("EnableVibration") var enableVibration = true

        public let motionManager = CMMotionManager()
        public let session = WCSession.default
        @State public var delegate: WatchDelegate?
        @State public var previousSittingDuration: TimeInterval = 0
//    private let healthStore = HKHealthStore()
//    private let newSittingTimeCategory = HKQuantityTypeIdentifier(rawValue: "newSittingTimeCategory")
    @State  public var lastUpdateTime: Date?
     @State public var accumulatedSittingDuration: TimeInterval = 0



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
                    VStack() {
                        Text("Reminder Interval")
                            .font(.subheadline)
                            .padding(.bottom, 2)

                        VStack {
                            Slider(value: $reminderInterval, in: 1800...7200, step: 1800)
                                .accentColor(Color(hex: "CB95F6"))
                            Text("\(Int(reminderInterval / 60)) minutes")
                                .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex:"373434"))
                                .padding(.horizontal)
                                .opacity(1)
                                .frame(width: 120))
                            
                            
                        }
                        .padding(.leading)
                        .padding(.trailing, 10)
                    }
                    .padding(.bottom)
                    .padding(.top)
                                   Toggle("Enable Notifications", isOn: $enableNotifications)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding(.trailing,15)
                                       .padding(.leading,15)
                                       .padding()
                                       

                                   Toggle("Enable Sound", isOn: $enableSound)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding(.trailing,15)
                                       .padding(.leading,15)
                                       .padding()
                                   Toggle("Enable Vibration", isOn: $enableVibration)
                                       .toggleStyle(SwitchToggleStyle(tint: Color(hex: "CB95F6")))
                                       .padding(.trailing,15)
                                       .padding(.leading,15)
                                       .padding()
                                       
                                   
//                                   .background(Color(hex:"373434"))
                    
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
//            requestHealthKitAuthorization()
         resetSittingTimeIfNewDay()
            
        }
        .onDisappear {
            stopMotionUpdates()
        }
    }


}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView()
    }
}


