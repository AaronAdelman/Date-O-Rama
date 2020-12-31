//
//  ASAEventCalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventCalendarDetailView: View {
    @ObservedObject var selectedEventCalendar:  ASAEventCalendar

    @EnvironmentObject var userData:  ASAUserData

    @State private var showingActionSheet = false

    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    var body: some View {
        List {
        ASAEventCalendarDetailSection(selectedEventCalendar: self.selectedEventCalendar)

        Section(header:  Text("")) {
            HStack {
                Spacer()
                Button(action: {
                    self.showingActionSheet = true
                }) {
                    Text("Delete This Internal Event Calendar").foregroundColor(Color.red).frame(alignment: .center)
                }
                Spacer()
            } // HStack
            .actionSheet(isPresented: self.$showingActionSheet) {
                ActionSheet(title: Text("Are you sure you want to delete this internal event calendar?"), buttons: [
                    .destructive(Text("Delete This Internal Event Calendar")) {
                        let index = self.userData.ASAEventCalendars.firstIndex(where: {$0.uuid == selectedEventCalendar.uuid})
                        if index != nil {
                            self.userData.ASAEventCalendars.remove(at: index!)
                            self.userData.savePreferences(code: .events)
                            self.dismiss()
                        }
                    },
                    .cancel()
                ])
            }
        } // Section
        }
    } // var body
} // struct ASAEventCalendarDetailView

struct ASAEventCalendarDetailSection:  View {
    @ObservedObject var selectedEventCalendar:  ASAEventCalendar

    var body: some View {
        Section {
            NavigationLink(destination:  ASAEventsFileChooser(eventCalendar:  self.selectedEventCalendar, tempInternalEventCode: self.selectedEventCalendar.fileName)) {
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
                    ASATimeZoneCell(timeZone: selectedEventCalendar.locationData.timeZone, now: Date())
                } // VStack
            }
        } // Section
    } // var body
} // struct ASAEventCalendarDetailSection


// MARK:  -

struct ASAEventCalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        ASAEventCalendarDetailView(selectedEventCalendar: ASAEventCalendarFactory.eventCalendar(eventSourceCode: "Solar events")!)
        ASAEventCalendarDetailView(selectedEventCalendar: ASAEventCalendar.eventCalendar(eventsFileName: "Solar events")!)
    }
} // struct ASAEventCalendarDetailView_Previews
