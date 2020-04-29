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


struct ASACalendarDetailCell:  View {
    var title:  String
    var detail:  String
    var systemIconName:  String?
    
    var body:  some View {
        HStack {
            if systemIconName != nil {
                Image(systemName: systemIconName!)
            }
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail).multilineTextAlignment(.trailing)
        } // HStack
    } // var body
} // struct ASADetailCell


struct ASACalendarTimeZoneCell:  View {
    var timeZone:  TimeZone
    var now:  Date

    var body:  some View {
        HStack {
            Text(verbatim:  NSLocalizedString("HEADER_TIME_ZONE", comment: "")).bold()
            Spacer()
            VStack {
                if timeZone == TimeZone.autoupdatingCurrent {
                    HStack {
                        Spacer()
                        Text("AUTOUPDATING_CURRENT_TIME_ZONE").multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Spacer()
                    Text(verbatim:  timeZone.abbreviation(for:  now) ?? "").multilineTextAlignment(.trailing)
                }
                HStack {
                    Spacer()
                    Text(verbatim:  timeZone.localizedName(for: timeZone.isDaylightSavingTime(for: now) ? .daylightSaving : .standard, locale: Locale.current) ?? "").multilineTextAlignment(.trailing)
                }
            }
        } // HStack
    } // var body
} // struct ASACalendarTimeZoneCell


struct ASACalendarLocationCell:  View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    var currentLocation:  CLLocation
    var currentPlacemark:  CLPlacemark?
    
    func location() -> CLLocation {
        if selectedRow.usesDeviceLocation {
            return currentLocation
        } else {
            return selectedRow.location
        }
    } // func location() -> CLLocation
    
    func placemark() -> CLPlacemark? {
        if selectedRow.usesDeviceLocation {
            return currentPlacemark
        } else {
            return selectedRow.placemark
        }
    } //
    
    var body: some View {
        HStack {
            Text((self.currentPlacemark?.isoCountryCode ?? "").flag())
            Text("HEADER_LOCATION").bold()
            Spacer()
            VStack {
                if selectedRow.usesDeviceLocation {
                    HStack {
                        Spacer()
                        Image(systemName: "location")
                        Text("DEVICE_LOCATION").multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Spacer()
                    Text(verbatim:  location().humanInterfaceRepresentation()).multilineTextAlignment(.trailing)
                }
                if placemark()?.name != nil {
                    HStack {
                        Spacer()
                        Text(placemark()!.name!)
                    }
                }
                if placemark()?.locality != nil {
                    HStack {
                        Spacer()
                        Text(placemark()!.locality!)
                    }
                }
                if placemark() != nil {
                    HStack {
                        Spacer()
                        if placemark()?.country != nil {
                            Text(placemark()!.country!)
                        }
                    }
                }
            } // VStack
        } // HStack
    } // body
} // struct ASACalendarLocationCell


struct ASACalendarDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    var currentLocation:  CLLocation
    var currentPlacemark:  CLPlacemark?
    
    var body: some View {
        List {
            //            if selectedRow != nil {
            if selectedRow.dummy != true {
                Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                    NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow, currentLocation: self.currentLocation)) {
                        HStack {
//                            Image(systemName: "calendar")
                            Text(verbatim: "🗓")
                            ASACalendarDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                        }
                    }
                    if selectedRow.supportsLocales() {
                        NavigationLink(destination: ASALocalePickerView(row: selectedRow, currentLocation: self.currentLocation)) {
                            HStack {
                                Text(verbatim:  selectedRow.localeIdentifier.localeCountryCodeFlag())
                                ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                            }
                        }
                    }
                    if selectedRow.calendar.supportsDateFormats() {
                        NavigationLink(destination: ASAFormatPickerView(row: selectedRow, currentLocation: self.currentLocation)) {
                            ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                        }
                    }
                    if selectedRow.calendar.supportsTimeZones() {
                        NavigationLink(destination: ASATimeZonePickerView(row: selectedRow)) {
                            HStack {
                                Text(selectedRow.timeZone.emoji(date:  now))
                                ASACalendarTimeZoneCell(timeZone: selectedRow.timeZone, now: now)
                            }
                        }
                    } else {
                        HStack {
                            Text(selectedRow.calendar.timeZone(location:  self.currentLocation).emoji(date:  now))
                            ASACalendarTimeZoneCell(timeZone: selectedRow.calendar.timeZone(location:  self.currentLocation), now: now)
                        }
                    }
                    if selectedRow.calendar.supportsLocations() {
                        ASACalendarLocationCell(selectedRow: self.selectedRow, now: self.now, currentLocation: self.currentLocation, currentPlacemark: self.currentPlacemark)
                    }
                }
                if selectedRow.calendar.LDMLDetails().count > 0 {
                    Section(header:  Text("HEADER_Date")) {
                        ForEach(selectedRow.details(), id: \.name) {
                            detail
                            in
                            ASACalendarDetailCell(title: NSLocalizedString(detail.name, comment: ""), detail: self.selectedRow.dateString(now: self.now, LDMLString: detail.geekCode, defaultLocation: self.currentLocation))
                        }
                    }
                }
                if selectedRow.calendar.supportsEventDetails() {
                    Section(header:  Text("HEADER_EVENTS")) {
                        ForEach(selectedRow.calendar.eventDetails(date: now, location: currentLocation), id: \.key) {
                            detail
                            in
                            ASACalendarDetailCell(title: NSLocalizedString(detail.key, comment: ""), detail: detail.value == nil ? "—" : DateFormatter.localizedString(from: detail.value!, dateStyle: .none, timeStyle: .medium), systemIconName: detail.key.systemIconName())
                        }
                    }
                }
                Section(header:  Text("HEADER_Other")) {
                    ASACalendarDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: DateFormatter.localizedString(from: self.selectedRow.calendar.transitionToNextDay(now: self.now, location: currentLocation, timeZone: self.selectedRow.timeZone), dateStyle: .full, timeStyle: .full))
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
        ASACalendarDetailView(selectedRow: ASARow.generic(), now: Date(), currentLocation: CLLocation.NullIsland)
    }
}
