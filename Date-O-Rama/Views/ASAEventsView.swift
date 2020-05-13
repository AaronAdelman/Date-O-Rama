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
    var userData = ASAUserData.shared()
    @State var date = Date()
    @State var primaryRowUUID:  UUID?
    @State var secondaryRowUUID:  UUID?
    
    func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible> {
        let externalEvents = self.eventManager.eventsFor(startDate: self.primaryRow.startODay(date: self.date), endDate: self.primaryRow.startOfNextDay(date: self.date))
        
        let row = self.primaryRow
        //        return externalEvents + ASAHebrewCalendarSupplement.eventDetails(startDate: self.primaryRow.startODay(date: self.date), endDate: self.primaryRow.startOfNextDay(date: self.date), location: row.locationData.location ?? CLLocation.NullIsland, timeZone: row.effectiveTimeZone)
        let HebrewCalendarEvents: [ASAEvent] = ASAHebrewCalendarSupplement.eventDetails(date:  self.date, location: row.locationData.location ?? CLLocation.NullIsland, timeZone: row.effectiveTimeZone)
        let unsortedEvents: [ASAEventCompatible] = externalEvents + HebrewCalendarEvents
        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
    
    //    var timeFormatter:  DateFormatter = {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateStyle = .none
//        dateFormatter.timeStyle = .short
//        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
//        return dateFormatter
//    }()
    let TIME_WIDTH = 150.0 as CGFloat
    let TIME_FONT_SIZE = Font.subheadline
    
    var primaryRow:  ASARow {
        get {
            let result = self.userData.mainRows.first(where: {$0.uuid == self.primaryRowUUID})
            if result != nil {
                return result!
            }
            
            return ASARow.generic()
        } // get
    } // var primaryRow
    
    var secondaryRow:  ASARow {
        get {
            let result = self.userData.mainRows.first(where: {$0.uuid == self.secondaryRowUUID})
            if result != nil {
                return result!
            }
            
            return ASARow.generic()
        } // get
    } // var secondaryRow:  ASARow
    
    var body: some View {
        NavigationView {
            List {
                Text(verbatim: primaryRow.dateString(now: date)).font(.title)
                Text(verbatim: secondaryRow.dateString(now: date)).font(.title)
                Spacer()
                ForEach(self.events(startDate: self.primaryRow.startODay(date: date), endDate: self.primaryRow.startOfNextDay(date: date), row: self.primaryRow), id: \.eventIdentifier) {
                    event
                    in
                    HStack {
                        ASAStartAndEndTimesSubcell(event: event, row: self.primaryRow, timeWidth: self.TIME_WIDTH, timeFontSize: self.TIME_FONT_SIZE)
                        ASAStartAndEndTimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.TIME_WIDTH, timeFontSize: self.TIME_FONT_SIZE)
                        Rectangle().frame(width:  2.0).foregroundColor(event.color)
                        Text(event.title)
                    }
                }
            }
            .onAppear() {
                if self.primaryRowUUID == nil {
                    self.primaryRowUUID = self.userData.mainRows[0].uuid
                }
                if self.secondaryRowUUID == nil {
                    self.secondaryRowUUID = self.userData.mainRows[1].uuid
                }
                
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
        ASAEventsView()
    }
}
