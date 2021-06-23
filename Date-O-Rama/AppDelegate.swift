//
//  AppDelegate.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import UIKit
import WatchConnectivity


class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, ObservableObject {
    static let shared = AppDelegate()
    
    public let session = WCSession.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        _ = ASALocationManager.shared
        
        if WCSession.isSupported() {
            debugPrint("\(#file) \(#function) WCSession is supported.")
            session.delegate = self
            session.activate()
        } else {
            debugPrint("\(#file) \(#function) WCSession is not supported.")
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
        debugPrint("\(#file) \(#function)")
        
        debugPrint("\(#file) \(#function) Paired:  \(session.isPaired ? "Yes" : "No")")
        debugPrint("\(#file) \(#function) WatchApp installed:  \(session.isWatchAppInstalled ? "Yes" : "No")")
        debugPrint("\(#file) \(#function) Complication installed:  \(session.isComplicationEnabled ? "Yes" : "No")")
        debugPrint("\(#file) \(#function) Reachable:  \(session.isReachable ? "Yes" : "No")")
        debugPrint("\(#file) \(#function) Error:  \(String(describing: error))")
        
        sendUserData(session)
    } //  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("\(#file) \(#function)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("\(#file) \(#function)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        debugPrint("\(#file) \(#function)")
        
        if session.isReachable && session.isPaired && session.isWatchAppInstalled
//            && session.isComplicationEnabled
        {
            self.sendUserData(session)
        }
    } // func sessionWatchStateDidChange(_ session: WCSession)
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        debugPrint("\(#file) \(#function)")
        
        if session.isReachable && session.isPaired && session.isWatchAppInstalled
//            && session.isComplicationEnabled
        {
            self.sendUserData(session)
        }
    } // func sessionReachabilityDidChange(_ session: WCSession)
    
    func rowArrayDictionary(key:  ASARowArrayKey, forComplication:  Bool) -> Array<Dictionary<String, Any>> {
        let rowArray = ASAUserData.shared.rowArray(key: key)
        
        var temp:  Array<Dictionary<String, Any>> = []
        for row in rowArray {
            let dictionary = row.dictionary(forComplication: forComplication)
            temp.append(dictionary)
        }
        
        return temp
    } // func rowArrayDictionary(key:  ASARowArrayKey) -> Array<Dictionary<String, Any>>
    
    public func sendUserData(_ session: WCSession) {
        debugPrint(#file, #function)
                
        let threeLineLargeTemp = self.rowArrayDictionary(key: .threeLineLarge, forComplication: true)
        let twoLineLargeTemp   = self.rowArrayDictionary(key: .twoLineLarge, forComplication: true)
        let twoLineSmallTemp   = self.rowArrayDictionary(key: .twoLineSmall, forComplication: true)
        let oneLineLargeTemp   = self.rowArrayDictionary(key: .oneLineLarge, forComplication: true)
        let oneLineSmallTemp   = self.rowArrayDictionary(key: .oneLineSmall, forComplication: true)
  
        let mainRowsTemp = self.rowArrayDictionary(key: .app, forComplication: false)

        let updateMessage = [
            ASAMessageKeyType:  ASAMessageKeyUpdateUserData,
            ASARowArrayKey.threeLineLarge.rawValue:  threeLineLargeTemp,
            ASARowArrayKey.twoLineLarge.rawValue:  twoLineLargeTemp,
            ASARowArrayKey.twoLineSmall.rawValue:  twoLineSmallTemp,
            ASARowArrayKey.oneLineLarge.rawValue:  oneLineLargeTemp,
            ASARowArrayKey.oneLineSmall.rawValue:  oneLineSmallTemp,
            ASARowArrayKey.app.rawValue:  mainRowsTemp
            ] as [String : Any]
        
//        session.sendMessage(updateMessage, replyHandler: nil, errorHandler: nil)
//        session.transferCurrentComplicationUserInfo(updateMessage)

        do {
            try self.session.updateApplicationContext(updateMessage)
        } catch {
            debugPrint(#file, #function, error)
        }
    } // func sendUserData(_ session: WCSession)
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugPrint(#file, #function, applicationContext)
//        self.sendUserData(session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint(#file, #function, message)
        
        if message[ASAMessageKeyType] as! String == ASAMessageKeyRequestUserData {
            sendUserData(session)
        }
    } // func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    
} // class AppDelegate

