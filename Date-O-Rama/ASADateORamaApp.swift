//
//  ASADateORamaApp.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

@main
struct ASADateORamaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var userData = ASAModel.shared
    @State var now               = Date()
    @State var usingRealTime     = true
    @StateObject private var watchModel = WatchConnectivityModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if userData.shouldShowLocationTab {
                    ASAMainTabView(now: $now, usingRealTime: $usingRealTime)
                        .navigationBarTitleDisplayMode(.inline)
                        .environmentObject(userData)
                        .environmentObject(watchModel)
                } else {
                    ASAAllLocationsTab(
                        now: $now,
                        usingRealTime: $usingRealTime,
                        selectedTabIndex: $userData.selectedTabIndex,
                        isShowingLocationSheet: $userData.shouldShowLocationTab
                    )
                    .environmentObject(userData)
                    .environmentObject(watchModel)
                }
            }
            .preferredColorScheme(.dark)
            .onReceive(timer) { input in
                if usingRealTime {
                    self.now = Date()
                }
            }
        }
    }
}

