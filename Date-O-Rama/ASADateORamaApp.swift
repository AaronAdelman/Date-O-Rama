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

    var body: some Scene {
        WindowGroup {
            let userData = ASAUserData.shared

            TabView {
                ASAClocksTab().environmentObject(userData)
                    .tabItem {
                        Image(systemName: "globe")
                        Text("CLOCKS_TAB")
                    }
                
//                ASAEventsTab().environmentObject(userData)
//                    .tabItem {
//                        Image(systemName: "rectangle.stack")
//                        Text("EVENTS_TAB")
//                    }
                
                if self.appDelegate.session.isPaired {
                    ASAComplicationClocksTab().environmentObject(userData)
                        .tabItem {
                            Image(systemName: "applewatch.watchface")
                            Text("COMPLICATION_CLOCKS_TAB")
                        }
                }
                
                ASAAboutTab()
                    .tabItem {
                        Image(systemName: "info.circle.fill")
                        Text("ABOUT_TAB")
                    }
            } // TabView
        }
    }
}
