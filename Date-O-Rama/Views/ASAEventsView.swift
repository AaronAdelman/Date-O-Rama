//
//  ASAEventsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import EventKit

struct ASAEventsView: View {
    var eventManager = ASAEventManager.shared()
    @EnvironmentObject var userData:  ASAUserData
    @State var date = Date()
    
    func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible> {
        let externalEvents = self.eventManager.eventsFor(startDate: self.primaryRow.startOfDay(date: self.date), endDate: self.primaryRow.startOfNextDay(date: self.date))
        
        let row = self.primaryRow
        let HebrewCalendarEvents: [ASAEvent] = ASAHebrewCalendarSupplement.eventDetails(date:  self.date, location: row.locationData.location ?? CLLocation.NullIsland, timeZone: row.effectiveTimeZone)
        let unsortedEvents: [ASAEventCompatible] = externalEvents + HebrewCalendarEvents
        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
    
    let TIME_WIDTH = 100.0 as CGFloat
    let TIME_FONT_SIZE = Font.subheadline
    
    @State var primaryRow:  ASARow = ASAUserData.shared().mainRows[0]
    
    @State var secondaryRow:  ASARow = ASAUserData.shared().mainRows[1]
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination:  ASARowChooser(selectedRow: $primaryRow)) {
                    Text(verbatim: primaryRow.dateString(now: date)).font(.title).bold()
                }
                
                NavigationLink(destination:  ASARowChooser(selectedRow: $secondaryRow)) {
                Text(verbatim: "\(secondaryRow.dateTimeString(now: primaryRow.startOfDay(date: date)))\(NSLocalizedString("INTERVAL_SEPARATOR", comment: ""))\(secondaryRow.dateTimeString(now: primaryRow.startOfNextDay(date: date)))").font(.title)
                }
   
                ForEach(self.events(startDate: self.primaryRow.startOfDay(date: date), endDate: self.primaryRow.startOfNextDay(date: date), row: self.primaryRow), id: \.eventIdentifier) {
                    event
                    in
                    HStack {
                        ASAStartAndEndTimesSubcell(event: event, row: self.primaryRow, timeWidth: self.TIME_WIDTH, timeFontSize: self.TIME_FONT_SIZE)
                        ASAStartAndEndTimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.TIME_WIDTH, timeFontSize: self.TIME_FONT_SIZE)
                        Rectangle().frame(width:  2.0).foregroundColor(event.color)
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text(event.calendarTitle).font(.subheadline).foregroundColor(Color(UIColor.systemGray))
                        } // VStack
                    } // HStack
                }
                
            }
            .onAppear() {
                self.primaryRow = self.userData.mainRows[0]
                
                self.secondaryRow = self.userData.mainRows[1]
                
                let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
                debugPrint(#file, #function, status)
                
                self.eventManager.requestAccessToCalendar()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAEventsView

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
        ASAEventsView(primaryRow: ASARow.generic(), secondaryRow: ASARow.generic())
    }
}
