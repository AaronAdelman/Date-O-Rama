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
                    HStack {
                        Spacer()
                        
                        if UIDevice.current.userInterfaceIdiom != .phone {
                          Button (action: {
                                self.usingRealTime = false
                                now = now.oneDayBefore
                            }, label: {
                                Image(systemName: "arrowtriangle.backward.fill")
                                    .imageScale(.large)
                            })
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button (action: {
                                self.usingRealTime = false
                                now = now.oneDayAfter
                            }, label: {
                                Image(systemName: "arrowtriangle.forward.fill")
                                    .imageScale(.large)
                            })
                            .buttonStyle(.bordered)
                            
                            Spacer()
                        }

                        Button(action: {
                            self.usingRealTime = true
                        }, label: {
                            ASARadioButtonLabel(on: self.usingRealTime, onColor: .green, text: "Now")
                        })
                        
                        Spacer()
                            .frame(minWidth: 0.0)
                        
                        HStack {
                            Button(action: {
                                self.usingRealTime = false
                            }, label: {
                                let VERTICAL_PADDING: CGFloat = 7.0
                                ASARadioButtonLabel(on: !self.usingRealTime, onColor: .yellow, text: self.usingRealTime ? "Date:" : "")
                                    .padding(EdgeInsets(top: VERTICAL_PADDING, leading: 0.0, bottom: VERTICAL_PADDING, trailing: 0.0))
                            })
                            if !self.usingRealTime {
                                DatePicker(selection:  self.$now, in:  Date.distantPast...Date.distantFuture, displayedComponents: [.date, .hourAndMinute]) {
                                    Text("")
                                }
                                .environment(\.calendar, selectedCalendar)
                                .datePickerStyle(.compact)
                                
                                Menu {
                                    ForEach(availableCalendars, id: \.calendar) { calendarInfo in
                                        HStack {
                                            Button {
                                                selectedCalendar = Calendar(identifier: calendarInfo.calendar)
                                            } label: {
                                                Text(NSLocalizedString(calendarInfo.name, comment: ""))
                                                if selectedCalendar.identifier == calendarInfo.calendar {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        } // HStack
                                    } // ForEach
                                } label: {
                                    ASAMenuTitle(imageSystemName: "calendar")
                                }
                            }
                        } // HStack
                        
                        Spacer()
                    } // HStack
                    .border(Color.gray)
                    .zIndex(1.0) // This line from https://stackoverflow.com/questions/63934037/swiftui-navigationlink-cell-in-a-form-stays-highlighted-after-detail-pop to get rid of unwanted highlighting.
                    
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
