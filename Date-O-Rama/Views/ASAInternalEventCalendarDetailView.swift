//
//  ASAInternalEventCalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAInternalEventCalendarDetailView: View {
    @ObservedObject var selectedEventCalendar:  ASAInternalEventCalendar
    
    var body: some View {
        List {
            
            NavigationLink(destination:  ASAInternalEventSourceChooser(eventCalendar:  self.selectedEventCalendar)) {
//                Text(selectedEventCalendar.eventSourceCode).font(.headline)
                Text(selectedEventCalendar.eventSourceName()).font(.headline)
            }
            
            ASATimeZoneCell(timeZone: selectedEventCalendar.effectiveTimeZone, now: Date())
            
            NavigationLink(destination:  ASALocationChooserView(locatedObject:  selectedEventCalendar, tempLocationData: ASALocationData())) {
                ASALocationCell(usesDeviceLocation: self.selectedEventCalendar.usesDeviceLocation, locationData: self.selectedEventCalendar.locationData)
            }
            
        } // List
    } // var body
} // struct ASAInternalEventCalendarDetailView

struct ASAInternalEventCalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        ASAInternalEventCalendarDetailView(selectedEventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: .dailyJewish)!)
        ASAInternalEventCalendarDetailView(selectedEventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: "Solar events")!)
    }
}
