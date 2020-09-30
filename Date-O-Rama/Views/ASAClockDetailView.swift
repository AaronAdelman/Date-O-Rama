//
//  ASAClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASAClockDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date

    var shouldShowTime:  Bool

    @EnvironmentObject var userData:  ASAUserData

    @State private var showingActionSheet = false

    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var body: some View {
        List {
            ASAClockDetailEditingSection(selectedRow: selectedRow, now: now, shouldShowTime: shouldShowTime)
            
            //            if selectedRow.calendar.LDMLDetails.count > 0 {
            //                Section(header:  Text("HEADER_Date")) {
            //                    ForEach(selectedRow.LDMLDetails(), id: \.name) {
            //                        detail
            //                        in
            //                        ASAClockDetailCell(title: NSLocalizedString(detail.name, comment: ""), detail: self.selectedRow.dateTimeString(now: self.now, LDMLString: detail.geekCode))
            //                    }
            //                } // Section
            //            }
            //
            //            Section(header:  Text("HEADER_Other")) {
            //                ASAClockDetailCell(title: NSLocalizedString("ITEM_NEXT_DATE_TRANSITION", comment: ""), detail: DateFormatter.localizedString(from: self.selectedRow.startOfNextDay(date: now), dateStyle: .full, timeStyle: .full))
            //                ASAClockDetailCell(title: NSLocalizedString("ITEM_NEXT_DAY", comment: ""), detail: self.selectedRow.dateString(now: self.selectedRow.startOfNextDay(date:  now).addingTimeInterval(1)))
            //            } // Section

            Section(header:  Text("")){
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingActionSheet = true
                    }) {
                        Text("Delete This Clock").foregroundColor(Color.red).frame(alignment: .center)
                    }
                    Spacer()
                } // HStack
                .actionSheet(isPresented: self.$showingActionSheet) {
                    ActionSheet(title: Text("Are you sure you want to delete this clock?"), buttons: [
                        .destructive(Text("Delete This Clock")) {
                            let index = self.userData.mainRows.firstIndex(of: selectedRow)
                            if index != nil {
                                self.userData.mainRows.remove(at: index!)
                                self.userData.savePreferences(code: .clocks)
                                self.dismiss()
                            }
                        },
                        .cancel()
                    ])
                }
            } // Section
        }
        .navigationBarTitle(Text(selectedRow.dateString(now: self.now) ))
    }
} // struct ASAClockDetailView

struct ASAClockDetailEditingSection:  View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    var shouldShowTime:  Bool

    var body: some View {
        Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
            NavigationLink(destination: ASACalendarChooserView(row: self.selectedRow, tempCalendarCode: self.selectedRow.calendar.calendarCode)) {
                HStack {
                    Text(verbatim: "🗓")
                    ASAClockDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                }
            }
            if selectedRow.supportsLocales() {
                NavigationLink(destination: ASALocaleChooserView(row: selectedRow, tempLocaleIdentifier: selectedRow.localeIdentifier)) {
                    HStack {
                        Text(verbatim:  selectedRow.localeIdentifier.localeCountryCodeFlag())
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                    }
                }
            }
            if selectedRow.calendar.supportsDateFormats {
                NavigationLink(destination: ASADateFormatChooserView(row: selectedRow, tempMajorDateFormat: selectedRow.majorDateFormat, tempDateGeekFormat: selectedRow.dateGeekFormat, calendarCode: selectedRow.calendar.calendarCode)) {
                    ASAClockDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                }
            }
            if selectedRow.calendar.supportsTimeFormats && shouldShowTime {
                NavigationLink(destination: ASATimeFormatChooserView(row: selectedRow, tempMajorTimeFormat: selectedRow.majorTimeFormat, tempTimeGeekFormat: selectedRow.timeGeekFormat, calendarCode: selectedRow.calendar.calendarCode)) {
                    ASAClockDetailCell(title:  NSLocalizedString("HEADER_Time_format", comment: ""), detail: selectedRow.majorTimeFormat.localizedItemName())
                }
            }

            if selectedRow.calendar.supportsTimeZones || selectedRow.calendar.supportsLocations {
                ASATimeZoneCell(timeZone: selectedRow.effectiveTimeZone, now: now)

                NavigationLink(destination:  ASALocationChooserView(locatedObject:  selectedRow, tempLocationData: ASALocationData())) {
                    ASALocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, locationData: self.selectedRow.locationData)
                }
            }
        } // Section
    } // var body
} // struct ASAClockDetailEditingSection

struct ASAClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockDetailView(selectedRow: ASARow.generic(), now: Date(), shouldShowTime: true)
    }
}
