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

    var body: some Scene {
        WindowGroup {
            TabView {
                ForEach($userData.mainClocks) {
                    locationWithClocks
                    in
                    let usesDeviceLocation: Bool = locationWithClocks.usesDeviceLocation.wrappedValue
                    let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "mappin")
                    
                    ASALocationTab(now: $now, usingRealTime: $usingRealTime, locationWithClocks: locationWithClocks).environmentObject(userData)
                        .tabItem {
                            symbol
                        }
                } // ForEach($userData.mainClocks)
                
                ASAClocksTab(now: $now, usingRealTime: $usingRealTime).environmentObject(userData)
                    .tabItem {
//                        Image(systemName: "globe")
//                        Text("CLOCKS_TAB")
                        Image(systemName: "list.bullet")
                    }
                
                                
                if self.appDelegate.session.isPaired {
                    ASAComplicationClocksTab().environmentObject(userData)
                        .tabItem {
                            Image(systemName: "applewatch.watchface")
//                            Text("COMPLICATION_CLOCKS_TAB")
                        }
                }
                
                ASAAboutTab()
                    .tabItem {
                        Image(systemName: "info.circle.fill")
//                        Text("ABOUT_TAB")
                    }
            } // TabView
        }
    }
}
