//
//  ASAEventsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import EventKit
import EventKitUI


struct ASAEventsView: View {
    let ADD_EXTERNAL_EVENT_STRING = "Add external event"
    let FRAME_MIN_WIDTH:  CGFloat  = 300.0
    let FRAME_MIN_HEIGHT:  CGFloat = 500.0

    @ObservedObject var eventManager = ASAEKEventManager.shared
    @EnvironmentObject var userData:  ASAUserData
    @State var date = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingPreferences:  Bool = false
    @State private var showingEventCalendarChooserView = false
    
    var primaryRow:  ASARow {
        get {
            let result: ASARow = primaryRowUUIDString.row(backupIndex: 0)
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
            let result: ASARow = secondaryRowUUIDString.row(backupIndex: 1)
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
    
    var timeWidth:  CGFloat {
        get {
            if self.sizeClass! == .compact {
                return  90.00
            } else {
                return 120.00
            }
        } // get
    } // var timeWidth
    let TIME_FONT_SIZE = Font.subheadlineMonospacedDigit
    
    @State var isNavBarHidden:  Bool = false
    
    @State private var action:  EKEventEditViewAction?
    @State private var showingEventEditView = false
    
    fileprivate func enoughRowsToShowSecondaryDates() -> Bool {
        return self.userData.mainRows.count > 1
    }

    let SECONDARY_ROW_FONT_SIZE:  CGFloat = 22.0

    var body: some View {
        NavigationView {
            VStack {
                ASADatePicker(date: $date, primaryRow: self.primaryRow)

                List {
                    Section {
                        NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $primaryRowUUIDString)) {
                            VStack(alignment:  .leading) {
                                Text(verbatim: primaryRow.dateString(now: date)).font(.title).bold()
                                if primaryRow.calendar.supportsLocations ||  primaryRow.calendar.supportsTimeZones {
                                    HStack {
                                        if primaryRow.usesDeviceLocation {
                                            ASASmallLocationSymbol()
                                        }
                                        Text(verbatim: primaryRow.emoji(date:  date))
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
                                                ASASmallLocationSymbol()
                                            }
                                            Text(verbatim: secondaryRow.emoji(date:  date))
                                            Text(verbatim: secondaryRow.locationData.formattedOneLineAddress)
                                        }
                                    }
                                }
                            }
                        }

                        if ASAEKEventManager.shared.shouldUseEKEvents {
                            Button(action:
                                    {
                                        self.showingEventEditView = true
                                    }, label:  {
                                        Text(NSLocalizedString(ADD_EXTERNAL_EVENT_STRING, comment: ""))
                                    })
                                .popover(isPresented:  $showingEventEditView, arrowEdge: .top) {
                                    ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore)
                                        .frame(minWidth:  FRAME_MIN_WIDTH, minHeight:  FRAME_MIN_HEIGHT)
                                }
                                .foregroundColor(.accentColor)
                        }

                        DisclosureGroup("Show preferences", isExpanded: $showingPreferences) {
                            Button("Swap clocks") {
                                let tempRowUUIDString = self.primaryRowUUIDString
                                self.primaryRowUUIDString = self.secondaryRowUUIDString
                                self.secondaryRowUUIDString = tempRowUUIDString
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
                            ASALinkedEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, rangeStart: rangeStart, rangeEnd: rangeEnd)
                        } // ForEach
                    } // Section
                } // List

            } // VStack
            .navigationBarHidden(self.isNavBarHidden)
            .onAppear {
                self.isNavBarHidden = true
            }
            .onDisappear {
//                self.isNavBarHidden = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAEventsView


// MARK: -

struct ASAEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventsView()
    }
} // struct ASAEventsView_Previews
