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
    
    @State private var selectedCalendar = Calendar(identifier: .gregorian)
    
    let availableCalendars: [(name: String, calendar: Calendar.Identifier)] = [
        ("gre", .gregorian),
        ("tha", .buddhist),
        ("chi", .chinese),
        ("cop", .coptic),
        ("EthiopicAmeteAlem", .ethiopicAmeteAlem),
        ("EthiopicAmeteMihret", .ethiopicAmeteMihret),
        ("Hebrew", .hebrew),
        ("ind", .indian),
        ("Islamic", .islamic),
        ("IslamicCivil", .islamicCivil),
        ("IslamicTabular", .islamicTabular),
        ("IslamicUmmAlQura", .islamicUmmAlQura),
        ("kok", .japanese),
        ("his", .persian),
        ("min", .republicOfChina)
    ]
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VStack(spacing: 0.0) {
                    if !usingRealTime {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                now = now.oneDayBefore
                            }) {
                                Image(systemName: "arrowtriangle.backward.fill")
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button(action: {
                                now = now.oneDayAfter
                            }) {
                                Image(systemName: "arrowtriangle.forward.fill")
                            }
                            .buttonStyle(.bordered)
                            
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
                                ForEach(availableCalendars, id: \.calendar) { calendarInfo in
                                    Button {
                                        selectedCalendar = Calendar(identifier: calendarInfo.calendar)
                                    } label: {
                                        Label(NSLocalizedString(calendarInfo.name, comment: ""), systemImage:
                                                selectedCalendar.identifier == calendarInfo.calendar ? "checkmark" : "")
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
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button {
                                showLocationsSheet = true
                            } label: {
                                Image(systemName: "list.bullet")
                            }

                            // 🔁 Dynamic menu for time control
                            let NOW_NAME  = "clock"
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
                } // VStack
            } // NavigationStack
            .onReceive(timer) { input in
                if usingRealTime {
                    self.now = Date()
                }
            }
        } // WindowGroup
    } // var body
} // struct ASADateORamaApp
