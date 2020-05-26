//
//  ASAInternalEventCalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAInternalEventCalendarDetailView: View {
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar
    
    var body: some View {
        List {
            HStack {
                Text(eventCalendar.emoji(date: Date()))
                Text(eventCalendar.eventCalendarName()).font(.headline)
            }
            
            ASACalendarTimeZoneCell(timeZone: eventCalendar.effectiveTimeZone, now: Date())
            
            NavigationLink(destination:  ASALocationChooserView(row:  eventCalendar, tempLocationData: ASALocationData())) {
                ASACalendarLocationCell(usesDeviceLocation: self.eventCalendar.usesDeviceLocation, locationData: self.eventCalendar.locationData)
            }
            
        } // List
    } // var body
} // struct ASAInternalEventCalendarDetailView

struct ASAInternalEventCalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAInternalEventCalendarDetailView(eventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: .dailyJewish)!)
    }
}
