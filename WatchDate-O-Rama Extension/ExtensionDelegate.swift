//
//  ExtensionDelegate.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import WatchKit
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    var session:  WCSession?
    public var complicationController = ComplicationController()
    
    var locationManager = ASALocationManager.shared
    let notificationCenter = NotificationCenter.default

    let userData = ASAUserData.shared

    override init() {
        super.init()
        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: UPDATED_LOCATION_NAME), object: nil, queue: nil, using: {notification
            in
            if notification.name.rawValue == UPDATED_LOCATION_NAME {
                // TODO:  Put in something to check if we need if something actually needs a refresh!
//                if self.complicationController.complication != nil {
//                    debugPrint(#file, #function, "Update location notification recieved.  Will reload timeline")
//                    CLKComplicationServer.sharedInstance().reloadTimeline(for: self.complicationController.complication!)
//                } else {
//                    debugPrint(#file, #function, "Update location notification recieved.  No complication!")
//                }
            }
        })
    } // override init()

    deinit {
        notificationCenter.removeObserver(self)
    } // deinit
    
    public func requestUserData() {
//        debugPrint(#file, #function)
        
        if WCSession.isSupported() {
            do {
                try session?.updateApplicationContext([ASAMessageKeyType:  ASAMessageKeyRequestUserData])
//                debugPrint("\(#file) \(#function) Sent request for an update.")
            } catch {
                debugPrint("\(#file) \(#function) An error occurred when sending the request for an update!")
            }
        } else {
//            debugPrint(#file, #function, "WCsession is not supported")
        }
    } // func requestUserData()
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
//        debugPrint(#file, #function)
        
        if WCSession.isSupported() {
            if session == nil {
                session = WCSession.default
                session?.delegate = self
                session?.activate()
            }
        }

        self.requestUserData()
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        self.requestUserData()
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    fileprivate func handleMessage(_ message: [String : Any]) {
        //        debugPrint(#file, #function, message)
        
        if (message[ASAMessageKeyType] as! String) == ASAMessageKeyUpdateUserData {
            for key in ASAClockArrayKey.complicationSections {
                let value = message[key.rawValue]
                var clockArray = self.userData.locationsWithClocksArray(key: key).clocks
                if value != nil {
                    let valueAsArray = value! as! Array<Dictionary<String, Any>>
                    for i in 0..<key.minimumNumberOfClocks {
                        let newClock: ASAClock = ASAClock.new(dictionary: valueAsArray[i])
                        clockArray[i] = newClock
                    } // for i in 0..<key.minimumNumberOfClocks
                }
                userData.setClockArray(clockArray:  clockArray, key:  key)
            } // for
            ASAUserData.shared.savePreferences(code: .clocks)
            ASAUserData.shared.savePreferences(code: .complications)

//            if complicationController.complication != nil {
//                CLKComplicationServer.sharedInstance().reloadTimeline(for: complicationController.complication!)
//                debugPrint(#file, #function, "Updated complication \(String(describing: complicationController.complication?.identifier))", complicationController.complication?.identifier as Any)
//            } else {
//                debugPrint(#file, #function, "Could not update complication!  Complication is nil!")
//            }
            //             TODO:  Figure out what went wrong
            
            let mainClocksTemp = message[ASAClockArrayKey.app.rawValue]
            if mainClocksTemp != nil {
                let tempAsArray = mainClocksTemp! as! Array<Dictionary<String, Any>>
                var mainClocks:  Array<ASAClock> = []
                for item in tempAsArray {
                    let itemAsClock = ASAClock.new(dictionary: item)
                    mainClocks.append(itemAsClock)
                }
                DispatchQueue.main.async {
                    ASAUserData.shared.mainClocks = mainClocks.byLocation
                    ASAUserData.shared.savePreferences(code: .clocks)
                }
            }
        }
    } // fileprivate func handleMessage(_ message: [String : Any])
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        var activationStateString:  String
//        switch activationState {
//        case .notActivated:
//            activationStateString = "notActivated"
//
//        case .inactive:
//            activationStateString = "inactive"
//
//        case .activated:
//            activationStateString = "activated"
//        @unknown default:
//            activationStateString = "unknownDefault"
//        } // switch
//        debugPrint("\(#file) \(#function) activation state:  \(activationStateString), error:  \(String(describing: error))")
        
//        debugPrint("\(#file) \(#function) Reachable:  \(session.isReachable ? "Yes" : "No")")
        
        requestUserData()
    } // func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //        debugPrint(#file, #function, message)
        
        self.handleMessage(message)
    } // func session(_ session: WCSession, didReceiveMessage message: [String : Any])

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        //        debugPrint(#file, #function, userInfo)

        self.handleMessage(userInfo)
    } // func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:])

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.handleMessage(applicationContext)
    } // func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any])
} // class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate
