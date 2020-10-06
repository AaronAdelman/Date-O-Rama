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


struct ASAIndentedText:  View {
    var title:  String

    var body: some View {
        HStack {
            Spacer().frame(width:  25.0)
            Text("•")
            Text(NSLocalizedString(title, comment: ""))
        }
    } // var body
} // struct ASAIndentedText


struct ASAEventsView: View {
    let ADD_EXTERNAL_EVENT_STRING = "Add external event"

    @ObservedObject var settings = ASAUserSettings()
    
    @ObservedObject var eventManager = ASAExternalEventManager.shared()
    @EnvironmentObject var userData:  ASAUserData
    @State var date = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State var showingPreferences:  Bool = false
    @State private var showingNewInternalEventCalendarDetailView = false
    
    var primaryRow:  ASARow {
        get {
            let result: ASARow = settings.primaryRowUUIDString.row(backupIndex: 0)
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            settings.primaryRowUUIDString = newValue.uuid.uuidString
        } // set
    } // var primaryRow:  ASARow
    var secondaryRow:  ASARow {
        get {
            let result: ASARow = settings.secondaryRowUUIDString.row(backupIndex: 1)
            //            debugPrint(#file, #function, result, result.calendar.calendarCode, result.locationData.formattedOneLineAddress)
            return result
        } // get
        set {
            settings.secondaryRowUUIDString = newValue.uuid.uuidString
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
    
    func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible> {
        var unsortedEvents: [ASAEventCompatible] = []
        if settings.useExternalEvents {
            let externalEvents = self.eventManager.eventsFor(startDate: self.primaryRow.startOfDay(date: self.date), endDate: self.primaryRow.startOfNextDay(date: self.date))
            unsortedEvents = unsortedEvents + externalEvents
        }
        
        for eventCalendar in userData.internalEventCalendars {
            unsortedEvents = unsortedEvents + eventCalendar.eventDetails(startDate:  startDate, endDate:  endDate, ISOCountryCode: eventCalendar.locationData.ISOCountryCode, requestedLocaleIdentifier: eventCalendar.localeIdentifier)
        } // for eventCalendar in userData.internalEventCalendars
        
        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
    
    var timeWidth:  CGFloat {
        get {
            if self.sizeClass! == .compact {
                return 100.00
            } else {
                return 120.00
            }
        } // get
    } // var timeWidth
    let TIME_FONT_SIZE = Font.subheadline
    
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
                ASADatePicker(date: $date, primaryRow: self.primaryRow
//                              , showingDatePicker: false
                )

                Form {
                    NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $settings.primaryRowUUIDString)) {
                        VStack(alignment:  .leading) {
                            Text(verbatim: primaryRow.dateString(now: date)).font(.title).bold()
                            if primaryRow.calendar.supportsLocations ||  primaryRow.calendar.supportsTimeZones {
                                HStack {
                                    if primaryRow.usesDeviceLocation {
                                        Image(systemName:  "location.fill").imageScale(.small)
                                    }
                                    Text(verbatim: primaryRow.emoji(date:  date))
                                    Text(verbatim:  primaryRow.locationData.formattedOneLineAddress)
                                }
                            }
                        }
                    }
                    
                    if settings.eventsViewShouldShowSecondaryDates && self.enoughRowsToShowSecondaryDates() {
                        NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $settings.secondaryRowUUIDString)) {
                            VStack(alignment:  .leading) {
                                if self.shouldHideTimesInSecondaryRow {
                                    Text(verbatim: secondaryRow.dateString(now: date)).font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                } else {
                                    Text(verbatim: "\(secondaryRow.dateTimeString(now: primaryRow.startOfDay(date: date)))\(NSLocalizedString("INTERVAL_SEPARATOR", comment: ""))\(secondaryRow.dateTimeString(now: primaryRow.startOfNextDay(date: date)))").font(.system(size: SECONDARY_ROW_FONT_SIZE))
                                }
                                if secondaryRow.calendar.supportsLocations ||  secondaryRow.calendar.supportsTimeZones {
                                    HStack {
                                        if secondaryRow.usesDeviceLocation {
                                            Image(systemName:  "location.fill").imageScale(.small)
                                        }
                                        Text(verbatim: secondaryRow.emoji(date:  date))
                                        Text(verbatim: secondaryRow.locationData.formattedOneLineAddress)
                                    }
                                }
                            }
                        }
                        Button("🔃") {
                            let tempRowUUIDString = self.settings.primaryRowUUIDString
                            self.settings.primaryRowUUIDString = self.settings.secondaryRowUUIDString
                            self.settings.secondaryRowUUIDString = tempRowUUIDString
                        }
                    }

                    Toggle(isOn: $showingPreferences) {
                        Text("Show preferences")
                    } // Toggle

