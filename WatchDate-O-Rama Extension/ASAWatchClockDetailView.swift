//
//  ASAWatchClockDetailView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-06-01.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASAWatchClockDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    
    func localDateFormatter(timeZone:  TimeZone?) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone ?? TimeZone(secondsFromGMT: 0)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        return dateFormatter
    } // func localDateFormatter(timeZone:  TimeZone?) -> DateFormatter
    
    var body: some View {
        List {
            Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
//                NavigationLink(destination: ASACalendarChooserView(row: self.selectedRow)) {
                    HStack {
                        Text(verbatim: "🗓")
                        ASAClockDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                    }
//                }
                if selectedRow.supportsLocales() {
//                    NavigationLink(destination: ASALocaleChooserView(row: selectedRow)) {
                        HStack {
                            Text(verbatim:  selectedRow.localeIdentifier.localeCountryCodeFlag())
                            ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                        }
//                    }
                }
                if selectedRow.calendar.supportsDateFormats {
                    NavigationLink(destination: ASADateFormatChooserView(row: selectedRow)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                    }
                }
                if selectedRow.calendar.supportsTimeFormats {
                    NavigationLink(destination: ASATimeFormatChooserView(row: selectedRow)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Time_format", comment: ""), detail: selectedRow.majorTimeFormat.localizedItemName())
                    }
                }

                if selectedRow.calendar.supportsTimeZones || selectedRow.calendar.supportsLocations {
                    ASATimeZoneCell(timeZone: selectedRow.effectiveTimeZone, now: now)
                    
//                    NavigationLink(destination:  ASALocationChooserView(locatedObject:  selectedRow, tempLocationData: ASALocationData())) {
                        ASALocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, locationData: self.selectedRow.locationData)
//                    }
                }
            } // Section
            
            if selectedRow.calendar.LDMLDetails.count > 0 {
                Section(header:  Text("HEADER_Date")) {
                    ForEach(selectedRow.LDMLDetails(), id: \.name) {
                        detail
                        in
                        ASAClockDetailCell(title: NSLocalizedString(detail.name, comment: ""), detail: self.selectedRow.dateTimeString(now: self.now, LDMLString: detail.geekCode))
                    }
                } // Section
            }
                        
            Section(header:  Text("HEADER_Other")) {
                ASAClockDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: DateFormatter.localizedString(from: self.selectedRow.startOfNextDay(date: now), dateStyle: .full, timeStyle: .full))
                ASAClockDetailCell(title: NSLocalizedString("ITEM_NEXT_DAY", comment: ""), detail: self.selectedRow.dateString(now: self.selectedRow.startOfNextDay(date:  now).addingTimeInterval(1)))
            } // Section
            
        }.navigationBarTitle(Text(
            selectedRow.dateString(now: self.now) ))
    }
}

struct ASAWatchClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAWatchClockDetailView(selectedRow: ASARow.generic(), now: Date())
    }
}
