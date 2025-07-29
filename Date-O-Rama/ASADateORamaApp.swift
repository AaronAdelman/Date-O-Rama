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
    
    @State private var showLocationsSheet = false
    @State private var showAboutSheet     = false
        
    var body: some Scene {
        WindowGroup {
            ZStack {
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
                    
                    if appDelegate.session.isPaired {
                        ASAComplicationClocksTab()
                            .environmentObject(userData)
                            .tag(userData.mainClocks.count)
                            .tabItem { Image(systemName: "applewatch.watchface") }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .id(userData.mainClocksVersion)
                
                // Overlay buttons
                VStack {
                    Spacer()
                    HStack {
                        let BUTTON_STYLE: BorderedProminentButtonStyle = .borderedProminent
                        let BUTTON_FONT: Font            = .title2
                        let BUTTON_SHAPE: ButtonBorderShape = .capsule
                        let BUTTON_TINT = Color(white: 0.95)
                        let BUTTON_IMAGE_COLOR = Color.gray

                        Button {
                            showAboutSheet = true
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(BUTTON_FONT)
                                .foregroundStyle(BUTTON_IMAGE_COLOR)
                                .padding()
                        }
                        .buttonStyle(BUTTON_STYLE)
                        .buttonBorderShape(BUTTON_SHAPE)
                        .tint(BUTTON_TINT)
                        
                        Spacer()
                        
                        Button {
                            showLocationsSheet = true
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(BUTTON_FONT)
                                .foregroundStyle(BUTTON_IMAGE_COLOR)
                                .padding()
                        }
                        .buttonStyle(BUTTON_STYLE)
                        .buttonBorderShape(BUTTON_SHAPE)
                        .tint(BUTTON_TINT)
                    }
                    .frame(height: 24.0)
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
        }
    }
}
