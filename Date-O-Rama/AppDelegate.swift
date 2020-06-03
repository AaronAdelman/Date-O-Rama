//
//  AppDelegate.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    public let session = WCSession.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if WCSession.isSupported() {
            print("\(#file) \(#function) WCSession is supported.")
            session.delegate = self
            session.activate()
        } else {
            print("\(#file) \(#function) WCSession is not supported.")
        }
        return true
    }
    
    // MARK:-  UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    // MARK: -
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("\(#file) \(#function)")
        
        print("\(#file) \(#function) Paired:  \(session.isPaired ? "Yes" : "No")")
        print("\(#file) \(#function) WatchApp installed:  \(session.isWatchAppInstalled ? "Yes" : "No")")
        print("\(#file) \(#function) Complication installed:  \(session.isComplicationEnabled ? "Yes" : "No")")
        print("\(#file) \(#function) Reachable:  \(session.isReachable ? "Yes" : "No")")
        
        sendUserData(session)
    } //  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("\(#file) \(#function)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#file) \(#function)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#file) \(#function)")
        
        if session.isReachable && session.isPaired && session.isWatchAppInstalled && session.isComplicationEnabled {
            self.sendUserData(session)
        }
    } // func sessionWatchStateDidChange(_ session: WCSession)
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("\(#file) \(#function)")
        
        if session.isReachable && session.isPaired && session.isWatchAppInstalled && session.isComplicationEnabled {
            self.sendUserData(session)
        }
    } // func sessionReachabilityDidChange(_ session: WCSession)
    
    public func sendUserData(_ session: WCSession) {
        debugPrint(#file, #function)
        
        let modularLargeRowArray = ASAUserData.rowArray(key: ASARowArrayKey.modularLarge)
        
        var modularLargeTemp:  Array<Dictionary<String, Any>> = []
        for row in modularLargeRowArray {
            let dictionary = row.dictionary()
            modularLargeTemp.append(dictionary)
        }
        
        var mainRowsTemp:  Array<Dictionary<String, Any>> = []
        for row in ASAUserData.shared().mainRows {
            let dictionary = row.dictionary()
            mainRowsTemp.append(dictionary)
        }
        
        
        let updateMessage = [
            ASAMessageKeyType:  ASAMessageKeyUpdateUserData,
            ASARowArrayKey.modularLarge.rawValue:  modularLargeTemp,
            ASARowArrayKey.app.rawValue:  mainRowsTemp
            ] as [String : Any]
        
        session.sendMessage(updateMessage, replyHandler: nil, errorHandler: nil)
    } // func sendUserData(_ session: WCSession)
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugPrint(#file, #function, applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint(#file, #function, message)
        
        if message[ASAMessageKeyType] as! String == ASAMessageKeyRequestUserData {
            sendUserData(session)
        }
    } // func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    
} // class AppDelegate