                    if showingPreferences {
                        if self.enoughRowsToShowSecondaryDates() {
                            Toggle(isOn: $settings.eventsViewShouldShowSecondaryDates) {
                                ASAIndentedText(title: "Show secondary dates")
                            }
                        }

                        Toggle(isOn: $settings.useExternalEvents) {
                            ASAIndentedText(title: "Use external events")
                        } // Toggle

                        NavigationLink(destination:                             ASAInternalEventCalendarsView()
                        ) {
                            ASAIndentedText(title: "Internal event calendars")
                        }
                    }
                    
                    if settings.useExternalEvents {
                        #if targetEnvironment(macCatalyst)
                        Button(action:
                            {
                                self.showingEventEditView = true
                        }, label:  {
                            Text(NSLocalizedString(ADD_EXTERNAL_EVENT_STRING, comment: ""))
                        })
                            .popover(isPresented:  $showingEventEditView, arrowEdge: .top) {
                                ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore).frame(minWidth:  300, minHeight:  600)
                        }
                        .foregroundColor(.accentColor)
                        #else
                        Button(action:
                            {
                                self.showingEventEditView = true
                        }, label:  {
                            Text(NSLocalizedString(ADD_EXTERNAL_EVENT_STRING, comment: ""))
                        })
                            .sheet(isPresented:  $showingEventEditView) {
                                ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore).frame(minWidth:  300, minHeight:  600)
                        }
                        .foregroundColor(.accentColor)
                        #endif
                    }
                    
                    ForEach(self.events(startDate: self.primaryRow.startOfDay(date: date), endDate: self.primaryRow.startOfNextDay(date: date), row: self.primaryRow), id: \.eventIdentifier) {
                        event
                        in
                        ASALinkedEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.TIME_FONT_SIZE, eventsViewShouldShowSecondaryDates: self.settings.eventsViewShouldShowSecondaryDates, eventStore: self.eventManager.eventStore)
                    } // ForEach
                } // Form
                
            } // VStack
                .navigationBarTitle(Text("EVENTS_TAB"))
                .navigationBarHidden(self.isNavBarHidden)
                .onAppear {
                    self.isNavBarHidden = true
            }.onDisappear {
                self.isNavBarHidden = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAEventsView


// MARK: -

struct ASADatePicker:  View {
    let BOTTOM_BUTTONS_FONT_SIZE = Font.title
    //        let BOTTOM_BUTTONS_FONT_SIZE = Font.body
    
    @Binding var date:  Date {
        didSet {

        } // didSet
    } // var date
    @ObservedObject var primaryRow:  ASARow {
        didSet {

        } // didSet
    } // var primaryRow
//    @State var showingDatePicker:  Bool
    
//    #if os(iOS)
//    #if targetEnvironment(macCatalyst)
//    let runningOnIOS = false
//    #else
//    let runningOnIOS = true
//    #endif
//    #else
//    let runningOnIOS = false
//    #endif
    
//    let SPECIAL_SPACER_WIDTH = 80.0 as CGFloat
    
    var body: some View {
        HStack {
//            if runningOnIOS {
//                Toggle(isOn: self.$showingDatePicker) {
//                    Text("")
//                }
//                .frame(width:  SPECIAL_SPACER_WIDTH)
//            }
            
            Spacer()
            
//            if !self.showingDatePicker || !runningOnIOS {
                Button(action: {
                    self.date = self.date.oneDayBefore
                }) {
                    Text("🔺").font(BOTTOM_BUTTONS_FONT_SIZE)
                }
//            }
            
            
            Button(action: {
                self.date = Date()
            }) {
                Text("Today").font(BOTTOM_BUTTONS_FONT_SIZE)
            }.foregroundColor(.accentColor)
            
//            if !self.showingDatePicker || !runningOnIOS {
                Button(action: {
                    self.date = self.date.oneDayAfter
                }) {
                    Text("🔻").font(BOTTOM_BUTTONS_FONT_SIZE)
                }
//            }
            
            Spacer()

//            if self.showingDatePicker || !runningOnIOS {
                DatePicker(selection:  self.$date, in:  Date.distantPast...Date.distantFuture, displayedComponents: .date) {
                    Text("")
                }
                Spacer()
//            }
            
//            if !self.showingDatePicker && runningOnIOS {
//                Spacer().frame(width:  SPECIAL_SPACER_WIDTH)
//            }

        }
        .border(Color.gray)
    } // var body
} // struct ASADatePicker


// MARK: -

struct ASALinkedEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
    var secondaryRow:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var eventsViewShouldShowSecondaryDates: Bool
    var eventStore:  EKEventStore
    @State private var action:  EKEventViewAction?
    @State private var showingEventView = false

    let CLOSE_BUTTON_TITLE = "Done"
    
    var body: some View {
        Group {
            if event.isEKEvent {
                HStack {
                    ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates)
                    
                    Spacer()
                    
                    #if targetEnvironment(macCatalyst)
                    Button(action:  {
                        self.showingEventView = true
                    }, label:  {
                        Image(systemName: "info.circle.fill") .font(Font.system(.title))
                    })
                        .popover(isPresented: $showingEventView, arrowEdge: .leading) {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(NSLocalizedString(self.CLOSE_BUTTON_TITLE, comment: ""), action: {
                                        self.showingEventView = false
                                    })
                                    Spacer().frame(width:  30)
                                }
                                ASAEKEventView(action: self.$action, event: self.event as! EKEvent).frame(minWidth:  300, minHeight:  500)
                            }
                    }.foregroundColor(.accentColor)
                    #else
                    Button(action:  {
                        self.showingEventView = true
                    }, label:  {
                        Image(systemName: "info.circle.fill") .font(Font.system(.title))
                    })
                        .sheet(isPresented: $showingEventView) {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(NSLocalizedString(self.CLOSE_BUTTON_TITLE, comment: ""), action: {
                                        self.showingEventView = false
                                    })
                                    Spacer().frame(width:  20)
                                }
                                ASAEKEventView(action: self.$action, event: self.event as! EKEvent).frame(minWidth:  300, minHeight:  300)
                            }
                    }.foregroundColor(.accentColor)
                    #endif
                }
            } else {
                ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates)
            }
        }
    }
}


