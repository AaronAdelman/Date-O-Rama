//
//  ASALocationsTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASALocationsTab: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var selectedTabIndex: Int
    
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
            
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var isNavigationBarHidden: Bool = true
    
    @State var isShowingNewLocationView = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                HStack {
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            self.isShowingNewLocationView = true
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                            Text("New location")
                        })
                        
                        Divider()
                        
                        Group {
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress < $1.location.shortFormattedOneLineAddress})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.down")
                                Text("Sort locations by name ascending")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress > $1.location.shortFormattedOneLineAddress})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.up")
                                Text("Sort locations by name descending")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude < $1.location.location.coordinate.longitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.right")
                                Text("Sort locations west to east")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude > $1.location.location.coordinate.longitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.left")
                                Text("Sort locations east to west")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude < $1.location.location.coordinate.latitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.up")
                                Text("Sort locations south to north")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude > $1.location.location.coordinate.latitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Image(systemName: "arrow.down")
                                Text("Sort locations north to south")
                            })
                        }
                    } label: {
                        ASAMenuTitle(imageSystemName: "mappin", title: "Locations")
                    }
                    .sheet(isPresented: $isShowingNewLocationView, content: {
                        let locationManager: ASALocationManager = ASALocationManager.shared
                        let locationWithClocks = ASALocationWithClocks(location: locationManager.deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true, locationManager: locationManager)
                        ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: true).environmentObject(userData).environmentObject(userData).environmentObject(locationManager)
                    })
                    
                    Spacer()
                        .frame(minWidth: 0.0)

                    
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
                
                List {
//                    ASAMainClocksView(now: $now).environmentObject(userData)
                    
                    ForEach(Array(userData.mainClocks.enumerated()), id: \.element.id) { index, locationWithClocks in
                        let location = locationWithClocks.location
                        
                        Button(action: {
                            selectedTabIndex = index
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .fill(Color.secondary)
                                
                                HStack {
                                    Text(location.flag)
                                    Spacer()
                                    Text(location.formattedOneLineAddress)
                                        .font(.title2)
                                    Spacer()
                                    Text(location.abbreviatedTimeZoneString(for: now))
                                }
                                .foregroundStyle(Color.primary)
                                .padding()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onMove(perform: moveClock)
                }
                .listStyle(GroupedListStyle())
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing: EditButton())
                .onAppear {
                    self.isNavigationBarHidden = true
                }
            } // VStack
        }.navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            if usingRealTime {
                self.now = Date()
            }
        }
    } // var body
    
    private func moveClock(from source: IndexSet, to destination: Int) {
        userData.mainClocks.move(fromOffsets: source, toOffset: destination)
        userData.savePreferences(code: .clocks)
        userData.mainClocksVersion += 1 // 🔄 Force update
    }
} // struct ASALocationsTab


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClocksTab().environmentObject(ASAModel.shared)
//    }
//}
