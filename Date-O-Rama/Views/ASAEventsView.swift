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

let INFO_STRING     = "ⓘ"
let BIG_PLUS_STRING = "Add external event"

struct ASAEventsView: View {
    @ObservedObject var settings = ASAUserSettings()
    
    @ObservedObject var eventManager = ASAExternalEventManager.shared()
    @EnvironmentObject var userData:  ASAUserData
    @State var date = Date()
    var primaryRow:  ASARow {
        get {
            return settings.primaryRowUUIDString.row(backupIndex: 0)
        } // get
        set {
            settings.primaryRowUUIDString = newValue.uuid.uuidString
        } // set
    } // var primaryRow:  ASARow
    var secondaryRow:  ASARow {
        get {
            return settings.secondaryRowUUIDString.row(backupIndex: 1)
        } // get
        set {
            settings.secondaryRowUUIDString = newValue.uuid.uuidString
        } // set
    } // var secondaryRow
    
    func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible> {
        let externalEvents = self.eventManager.eventsFor(startDate: self.primaryRow.startOfDay(date: self.date), endDate: self.primaryRow.startOfNextDay(date: self.date))
        
        let row = self.primaryRow
        let HebrewCalendarEvents: [ASAEvent] = ASAHebrewCalendarEvents.eventDetails(startDate:  startDate, endDate: endDate, location: row.locationData.location ?? CLLocation.NullIsland, timeZone: row.effectiveTimeZone)
        let unsortedEvents: [ASAEventCompatible] = externalEvents + HebrewCalendarEvents
        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
    
    let TIME_WIDTH = 100.0 as CGFloat
    let TIME_FONT_SIZE = Font.subheadline
    
    @State var isNavBarHidden:  Bool = false
    
    @State private var action:  EKEventEditViewAction?
    @State private var showingEventEditView = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $settings.primaryRowUUIDString)) {
                        VStack(alignment:  .leading) {
                            Text(verbatim: primaryRow.dateString(now: date)).font(.title).bold()
                            if primaryRow.calendar.supportsLocations ||  primaryRow.calendar.supportsTimeZones {
                                HStack {
                                    Text(verbatim: primaryRow.emoji(date:  date))
                                    Text(verbatim:  primaryRow.locationData.formattedOneLineAddress())
                                }
                            }
                        }
                    }
                    
                    if settings.eventsViewShouldShowSecondaryDates {
                        NavigationLink(destination:  ASARowChooser(selectedUUIDString:  $settings.secondaryRowUUIDString)) {
                            VStack(alignment:  .leading) {
                                Text(verbatim: "\(secondaryRow.dateTimeString(now: primaryRow.startOfDay(date: date)))\(NSLocalizedString("INTERVAL_SEPARATOR", comment: ""))\(secondaryRow.dateTimeString(now: primaryRow.startOfNextDay(date: date)))").font(.title)
                                if secondaryRow.calendar.supportsLocations ||  secondaryRow.calendar.supportsTimeZones {
                                    HStack {
                                        Text(verbatim: secondaryRow.emoji(date:  date))
                                        Text(verbatim: secondaryRow.locationData.formattedOneLineAddress())
                                    }
                                }
                            }
                        }
                    }
                    Toggle(isOn: $settings.eventsViewShouldShowSecondaryDates) {
                        Text("Show secondary dates")
                    }
                    
                    #if targetEnvironment(macCatalyst)
                    Button(action:
                        {
                            self.showingEventEditView = true
                    }, label:  {
                        Text(NSLocalizedString(BIG_PLUS_STRING, comment: ""))
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
                        Text(NSLocalizedString(BIG_PLUS_STRING, comment: ""))
                    })
                        .sheet(isPresented:  $showingEventEditView) {
                            ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore).frame(minWidth:  300, minHeight:  600)
                    }
                    .foregroundColor(.accentColor)
                    #endif
                    
                    ForEach(self.events(startDate: self.primaryRow.startOfDay(date: date), endDate: self.primaryRow.startOfNextDay(date: date), row: self.primaryRow), id: \.eventIdentifier) {
                        event
                        in
                        ASALinkedEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.TIME_WIDTH, timeFontSize: self.TIME_FONT_SIZE, eventsViewShouldShowSecondaryDates: self.settings.eventsViewShouldShowSecondaryDates, eventStore: self.eventManager.eventStore)
                    } // ForEach
                } // List
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.date = self.date.oneDayBefore
                    }) {
                        Text("🔺").font(BOTTOM_BUTTONS_FONT_SIZE)
                    }
                    
                    Spacer().frame(width:  50)
                    
                    Button(action: {
                        self.date = Date()
                    }) {
                        Text("Today").font(BOTTOM_BUTTONS_FONT_SIZE)
                    }.foregroundColor(.accentColor)
                    
                    Spacer().frame(width:  50)
                    
                    Button(action: {
                        self.date = self.date.oneDayAfter
                    }) {
                        Text("🔻").font(BOTTOM_BUTTONS_FONT_SIZE)
                    }
                    
                    Spacer()
                }.border(Color.gray)
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
    
    let BOTTOM_BUTTONS_FONT_SIZE = Font.title
} // struct ASAEventsView

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
    
    var body: some View {
        Group {
            if event.isEKEvent {
                HStack {
                    ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates)
                    
                    Spacer()
                   
                    #if targetEnvironment(macCatalyst)
                    Button(INFO_STRING) {
                        self.showingEventView = true
                    }
                        .popover(isPresented: $showingEventView, arrowEdge: .leading) {
                            ASAEKEventView(action: self.$action, event: self.event as! EKEvent).frame(minWidth:  300, minHeight:  500)
                    }.foregroundColor(.accentColor)
                    #else
                    Button(INFO_STRING) {
                        self.showingEventView = true
                    }
                        .sheet(isPresented: $showingEventView) {
                            ASAEKEventView(action: self.$action, event: self.event as! EKEvent).frame(minWidth:  300, minHeight:  500)
                    }.foregroundColor(.accentColor)
                    #endif
                }
                
            } else {
                ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates)
            }
        }
    }
}

struct ASAEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
    var secondaryRow:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var eventsViewShouldShowSecondaryDates: Bool
    
    var body: some View {
        HStack {
            ASAStartAndEndTimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize)
            if self.eventsViewShouldShowSecondaryDates {
                ASAStartAndEndTimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize)
            }
            Rectangle().frame(width:  2.0).foregroundColor(event.color)
            VStack(alignment: .leading) {
                Text(event.title).font(.headline)
                Text(event.calendarTitle).font(.subheadline).foregroundColor(Color(UIColor.systemGray))
            } // VStack
        } // HStack
    }
}

struct ASAStartAndEndTimesSubcell:  View {
    var event:  ASAEventCompatible
    var row:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    
    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay && row.calendar.calendarCode == ASACalendarCode.Gregorian {
                Text(row.dateString(now: event.startDate)).frame(width:  timeWidth).font(timeFontSize)
                Text("All day").frame(width:  timeWidth).font(timeFontSize)
            } else {
                Text(row.dateTimeString(now: event.startDate)).frame(width:  timeWidth).font(timeFontSize)
                if event.endDate != event.startDate {
                    Text(row.dateTimeString(now: event.endDate)).frame(width:  timeWidth).font(self.timeFontSize)
                }
            }
        } // VStack
    } // var body
} // struct ASAStartAndEndTimesSubcell

struct ASAEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventsView(settings: ASAUserSettings(), eventManager: ASAExternalEventManager.shared(), userData:                 ASAEventsView().environmentObject(ASAUserData.shared()) as! EnvironmentObject<ASAUserData>, date: Date())
    }
}
