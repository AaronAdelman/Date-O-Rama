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
    
    var primaryRow:  ASARow {
        get {
            let result: ASARow = ASAUserData.shared.row(uuidString: primaryRowUUIDString, backupIndex: 0)
            
            self.primaryRowUUIDString = result.uuid.uuidString
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            primaryRowUUIDString = newValue.uuid.uuidString
        } // set
    } // var primaryRow:  ASARow
    
    var secondaryRow:  ASARow {
        get {
            if self.userData.mainRows.count < 2 {
                return ASARow.generic
            }
            
            let result: ASARow = ASAUserData.shared.row(uuidString: secondaryRowUUIDString, backupIndex: 1)
            
            self.secondaryRowUUIDString = result.uuid.uuidString
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            secondaryRowUUIDString = newValue.uuid.uuidString
        } // set
    } // var secondaryRow

    var shouldHideTimesInSecondaryRow:  Bool {
        get {
            let primaryRowStartOfDay = self.primaryRow.startOfDay(date: date)
            let primaryRowStartOfNextDay = self.primaryRow.startOfNextDay(date: date)
            let secondaryRowStartOfDay = self.secondaryRow.startOfDay(date: date)
            let secondaryRowStartOfNextDay = self.secondaryRow.startOfNextDay(date: date)

            let result: Bool = primaryRowStartOfDay == secondaryRowStartOfDay && primaryRowStartOfNextDay == secondaryRowStartOfNextDay
            //            debugPrint(#file, #function, "Primary row:", primaryRowStartOfDay, primaryRowStartOfNextDay, "Secondary row:", secondaryRowStartOfDay, secondaryRowStartOfNextDay)
            return result
        }
    }

    @AppStorage("SHOULD_SHOW_SECONDARY_DATES_KEY") var eventsViewShouldShowSecondaryDates: Bool = true

    @AppStorage("PRIMARY_ROW_UUID_KEY") var primaryRowUUIDString: String = UUID().uuidString
    @AppStorage("SECONDARY_ROW_UUID_KEY") var secondaryRowUUIDString: String = UUID().uuidString

    @State var isNavigationBarHidden:  Bool = true
    
    fileprivate func enoughRowsToShowSecondaryDates() -> Bool {
        return self.userData.mainRows.count > 1
    }

    let SECONDARY_ROW_FONT_SIZE:  CGFloat = 22.0

    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                ASADatePicker(date: $date, primaryRow: self.primaryRow)

                List {
                    Section {
                        NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $primaryRowUUIDString)) {
                            VStack(alignment:  .leading) {
                                Text(verbatim: primaryRow.dateString(now: date))
                                    .font(.title)
                                    .bold()
                                if primaryRow.calendar.supportsLocations ||  primaryRow.calendar.supportsTimeZones {
                                    HStack {
                                        if primaryRow.usesDeviceLocation {
                                            ASALocationSymbol()
                                        }
                                        Text(verbatim: primaryRow.countryCodeEmoji(date:  date))
                                        Text(verbatim:  primaryRow.locationData.formattedOneLineAddress)
                                    }
                                }
                            }
                        }

                        if eventsViewShouldShowSecondaryDates && self.enoughRowsToShowSecondaryDates() {
                            NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $secondaryRowUUIDString)) {
                                VStack(alignment:  .leading) {
                                    if self.shouldHideTimesInSecondaryRow {
                                        Text(verbatim: secondaryRow.dateString(now: date)).font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                    } else {
                                        Text(verbatim: "\(secondaryRow.dateTimeString(now: primaryRow.startOfDay(date: date)))\(NSLocalizedString("INTERVAL_SEPARATOR", comment: ""))\(secondaryRow.dateTimeString(now: primaryRow.startOfNextDay(date: date)))").font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                    }
                                    if secondaryRow.calendar.supportsLocations ||  secondaryRow.calendar.supportsTimeZones {
                                        HStack {
                                            if secondaryRow.usesDeviceLocation {
                                                ASALocationSymbol()
                                            }
                                            Text(verbatim: secondaryRow.countryCodeEmoji(date:  date))
                                            Text(verbatim: secondaryRow.locationData.formattedOneLineAddress)
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
                                let tempRowUUIDString = self.primaryRowUUIDString
                                self.primaryRowUUIDString = self.secondaryRowUUIDString
                                self.secondaryRowUUIDString = tempRowUUIDString
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.swap")
                                    Text("Swap clocks")
                                }
                            }
                            .foregroundColor(.accentColor)
                            
                            if self.enoughRowsToShowSecondaryDates() {
                                Toggle(isOn: $eventsViewShouldShowSecondaryDates) {
                                    Text("Show secondary dates")
                                }
                            }

                            if !ASAEKEventManager.shared.userHasPermission {
                                Text("NO_EXTERNAL_EVENTS_PERMISSION").foregroundColor(.gray)
                            }
                        } // if showingPreferences
                    } // Section

                    let rangeStart = self.primaryRow.startOfDay(date: date)
                    let rangeEnd = self.primaryRow.startOfNextDay(date: date)
                    Section {
                        ForEach(ASAUserData.shared.events(startDate: rangeStart, endDate: rangeEnd, row: self.primaryRow), id: \.eventIdentifier) {
                            event
                            in
                            ASALinkedEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, now: $date, rangeStart: rangeStart, rangeEnd: rangeEnd, isForClock: false)
                                .listRowInsets(.zero)
                        } // ForEach
                    } // Section
                } // List

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
