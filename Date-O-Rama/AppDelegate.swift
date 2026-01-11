//
//  AppDelegate.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import UIKit
import WatchConnectivity

final class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, ObservableObject, Sendable {
    @MainActor static let shared = AppDelegate()

    public let session = WCSession.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = ASALocationManager.shared

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Nothing to clean up
    }

    // MARK: - WCSessionDelegate

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let activationStateString = {
            switch activationState {
            case .notActivated:
                return "not activated"
            case .inactive:
                return "inactive"
            case .activated:
                return "activated"
            @unknown default:
                return "unknown activation state"
            }
        }()
        debugPrint(#file, #function, activationStateString, error as Any, "isReachable:", session.isReachable, "isPaired:", session.isPaired, "isWatchAppInstalled:", session.isWatchAppInstalled)
        sendUserData(session)
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Optionally handle
        debugPrint(#file, #function)
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Optionally handle
        debugPrint(#file, #function)
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        debugPrint(#file, #function, session.isReachable, session.isPaired, session.isWatchAppInstalled)
        if session.isReachable && session.isPaired && session.isWatchAppInstalled {
            sendUserData(session)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        debugPrint(#file, #function, session.isReachable, session.isPaired, session.isWatchAppInstalled)
        if session.isReachable && session.isPaired && session.isWatchAppInstalled {
            sendUserData(session)
        }
    }

    public nonisolated func sendUserData(_ session: WCSession) {
        debugPrint(#file, #function)

        Task { @MainActor in
            let model = ASAModel.shared

            let threeLineLargeTemp = model.locationsWithClocksArrayDictionary(key: .threeLineLarge, forComplication: true)
            let twoLineLargeTemp   = model.locationsWithClocksArrayDictionary(key: .twoLineLarge, forComplication: true)
            let twoLineSmallTemp   = model.locationsWithClocksArrayDictionary(key: .twoLineSmall, forComplication: true)
            let oneLineLargeTemp   = model.locationsWithClocksArrayDictionary(key: .oneLineLarge, forComplication: true)
            let oneLineSmallTemp   = model.locationsWithClocksArrayDictionary(key: .oneLineSmall, forComplication: true)
            let mainClocksTemp     = model.locationsWithClocksArrayDictionary(key: .app, forComplication: false)

            let updateMessage = [
                ASAMessageKeyType:  ASAMessageKeyUpdateUserData,
                ASAClockArrayKey.threeLineLarge.rawValue:  threeLineLargeTemp,
                ASAClockArrayKey.twoLineLarge.rawValue:    twoLineLargeTemp,
                ASAClockArrayKey.twoLineSmall.rawValue:    twoLineSmallTemp,
                ASAClockArrayKey.oneLineLarge.rawValue:    oneLineLargeTemp,
                ASAClockArrayKey.oneLineSmall.rawValue:    oneLineSmallTemp,
                ASAClockArrayKey.app.rawValue:             mainClocksTemp
            ]

            do {
                try self.session.updateApplicationContext(updateMessage)
            } catch {
                debugPrint(#file, #function, error)
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        debugPrint(#file, #function, applicationContext)
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint(#file, #function, message)
        
        if message[ASAMessageKeyType] as? String == ASAMessageKeyRequestUserData {
            sendUserData(session)
        }
    }
}
