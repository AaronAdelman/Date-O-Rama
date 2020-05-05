//
//  ASACalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

extension String {
    func systemIconName() -> String? {
        switch self {
        case SUNRISE_KEY:
            return "sunrise"
            
        case SUNSET_KEY:
            return "sunset"
            
        default:
            return nil
        } // switch self
    } // func systemIconName() -> String?
} // extension ASASolarEvent


struct ASACalendarDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    
    func localDateFormatter(timeZone:  TimeZone?) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone ?? TimeZone(secondsFromGMT: 0)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        return dateFormatter
    }
    
    var body: some View {
        List {
            Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow)) {
                    HStack {
                        Text(verbatim: "🗓")
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                    }
                }
                if selectedRow.supportsLocales() {
                    NavigationLink(destination: ASALocalePickerView(row: selectedRow)) {
                        HStack {
                            Text(verbatim:  selectedRow.localeIdentifier.localeCountryCodeFlag())
                            ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                        }
                    }
                }
                if selectedRow.calendar.supportsDateFormats() {
                    NavigationLink(destination: ASAFormatPickerView(row: selectedRow)) {
                        ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                    }
                }
                
                if selectedRow.calendar.supportsTimeZones() || selectedRow.calendar.supportsLocations() {
                    ASACalendarTimeZoneCell(timeZone: selectedRow.effectiveTimeZone, now: now)
                    
                    NavigationLink(destination:  ASALocationChooserView(row:  selectedRow, tempLocationData: ASALocationData())) {
                        ASACalendarLocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, locationData: self.selectedRow.locationData)
                    }
                }
            } // Section
            
            if selectedRow.calendar.LDMLDetails().count > 0 {
                Section(header:  Text("HEADER_Date")) {
                    ForEach(selectedRow.details(), id: \.name) {
                        detail
                        in
                        ASACalendarDetailCell(title: NSLocalizedString(detail.name, comment: ""), detail: self.selectedRow.dateString(now: self.now, LDMLString: detail.geekCode))
                    }
                } // Section
            }
            
            if selectedRow.calendar.supportsEventDetails() {
                Section(header:  Text("HEADER_EVENTS")) {
                    ForEach(selectedRow.calendar.eventDetails(date: now, location: self.selectedRow.location, timeZone: selectedRow.effectiveTimeZone), id: \.uuid) {
                        event
                        in
                        ASAEventCell(event:  event)
                    }
                } // Section
                    .listRowBackground(Color(selectedRow.calendar.color))
            }
            
            Section(header:  Text("HEADER_Other")) {
                ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: DateFormatter.localizedString(from: self.selectedRow.startOfNextDay(now: now), dateStyle: .full, timeStyle: .full))
                ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DAY", comment: ""), detail: self.selectedRow.dateString(now: self.selectedRow.startOfNextDay(now:  now).addingTimeInterval(1)))
            } // Section
            
        }.navigationBarTitle(Text(
            selectedRow.dateString(now: self.now) ))
    }
}

struct ASACalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailView(selectedRow: ASARow.generic(), now: Date())
    }
}
