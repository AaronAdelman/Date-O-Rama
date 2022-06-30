//
//  ASAEventsTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import EventKit
import EventKitUI


struct ASAEventsTab: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var date = Date()
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var showingPreferences:  Bool = false
    @State private var showingEventCalendarChooserView = false
    
    var primaryClock: ASAClock {
        get {
            let result: ASAClock = ASAUserData.shared.row(uuidString: primaryClockUUIDString, backupIndex: 0)
            
            self.primaryClockUUIDString = result.uuid.uuidString
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            primaryClockUUIDString = newValue.uuid.uuidString
        } // set
    } // var primaryClock
    
    var secondaryClock: ASAClock {
        get {
            if self.userData.numberOfMainClocks < 2 {
                return ASAClock.generic
            }
            
            let result: ASAClock = ASAUserData.shared.row(uuidString: secondaryClockUUIDString, backupIndex: 1)
            
            self.secondaryClockUUIDString = result.uuid.uuidString
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            secondaryClockUUIDString = newValue.uuid.uuidString
        } // set
    } // var secondaryClock
    
    var shouldHideTimesInSecondaryRow:  Bool {
        get {
            let primaryClockStartOfDay = self.primaryClock.startOfDay(date: date)
            let primaryClockStartOfNextDay = self.primaryClock.startOfNextDay(date: date)
            let secondaryClockStartOfDay = self.secondaryClock.startOfDay(date: date)
            let secondaryClockStartOfNextDay = self.secondaryClock.startOfNextDay(date: date)
            
            let result: Bool = primaryClockStartOfDay == secondaryClockStartOfDay && primaryClockStartOfNextDay == secondaryClockStartOfNextDay
            //            debugPrint(#file, #function, "Primary row:", primaryClockStartOfDay, primaryClockStartOfNextDay, "Secondary row:", secondaryClockStartOfDay, secondaryClockStartOfNextDay)
            return result
        }
    }
    
    @AppStorage("SHOULD_SHOW_SECONDARY_DATES_KEY") var eventsViewShouldShowSecondaryDates: Bool = true
    
    @AppStorage("PRIMARY_ROW_UUID_KEY") var primaryClockUUIDString: String = UUID().uuidString
    @AppStorage("SECONDARY_ROW_UUID_KEY") var secondaryClockUUIDString: String = UUID().uuidString
    
    @State var isNavigationBarHidden:  Bool = true
    
    fileprivate func enoughClocksToShowSecondaryDates() -> Bool {
        return self.userData.numberOfMainClocks > 1
    }
    
    let SECONDARY_ROW_FONT_SIZE:  CGFloat = 22.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                ASADatePicker(date: $date, primaryClock: self.primaryClock)
                
                List {
                    Section {
                        NavigationLink(destination:  ASAClocksChooser(selectedUUIDString:  $primaryClockUUIDString)) {
                            VStack(alignment:  .leading) {
                                Text(verbatim: primaryClock.dateString(now: date))
                                    .font(.title)
                                    .bold()
                                if primaryClock.calendar.supportsLocations ||  primaryClock.calendar.supportsTimeZones {
                                    HStack {
                                        if primaryClock.usesDeviceLocation {
                                            ASALocationSymbol()
                                        }
                                        Text(verbatim: primaryClock.countryCodeEmoji(date:  date))
                                        Text(verbatim:  primaryClock.locationData.formattedOneLineAddress)
                                    }
                                }
                            }
                        }
                        
                        if eventsViewShouldShowSecondaryDates && self.enoughClocksToShowSecondaryDates() {
                            NavigationLink(destination:  ASAClocksChooser(selectedUUIDString:  $secondaryClockUUIDString)) {
                                VStack(alignment:  .leading) {
                                    if self.shouldHideTimesInSecondaryRow {
                                        Text(verbatim: secondaryClock.dateString(now: date)).font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                    } else {
                                        Text(verbatim: "\(secondaryClock.dateTimeString(now: primaryClock.startOfDay(date: date)))\(NSLocalizedString("INTERVAL_SEPARATOR", comment: ""))\(secondaryClock.dateTimeString(now: primaryClock.startOfNextDay(date: date)))").font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                    }
                                    if secondaryClock.calendar.supportsLocations ||  secondaryClock.calendar.supportsTimeZones {
                                        HStack {
                                            if secondaryClock.usesDeviceLocation {
                                                ASALocationSymbol()
                                            }
                                            Text(verbatim: secondaryClock.countryCodeEmoji(date:  date))
                                            Text(verbatim: secondaryClock.locationData.formattedOneLineAddress)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if ASAEKEventManager.shared.shouldUseEKEvents {
                            ASANewExternalEventButton(now: self.date)
                        }
                        
                        DisclosureGroup("Show event preferences", isExpanded: $showingPreferences) {
                            Button(action: {
                                let tempClockUUIDString = self.primaryClockUUIDString
                                self.primaryClockUUIDString = self.secondaryClockUUIDString
                                self.secondaryClockUUIDString = tempClockUUIDString
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.swap")
                                    Text("Swap clocks")
                                }
                            }
                            .foregroundColor(.accentColor)
                            
                            if self.enoughClocksToShowSecondaryDates() {
                                Toggle(isOn: $eventsViewShouldShowSecondaryDates) {
                                    Text("Show secondary dates")
                                }
                            }
                            
                            if !ASAEKEventManager.shared.userHasPermission {
                                Text("NO_EXTERNAL_EVENTS_PERMISSION").foregroundColor(.gray)
                            }
                        } // if showingPreferences
                    } // Section
                    
                    let rangeStart = self.primaryClock.startOfDay(date: date)
                    let rangeEnd = self.primaryClock.startOfNextDay(date: date)
                    Section {
                        ForEach(ASAUserData.shared.mainClocksEvents(startDate: rangeStart, endDate: rangeEnd), id: \.eventIdentifier) {
                            event
                            in
                            
                            let eventIsTodayOnly = event.isOnlyForRange(rangeStart: rangeStart, rangeEnd: rangeEnd)
                            let (startDateString, endDateString) = self.primaryClock.startAndEndDateStrings(event: event, isPrimaryClock: true, eventIsTodayOnly: eventIsTodayOnly)
                            
                            ASALinkedEventCell(event: event, primaryClock: self.primaryClock, secondaryClock: self.secondaryClock, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, now: $date, rangeStart: rangeStart, rangeEnd: rangeEnd, isForClock: false, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString:  endDateString)
                                .listRowInsets(.zero)
                        } // ForEach
                    } // Section
                } // List
                Spacer()
            } // VStack
            .navigationBarHidden(self.isNavigationBarHidden)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                self.isNavigationBarHidden = true
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAEventsTab


// MARK: -

struct ASAEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventsTab()
    }
} // struct ASAEventsView_Previews
