//
//  ASAClocksTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation


struct ASAClocksTab: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()
    @State var usingRealTime = true
            
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var isNavigationBarHidden: Bool = true
    
    @State var isShowingNewLocationView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                HStack {
                    Spacer()
                    
                    Menu {
                        Text("Locations")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            self.isShowingNewLocationView = true
                        }, label: {
                            Text("New location")
                        })
                        
                        Group {
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress < $1.location.shortFormattedOneLineAddress})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations by name ascending")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress > $1.location.shortFormattedOneLineAddress})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations by name descending")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude < $1.location.location.coordinate.longitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations west to east")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude > $1.location.location.coordinate.longitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations east to west")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude < $1.location.location.coordinate.latitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations south to north")
                            })
                            
                            Button(action: {
                                userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude > $1.location.location.coordinate.latitude})
                                userData.savePreferences(code: .clocks)
                            }, label: {
                                Text("Sort locations north to south")
                            })
                        }
                        
                        Divider()
                        
                        Text("Clocks")
                            .foregroundColor(.secondary)
                        
                        let JulianDateCalendarCodes: Array<ASACalendarCode> = [
                            .CCSDSJulianDay,
                            .CNESJulianDay,
                            .DublinJulianDay,
                            .JulianDay,
                            .LilianDate,
                            .MarsSolDate,
                            .ModifiedJulianDay,
                            .RataDie,
                            .ReducedJulianDay,
                            .TruncatedJulianDay,
                        ].sorted(by: {$0.localizedName < $1.localizedName})
                        Menu(content: {
                            ForEach(JulianDateCalendarCodes, id: \.rawValue) {
                                code
                                in
                                
                                Button(action: {
                                    let location = code == .MarsSolDate ? ASALocation.MarsUniversal : .EarthUniversal
                                    let clock = ASAClock()
                                    clock.calendar = ASACalendarFactory.calendar(code: code)!
                                    ASAUserData.shared.addMainClock(clock: clock, location: location)
                                }, label: {
                                    Text(code.localizedName)
                                })
                            }
                        }, label: {
                            Text("Add clock for Julian date calendar")
                        })

                        EditButton()
                    } label: {
                        Image(systemName: "gear")
                            .symbolRenderingMode(.multicolor)
                        Text("Settings")
                    }
                    .sheet(isPresented: $isShowingNewLocationView, content: {
                        let locationWithClocks = ASALocationWithClocks(location: ASALocationManager.shared.deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true)
                        ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: true)
                    })
                    
                    Spacer()
                    
                    Rectangle().frame(minWidth: 1.0, idealWidth: 1.0, maxWidth: 1.0, maxHeight: 32.0)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
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
                        }
                    } // HStack
                    
                    Spacer()
                } // HStack
                .border(Color.gray)
                .zIndex(1.0) // This line from https://stackoverflow.com/questions/63934037/swiftui-navigationlink-cell-in-a-form-stays-highlighted-after-detail-pop to get rid of unwanted highlighting.
                
                List {
                    ASAMainClocksView(mainClocks: $userData.mainClocks, now: $now)
                }
                .listStyle(GroupedListStyle())
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
//                .navigationBarBackButtonHidden(true)
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
} // struct ASAClocksTab


struct ASARadioButtonLabel: View {
    var on: Bool
    var onColor: Color
    var text: String?
    
    var body: some View {
        HStack {            
            if on {
                Image(systemName: "largecircle.fill.circle")
                    .imageScale(.large)
                    .foregroundColor(onColor)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large)
            }
            
            if text != nil {
                Text(NSLocalizedString(text!, comment: ""))
                    .modifier(ASAScalable(lineLimit: 1))
            }
        } // HStack
    } // var body
} // struct ASARadioButtonLabel


struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksTab().environmentObject(ASAUserData.shared)
    }
}
