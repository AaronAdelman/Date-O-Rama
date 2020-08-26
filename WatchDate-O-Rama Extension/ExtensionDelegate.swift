//
//  ExtensionDelegate.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    var session:  WCSession?
    public var complicationController = ComplicationController()
    
        var locationManager = ASALocationManager.shared()
        let notificationCenter = NotificationCenter.default
        
        
        override init() {
            super.init()
//            notificationCenter.addObserver(self, selector: #selector(handle(notification:)), name: NSNotification.Name(rawValue: UPDATED_LOCATION), object: nil)
            notificationCenter.addObserver(forName: NSNotification.Name(rawValue: UPDATED_LOCATION), object: nil, queue: nil, using: {notification
                in
                if notification.name.rawValue == UPDATED_LOCATION {
                    // TODO:  Put in something to check if we need if something actually needs a refresh!
                    if self.complicationController.complication != nil {
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: self.complicationController.complication!)
                    }
                }
            })
        } // override init()
        
        deinit {
            notificationCenter.removeObserver(self)
    } // deinit
    
//    @objc func handle(notification:  Notification) -> Void {
//        if notification.name.rawValue == UPDATED_LOCATION {
//            // TODO:  Put in something to check if we need if something actually needs a refresh!
//            CLKComplicationServer.sharedInstance().reloadTimeline(for: complicationController.complication!)
//        }
//    } // func handle(notification:  Notification) -> Void
    
    
    public func requestComplicationData() {
        debugPrint(#file, #function)
        
        if WCSession.isSupported() {
            do {
                try session?.updateApplicationContext([ASAMessageKeyType:  ASAMessageKeyRequestUserData])
                print("\(#file) \(#function) Sent request for an update.")
            } catch {
                print("\(#file) \(#function) An error occurred when sending the request for an update!")
            }
        } else {
            debugPrint(#file, #function, "WCsession is not supported")
        }
    } // func requestComplicationData()
    
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        debugPrint(#file, #function)
        
        if WCSession.isSupported() {
            if session == nil {
                session = WCSession.default
                session?.delegate = self
                session?.activate()
            }
        }
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
        debugPrint(#file, #function, message)
        
        if (message[ASAMessageKeyType] as! String) == ASAMessageKeyUpdateUserData {
            for key in ASARowArrayKey.complicationSections() {
                let value = message[key.rawValue]
                if complicationController.complication != nil {
                    var rowArray = complicationController.userData.rowArray(for:  complicationController.complication!.family)
                    if value != nil {
                        let valueAsArray = value! as! Array<Dictionary<String, Any>>
                        for i in 0..<key.minimumNumberOfRows() {
                            let newRow: ASARow = ASARow.newRow(dictionary: valueAsArray[i])
                            rowArray?[i] = newRow
                        } // for i in 0..<key.minimumNumberOfRows()
                    }
//                    ASAUserData.shared().saveRowArray(rowArray: rowArray!, key: key)
                    ASAUserData.shared().savePreferences()
                }
            }
 

            if complicationController.complication != nil {
                CLKComplicationServer.sharedInstance().reloadTimeline(for: complicationController.complication!)
            }
            //             TODO:  Figure out what went wrong
            
            let mainRowsTemp = message[ASARowArrayKey.app.rawValue]
            if mainRowsTemp != nil {
                let tempAsArray = mainRowsTemp! as! Array<Dictionary<String, Any>>
                var mainRows:  Array<ASARow> = []
                for item in tempAsArray {
                    let itemAsRow = ASARow.newRow(dictionary: item)
                    mainRows.append(itemAsRow)
                }
                DispatchQueue.main.async {
                    ASAUserData.shared().mainRows = mainRows
//                    ASAUserData.shared().saveRowArray(rowArray: mainRows, key: .app)
                    ASAUserData.shared().savePreferences()
                }
            }
        }
    } // fileprivate func handleMessage(_ message: [String : Any])
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        var activationStateString:  String
        switch activationState {
        case .notActivated:
            activationStateString = "notActivated"
            
        case .inactive:
            activationStateString = "inactive"
            
        case .activated:
            activationStateString = "activated"
        @unknown default:
            activationStateString = "unknownDefault"
        } // switch
        print("\(#file) \(#function) activation state:  \(activationStateString), error:  \(String(describing: error))")
        
        print("\(#file) \(#function) Reachable:  \(session.isReachable ? "Yes" : "No")")
        
        requestComplicationData()
    } // func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint(#file, #function, message)
        
        self.handleMessage(message)
    } // func session(_ session: WCSession, didReceiveMessage message: [String : Any])
} // class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate
