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
        ASAInternalEventCalendarDetailList(selectedEventCalendar: self.selectedEventCalendar)
    } // var body
} // struct ASAInternalEventCalendarDetailView

struct ASAInternalEventCalendarDetailList:  View {
    @ObservedObject var selectedEventCalendar:  ASAInternalEventCalendar

    var body: some View {
        List {
            NavigationLink(destination:  ASAInternalEventSourceChooser(eventCalendar:  self.selectedEventCalendar, tempInternalEventCode: self.selectedEventCalendar.eventSourceCode)) {
                Text(selectedEventCalendar.eventSourceName()).font(.headline)
            }

            NavigationLink(destination: ASALocaleChooserView(row: selectedEventCalendar, tempLocaleIdentifier: selectedEventCalendar.localeIdentifier, providedLocaleIdentifiers: selectedEventCalendar.supportedLocales)) {
                HStack {
                    Text(verbatim:  selectedEventCalendar.localeIdentifier.localeCountryCodeFlag())
                    ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedEventCalendar.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                }
            }


            NavigationLink(destination:  ASALocationChooserView(locatedObject:  selectedEventCalendar, tempLocationData: ASALocationData())) {
                VStack {
                    ASALocationCell(usesDeviceLocation: self.selectedEventCalendar.usesDeviceLocation, locationData: self.selectedEventCalendar.locationData)
                    Spacer()
                    ASATimeZoneCell(timeZone: selectedEventCalendar.effectiveTimeZone, now: Date())
                } // VStack
            }

        } // List
    } // var body
} // struct ASAInternalEventCalendarDetailList

struct ASAInternalEventCalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAInternalEventCalendarDetailView(selectedEventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: "Solar events")!)
    }
}
