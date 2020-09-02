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

            NavigationLink(destination: ASALocaleChooserView(row: selectedEventCalendar, tempLocaleIdentifier: selectedEventCalendar.localeIdentifier, providedLocaleIdentifiers: selectedEventCalendar.supportedLocales)) {
                HStack {
                    Text(verbatim:  selectedEventCalendar.localeIdentifier.localeCountryCodeFlag())
                    ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedEventCalendar.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                }
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
