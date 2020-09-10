//
//  ASANewClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/09/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASANewClockDetailView: View {
    @State var selectedRow:  ASARow = ASARow.generic()

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    let HORIZONTAL_PADDING:  CGFloat = 20.0

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer().frame(width:  HORIZONTAL_PADDING)

                    Button("Cancel") {
                        self.showingActionSheet = true
                    }

                    Spacer()

                    Text("New Clock").bold()

                    Spacer()

                    Button("Add") {
                        let userData = ASAUserData.shared()
                        userData.mainRows.insert(self.selectedRow, at: 0)
                        userData.savePreferences(code: .clocks)

                        let app = UIApplication.shared
                        let appDelegate = app.delegate as! AppDelegate
                        appDelegate.sendUserData(appDelegate.session)

                        self.dismiss()
                    }

                    Spacer().frame(width:  HORIZONTAL_PADDING)
                } // HStack

                List {
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
                        if selectedRow.calendar.supportsTimeFormats {
                            NavigationLink(destination: ASATimeFormatChooserView(row: selectedRow, tempMajorTimeFormat: selectedRow.majorTimeFormat, tempTimeGeekFormat: selectedRow.timeGeekFormat, calendarCode: selectedRow.calendar.calendarCode)) {
                                ASAClockDetailCell(title:  NSLocalizedString("HEADER_Time_format", comment: ""), detail: selectedRow.majorTimeFormat.localizedItemName())
                            }
                        }

                        if selectedRow.calendar.supportsTimeZones || selectedRow.calendar.supportsLocations {
                            ASATimeZoneCell(timeZone: selectedRow.effectiveTimeZone, now: Date())

                            NavigationLink(destination:  ASALocationChooserView(locatedObject:  selectedRow, tempLocationData: ASALocationData())) {
                                ASALocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, locationData: self.selectedRow.locationData)
                            }
                        }
                    }
                }
            } // VStack
                .navigationBarTitle(Text(selectedRow.dateString(now: Date())))
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: self.$showingActionSheet) {
            ActionSheet(title: Text("Are you sure you want to delete this new clock?"), buttons: [
                .destructive(Text("Cancel Changes")) { self.dismiss() },
                .default(Text("Continue Editing")) {  }
            ])
        }
    } // var body
} // struct ASANewClockDetailView

struct ASANewClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewClockDetailView(selectedRow: ASARow.generic())
    }
}
