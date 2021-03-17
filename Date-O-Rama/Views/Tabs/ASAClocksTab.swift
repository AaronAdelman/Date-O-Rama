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

    @State private var showingNewClockDetailView = false

    @AppStorage("mainRowsGroupingOption") var primaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName
    @AppStorage("secondaryMainRowsGroupingOption") var secondaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byFormattedDate
//    @AppStorage("showTimeToNextDay") var shouldShowTimeToNextDay = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var isNavBarHidden:  Bool = true

    @State private var showingPreferences:  Bool = false

    fileprivate func datePickerOpacity() -> Double {
        #if targetEnvironment(macCatalyst)
        return self.usingRealTime ? 0.25 : 1.0
        #else
            return 1.0
        #endif
    } // func datePickerOpacity() -> Double
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    let offColor = Color.gray
                    
                    Spacer()
                    
                    Button(action: {
                        self.usingRealTime = true
                    }, label: {
                        HStack {
                            let on = self.usingRealTime
                            let color: Color = on ? .green : offColor
                            ASARadioButtonSymbol(on: on, color: color)
                            Text("Now")
                                .modifier(ASAScalable(lineLimit: 1))
                        } // HStack
                    })
                    
                    Spacer()
                        .frame(minWidth: 0.0)
                    
                    HStack {
                        Button(action: {
                            self.usingRealTime = false
                        }, label: {
                            HStack {
                                let on: Bool = !self.usingRealTime
                                let color: Color = on ? .yellow : offColor
                                ASARadioButtonSymbol(on: on, color: color)
                                Text("Date:")
                                    .modifier(ASAScalable(lineLimit: 1))
                            } // HStack
                        })
                        Spacer()
                            .frame(maxWidth:0.0)
                        DatePicker(selection:  self.$now, in:  Date.distantPast...Date.distantFuture, displayedComponents: [.date, .hourAndMinute]) {
                            Text("")
                        }
                        .opacity(datePickerOpacity())
                        .disabled(self.usingRealTime)
                    } // HStack
                    
                    Spacer()
                } // HStack
                .border(Color.gray)
                
                List {
                    DisclosureGroup("Show clock preferences", isExpanded: $showingPreferences) {
                        NavigationLink(destination:  ASAArrangementChooserView(selectedGroupingOption:  self.$primaryMainRowsGroupingOption, groupingOptions: ASAClocksViewGroupingOption.primaryOptions, otherGroupingOption: self.$secondaryMainRowsGroupingOption, otherGroupingOptionIsSecondary: true)) {
                            HStack {
                                Text("Arrangement")
                                Spacer()
                                Text(self.primaryMainRowsGroupingOption.text())
                            }
                            .foregroundColor(.accentColor)
                        } // NavigationLink
                        
                        NavigationLink(destination:  ASAArrangementChooserView(selectedGroupingOption:  self.$secondaryMainRowsGroupingOption, groupingOptions: self.primaryMainRowsGroupingOption.compatibleOptions, otherGroupingOption: self.$primaryMainRowsGroupingOption, otherGroupingOptionIsSecondary: false)) {
                            HStack {
                                Text("Secondary arrangement")
                                Spacer()
                                Text(self.secondaryMainRowsGroupingOption.text())
                            }
                            .foregroundColor(.accentColor)
                        } // NavigationLink
                        
                        Button(
                            action: {
                                self.showingNewClockDetailView = true
                            }
                        ) {
                            Text("Add clock")
                        }
                        .foregroundColor(.accentColor)
                        
                        //                        Toggle("Show time to next day", isOn: $shouldShowTimeToNextDay)
                    } // DisclosureGroup
                    
                    switch self.primaryMainRowsGroupingOption {
                    case .byFormattedDate:
                        ASAMainRowsByFormattedDateView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, forComplications:  false)
                        
                    case .byCalendar:
                        ASAMainRowsByCalendarView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, forComplications:  false)
                        
                    case .byPlaceName, .byCountry:
                        ASAMainRowsByPlaceView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, forComplications:  false)
                        
                    case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
                        ASAMainRowsByTimeZoneView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, forComplications:  false)
                        
                    default:
                        EmptyView()
                    } // switch self.groupingOptions[self.groupingOptionIndex]
                }
                .sheet(isPresented: self.$showingNewClockDetailView) {
                    ASANewClockDetailView(now:  now)
                }
                .navigationBarHidden(self.isNavBarHidden)
                .onAppear {
                    self.isNavBarHidden = true
                }
                .onDisappear {
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


// MARK:  -

struct ASAConditionalEditButton:  View {
    var shouldShow:  Bool
    
    var body: some View {
        Group {
            
            if #available(macOS 11, iOS 14.0, tvOS 14.0, *) {
                if shouldShow {
                    EditButton()
                } else {
                    EmptyView()
                }
            } else {
                EditButton()
            }
        } // Group
    } //var body
} // struct ASAConditionalEditButton


struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksTab().environmentObject(ASAUserData.shared)
    }
}