// MARK: -

struct ASAEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
    var secondaryRow:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var eventsViewShouldShowSecondaryDates: Bool

    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        HStack {
            ASAStartAndEndTimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize)
            if self.eventsViewShouldShowSecondaryDates {
                ASAStartAndEndTimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize)
            }
            Rectangle().frame(width:  2.0).foregroundColor(event.color)
            VStack(alignment: .leading) {
                if self.sizeClass == .compact {
                    Text(event.title).font(.callout).bold().foregroundColor(Color(UIColor.label))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                } else {
                    Text(event.title).font(.headline).foregroundColor(Color(UIColor.label))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
                Text(event.calendarTitle).font(.subheadline).foregroundColor(Color(UIColor.secondaryLabel))
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
            } // VStack
        } // HStack
    }
}


// MARK: -

struct ASAAllDayTimesSubsubcell:  View {
    var startDate:  Date
    var endDate:  Date
    var startDateString:  String
    var endDateString:    String
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    
    var body:  some View {
        VStack {
            Text(startDateString).frame(width:  timeWidth).font(timeFontSize)
                .foregroundColor(startDate < Date() ? Color.gray : Color(UIColor.label))
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
            if startDateString != endDateString {
                Text(endDateString).frame(width:  timeWidth).font(timeFontSize)
                    .foregroundColor(endDate < Date() ? Color.gray : Color(UIColor.label))
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                //            } else {
                //                Text("All day").frame(width:  timeWidth).font(timeFontSize)
                //                    .foregroundColor(endDate < Date() ? Color.gray : Color(UIColor.label))
            }
        }
    }
}


// MARK: -

struct ASAStartAndEndTimesSubcell:  View {
    var event:  ASAEventCompatible
    var row:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    
    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay && row.calendar.calendarCode == event.calendarCode && (row.effectiveTimeZone.secondsFromGMT(for: event.startDate) == event.timeZone?.secondsFromGMT(for: event.startDate) || event.timeZone == nil) {
                ASAAllDayTimesSubsubcell(startDate:  event.startDate, endDate:  event.endDate, startDateString: row.shortenedDateString(now: event.startDate), endDateString: row.shortenedDateString(now: event.endDate - 1), timeWidth: timeWidth, timeFontSize: timeFontSize)
            } else {
                Text(row.shortenedDateTimeString(now: event.startDate)).frame(width:  timeWidth).font(timeFontSize).foregroundColor(event.startDate < Date() ? Color.gray : Color(UIColor.label))
                    .lineLimit(2)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                if event.endDate != event.startDate {
                    Text(row.shortenedDateTimeString(now: event.endDate)).frame(width:  timeWidth).font(self.timeFontSize).foregroundColor(event.endDate < Date() ? Color.gray : Color(UIColor.label))
                        .lineLimit(2)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
            }
        } // VStack
    } // var body
} // struct ASAStartAndEndTimesSubcell


// MARK: -

struct ASAEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventsView(settings: ASAUserSettings(), eventManager: ASAExternalEventManager.shared(), userData:                 ASAEventsView().environmentObject(ASAUserData.shared()) as! EnvironmentObject<ASAUserData>, date: Date())
    }
}
