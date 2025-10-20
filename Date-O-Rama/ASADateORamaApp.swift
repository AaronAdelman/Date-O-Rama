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
    
    // Add state for reverse animation (tab shrinking to list)
    @State private var animatingToLocationsList = false
    @State private var showLocationsOverlay = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var selectedCalendar = Calendar(identifier: .gregorian)
    
    let availableCalendars: [ASACalendarCode] = [
        .Gregorian,
        .Buddhist,
        .Chinese,
        .Coptic,
        .EthiopicAmeteAlem,
        .EthiopicAmeteMihret,
        .Hebrew,
        .Indian,
        .Islamic,
        .IslamicCivil,
        .IslamicTabular,
        .IslamicUmmAlQura,
        .Japanese,
        .Persian,
        .RepublicOfChina,
        .bangla,
        .dangi,
        .gujarati,
        .kannada,
        .malayalam,
        .marathi,
        .odia,
        .tamil,
//        .telugu,
        .vietnamese,
//        .vikram,
    ]
    // TODO:  Selecting the Telugu and Vikram calendars causes a crash due to some sort of range error.  Why?
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    // Main content
                    VStack(spacing: 0.0) {
                        if !usingRealTime {
                            HStack {
                                Spacer()
                                
                                DatePicker(
                                    selection: $now,
                                    in: Date.distantPast...Date.distantFuture,
                                    displayedComponents: [.date, .hourAndMinute]
                                ) {
                                    Text("")
                                }
                                .environment(\.calendar, selectedCalendar)
                                .datePickerStyle(.compact)
                                
                                Menu {
                                    ForEach(availableCalendars, id: \.self) { calendarInfo in
                                        Button {
                                            selectedCalendar = Calendar(identifier: calendarInfo.equivalentCalendarIdentifier!)
                                        } label: {
                                            Label(
                                                NSLocalizedString(calendarInfo.localizedName, comment: ""), systemImage:
                                                    selectedCalendar.identifier == calendarInfo.equivalentCalendarIdentifier ? "checkmark" : "")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "calendar")
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        
                        TabView(selection: $userData.selectedTabIndex) {
                            ForEach(Array(zip(userData.mainClocks.indices, $userData.mainClocks)), id: \.1.id) { index, locationWithClocks in
                                let usesDeviceLocation = locationWithClocks.usesDeviceLocation.wrappedValue
                                let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "circle.fill")
                                
                                ASALocationTab(
                                    now: $now,
                                    usingRealTime: $usingRealTime,
                                    locationWithClocks: locationWithClocks,
                                    isAnimatingToList: animatingToLocationsList && userData.selectedTabIndex == index
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
                            if !showLocationsOverlay {
                                ToolbarItemGroup(placement: .topBarLeading) {
                                    Button {
                                        // Start the shrinking animation
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            animatingToLocationsList = true
                                        }
                                        
                                        // Show locations overlay after animation starts
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLocationsOverlay = true
                                            }
                                            animatingToLocationsList = false
                                        }
                                    } label: {
                                        Image(systemName: "list.bullet")
                                    }
                                    
                                    // Dynamic menu for time control
                                    let NOW_NAME  = "arrow.trianglehead.clockwise"
                                    let DATE_NAME = "calendar"
                                    
                                    Menu {
                                        Button {
                                            usingRealTime = true
                                        } label: {
                                            Label("Now", systemImage: NOW_NAME)
                                            if usingRealTime {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        
                                        Button {
                                            usingRealTime = false
                                            now = Date()
                                        } label: {
                                            Label("Date:", systemImage: DATE_NAME)
                                            if !usingRealTime {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        Button(action: {
                                            usingRealTime = false
                                            now = now.oneDayBefore
                                        }) {
                                            Label("Previous day", systemImage: "chevron.backward")
                                        }
                                        
                                        Button(action: {
                                            usingRealTime = false
                                            now = now.oneDayAfter
                                        }) {
                                            Label("Next day", systemImage: "chevron.forward")
                                        }
                                    } label: {
                                        Image(systemName: usingRealTime ? NOW_NAME : DATE_NAME)
                                    }
                                    
                                    Button {
                                        showAboutSheet = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                    }
                                    
                                    if appDelegate.session.isPaired {
                                        Button {
                                            showComplicationsSheet = true
                                        } label: {
                                            Image(systemName: "applewatch.watchface")
                                        }
                                    }
                                }
                            }
                        } // toolbar
                        .sheet(isPresented: $showAboutSheet) {
                            ASAAboutTab()
                        }
                        .sheet(isPresented: $showComplicationsSheet) {
                            ASAComplicationClocksTab(now: $now)
                                .environmentObject(userData)
                        }
                    } // VStack
                    .opacity(showLocationsOverlay ? 0.0 : 1.0)
                    .scaleEffect(showLocationsOverlay ? 0.95 : 1.0)
                    
                    // Locations overlay
                    if showLocationsOverlay {
                        ASALocationsTab(
                            now: $now,
                            usingRealTime: $usingRealTime,
                            selectedTabIndex: $userData.selectedTabIndex,
                            showLocationsSheet: .constant(true), // Always true since it's shown as overlay
                            currentlySelectedLocationIndex: userData.selectedTabIndex,
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLocationsOverlay = false
                                }
                            }
                        )
                        .environmentObject(userData)
                        .opacity(showLocationsOverlay ? 1.0 : 0.0)
                        .scaleEffect(showLocationsOverlay ? 1.0 : 1.05)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.05).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                } // ZStack
            } // NavigationStack
            .onReceive(timer) { input in
                if usingRealTime {
                    self.now = Date()
                }
            }
        } // WindowGroup
    } // var body
} // struct ASADateORamaApp
