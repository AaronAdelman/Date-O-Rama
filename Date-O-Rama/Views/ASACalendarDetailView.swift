//
//  ASACalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASACalendarDetailCell:  View {
    var title:  String
    var detail:  String
    var body:  some View {
        HStack {
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail).multilineTextAlignment(.trailing)
        } // HStack
    } // var body
} // struct ASADetailCell


struct ASACalendarDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    var currentLocation:  CLLocation
    
    var body: some View {
        List {
            //            if selectedRow != nil {
            if selectedRow.dummy != true {
                Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                    NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow, currentLocation: self.currentLocation)) {
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                    }
                    if selectedRow.supportsLocales() {
                        NavigationLink(destination: ASALocalePickerView(row: selectedRow, currentLocation: self.currentLocation)) {
                            ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                        }
                    }
                    if selectedRow.calendar.supportsDateFormats() {
                        NavigationLink(destination: ASAFormatPickerView(row: selectedRow, currentLocation: self.currentLocation)) {
                            ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                        }
                    }
                    if selectedRow.calendar.supportsTimeZones() {
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_TIME_ZONE", comment: ""), detail: "\(TimeZone.autoupdatingCurrent)")
                    } else {
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_TIME_ZONE", comment: ""), detail: "\(TimeZone(secondsFromGMT: 0)!)")
                    }
                    if selectedRow.calendar.supportsLocations() {
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_LATITUDE", comment: ""), detail: "\(self.currentLocation.coordinate.latitude)")
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_LONGITUDE", comment: ""), detail: "\(self.currentLocation.coordinate.longitude)")
                    }
                }
                if selectedRow.calendar.details().count > 0 {
                    Section(header:  Text("HEADER_Date")) {
                        ForEach(selectedRow.details(), id: \.name) {
                            detail
                            in
                            ASACalendarDetailCell(title: NSLocalizedString(detail.name, comment: ""), detail: self.selectedRow.dateString(now: self.now, LDMLString: detail.geekCode, defaultLocation: self.currentLocation))
                        }
                    }
                }
                Section(header:  Text("HEADER_Other")) {
                    ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: "\(self.selectedRow.calendar.transitionToNextDay(now: self.now, location: currentLocation))")
                }
            } else {
                //                Text("Detail view content goes here")
                EmptyView()
            }
        }.navigationBarTitle(Text(selectedRow.dummy ? "" : selectedRow.dateString(now: self.now, defaultLocation: self.currentLocation) ))
    }
}

struct ASACalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailView(selectedRow: ASARow.generic(), now: Date(), currentLocation: CLLocation(latitude: 0.0, longitude: 0.0))
    }
}
