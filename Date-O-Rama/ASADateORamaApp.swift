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

    @State private var showLocationsSheet     = false
    @State private var showAboutSheet         = false
    @State private var showComplicationsSheet = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TabView(selection: $userData.selectedTabIndex) {
                    ForEach(Array(zip(userData.mainClocks.indices, $userData.mainClocks)), id: \.1.id) { index, locationWithClocks in
                        let usesDeviceLocation = locationWithClocks.usesDeviceLocation.wrappedValue
                        let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "circle.fill")

                        ASALocationTab(
                            now: $now,
                            usingRealTime: $usingRealTime,
                            locationWithClocks: locationWithClocks
                        )
                        .environmentObject(userData)
                        .tag(index)
                        .tabItem { symbol }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .id(userData.mainClocksVersion)
                .navigationTitle("")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if appDelegate.session.isPaired {
                            Button {
                                showComplicationsSheet = true
                            } label: {
                                Image(systemName: "applewatch.watchface")
                            }
                        }
                        
                        Button {
                            showAboutSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                        }

                        Button {
                            showLocationsSheet = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                        
                    }
                }
                .fullScreenCover(isPresented: $showLocationsSheet) {
                    ASALocationsTab(
                        now: $now,
                        usingRealTime: $usingRealTime,
                        selectedTabIndex: $userData.selectedTabIndex,
                        showLocationsSheet: $showLocationsSheet
                    )
                    .environmentObject(userData)
                }
                .sheet(isPresented: $showAboutSheet) {
                    ASAAboutTab()
                }
                .sheet(isPresented: $showComplicationsSheet) {
                    ASAComplicationClocksTab(now: $now)
                        .environmentObject(userData)
                }
            }
            .onReceive(timer) { input in
                if usingRealTime {
                    self.now = Date()
                }
            }
        }
    }
}
