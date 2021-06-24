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
    
    @State var isNavigationBarHidden:  Bool = true
    
    @State private var showingPreferences:  Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                HStack {
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
                    
                    if ASAEKEventManager.shared.shouldUseEKEvents {
                        ASANewExternalEventButton(now: now)
                    }
                    
                    switch self.primaryMainRowsGroupingOption {
                    case .byFormattedDate:
                        ASAMainRowsByFormattedDateView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption)
                        
                    case .byCalendar:
                        ASAMainRowsByCalendarView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption)
                        
                    case .byPlaceName, .byCountry:
                        ASAMainRowsByPlaceView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now)
                        
                    case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
                        ASAMainRowsByTimeZoneView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now)
                        
                    default:
                        EmptyView()
                    } // switch self.groupingOptions[self.groupingOptionIndex]
                }
                .listStyle(SidebarListStyle())
                .sheet(isPresented: self.$showingNewClockDetailView) {
                    ASANewClockDetailView(now:  now)
                }
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
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
