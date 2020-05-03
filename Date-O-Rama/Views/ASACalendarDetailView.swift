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
            
        case SUNSET_KEY, PREVIOUS_SUNSET_KEY:
            return "sunset"
            
        default:
            return nil
        } // switch self
    } // func systemIconName() -> String?
} // extension ASASolarEvent


struct ASACalendarDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    
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
                
                ASACalendarTimeZoneCell(timeZone: selectedRow.effectiveTimeZone, now: now)
                
                NavigationLink(destination:  ASALocationChooserView(row:  selectedRow, tempLocationData: ASALocationData())) {
                                        ASACalendarLocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, location: self.selectedRow.location, placeName: self.selectedRow.placeName, locality: self.selectedRow.locality, country: self.selectedRow.country, ISOCountryCode: self.selectedRow.ISOCountryCode)
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
                    ForEach(selectedRow.calendar.eventDetails(date: now, location: self.selectedRow.location), id: \.key) {
                        detail
                        in
                        ASACalendarDetailCell(title: NSLocalizedString(detail.key, comment: ""), detail: detail.value == nil ? "—" : DateFormatter.localizedString(from: detail.value!, dateStyle: .none, timeStyle: .medium), systemIconName: detail.key.systemIconName())
                    }
                } // Section
            }
            
            Section(header:  Text("HEADER_Other")) {
                ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: DateFormatter.localizedString(from: self.selectedRow.startOfNextDay(now: now), dateStyle: .full, timeStyle: .full))
                ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DAY", comment: ""), detail: self.selectedRow.dateString(now: self.selectedRow.startOfNextDay(now:  now).addingTimeInterval(1)), systemIconName: nil)
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
