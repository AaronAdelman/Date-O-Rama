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
            TabView(selection: $userData.selectedTabIndex) {
                ForEach(Array(zip(userData.mainClocks.indices, $userData.mainClocks)), id: \.1.id) { index, locationWithClocks in
                    let usesDeviceLocation = locationWithClocks.usesDeviceLocation.wrappedValue
                    let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "circle.fill")
                    
                    ASALocationTab(now: $now, usingRealTime: $usingRealTime, locationWithClocks: locationWithClocks)
                        .environmentObject(userData)
                        .tabItem { symbol }
                        .tag(index)
                }

                ASALocationsTab(now: $now, usingRealTime: $usingRealTime, selectedTabIndex: $userData.selectedTabIndex)
                    .environmentObject(userData)
                    .tabItem { Image(systemName: "list.bullet") }
                    .tag(userData.mainClocks.count)

                if appDelegate.session.isPaired {
                    ASAComplicationClocksTab().environmentObject(userData)
                        .tabItem { Image(systemName: "applewatch.watchface") }
                        .tag(userData.mainClocks.count + 1)
                }

                ASAAboutTab()
                    .tabItem { Image(systemName: "info.circle.fill") }
                    .tag(userData.mainClocks.count + 2)
            } // TabView
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .id(userData.mainClocksVersion) // 🔁 Trigger refresh when reordering
        } // WindowGroup
    } // body
}
