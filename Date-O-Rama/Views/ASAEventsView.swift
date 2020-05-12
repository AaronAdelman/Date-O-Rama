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
    @State var date = Date()
    @State var events:  Array<EKEvent> = []
    var timeFormatter:  DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
    let TIME_WIDTH = 45.0 as CGFloat
    let TIME_FONT_SIZE = Font.caption
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events, id: \.eventIdentifier) {
                    event
                    in
                    HStack {
                        if event.isAllDay {
                            Text("All day").frame(width:  self.TIME_WIDTH).font(self.TIME_FONT_SIZE)
                        } else {
                            VStack {
                                Text(self.timeFormatter.string(from: event.startDate)).frame(width:  self.TIME_WIDTH).font(self.TIME_FONT_SIZE)
                                Text(self.timeFormatter.string(from: event.endDate)).frame(width:  self.TIME_WIDTH).font(self.TIME_FONT_SIZE)
                            }
                        }
                        Rectangle().frame(width:  2.0).foregroundColor(Color(UIColor(cgColor: event.calendar.cgColor)))
                        Text(event.title)
                    }
                }
            }
            .onAppear() {
                let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
                debugPrint(#file, #function, status)
                
                self.eventManager.requestAccessToCalendar()
                self.events = self.eventManager.eventsFor(startDate: self.date.previousMidnight(timeZone: TimeZone.autoupdatingCurrent), endDate: self.date.nextMidnight(timeZone: TimeZone.autoupdatingCurrent))
                debugPrint(#file, #function, self.events.count)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASAEventsView

struct ASAEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventsView()
    }
}
