//
//  ASAClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation
import EventKit

struct ASAClockDetailView: View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    
    var shouldShowTime:  Bool
    
    @EnvironmentObject var userData:  ASAUserData
    
    @State private var showingActionSheet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var deleteable:  Bool
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var forAppleWatch:  Bool
    
    var body: some View {
        NavigationView {
            List {
                ASAClockDetailEditingSection(selectedRow: selectedRow, now: now, shouldShowTime: shouldShowTime, forAppleWatch: forAppleWatch)
                
                if deleteable {
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
                                    let index = self.userData.mainRows.firstIndex(where: {$0.uuid == selectedRow.uuid})
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
            } // List
            .navigationTitle("Clock Details")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
} // struct ASAClockDetailView


// MARK:  -

struct ASAClockDetailEditingSection:  View {
    @ObservedObject var selectedRow:  ASARow
    var now:  Date
    var shouldShowTime:  Bool
    var forAppleWatch:  Bool
    
    fileprivate func dateFormats() -> [ASADateFormat] {
        if forAppleWatch {
            return selectedRow.calendar.supportedWatchDateFormats
        }
        
        return selectedRow.calendar.supportedDateFormats
    }
    
    var body: some View {
        Group {
            Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                NavigationLink(destination: ASACalendarChooserView(row: self.selectedRow, tempCalendarCode: self.selectedRow.calendar.calendarCode)) {
                    HStack {
                        ASAClockDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName)
                    }
                }
                
                if selectedRow.calendar.supportsTimeZones || selectedRow.calendar.supportsLocations {
                    NavigationLink(destination:  ASALocationChooserView(clock:  selectedRow, tempLocationData: ASALocation())) {
                        VStack {
                            ASALocationCell(usesDeviceLocation: self.selectedRow.usesDeviceLocation, locationData: self.selectedRow.locationData)
                            Spacer()
                            ASATimeZoneCell(timeZone: selectedRow.locationData.timeZone, now: now)
                        } // VStack
                    }
                }
                
                if selectedRow.supportsLocales {
                    NavigationLink(destination: ASALocaleChooserView(row: selectedRow, tempLocaleIdentifier: selectedRow.localeIdentifier)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail:  selectedRow.localeIdentifier.localeCountryCodeFlag + " " + selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier)
                    }
                }
                if selectedRow.calendar.supportsDateFormats && dateFormats().count > 1 {
                    NavigationLink(destination: ASADateFormatChooserView(row: selectedRow, tempDateFormat: selectedRow.dateFormat, calendarCode: selectedRow.calendar.calendarCode, forAppleWatch: forAppleWatch)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.dateFormat.localizedItemName)
                    }
                }
                if selectedRow.calendar.supportsTimeFormats && shouldShowTime && selectedRow.calendar.supportedTimeFormats.count > 1 {
                    NavigationLink(destination: ASATimeFormatChooserView(row: selectedRow, tempTimeFormat: selectedRow.timeFormat, calendarCode: selectedRow.calendar.calendarCode)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Time_format", comment: ""), detail: selectedRow.timeFormat.localizedItemName)
                    }
                }
            } // Section
            
            if !forAppleWatch {
                ASABuiltInEventCalendarsEditingSection(selectedRow: selectedRow, builtInEventCalendarFileNames: ASAEventCalendar.builtInEventCalendarFileNames(calendarCode: selectedRow.calendar.calendarCode))
                
                ASAICalendarEventCalendarsEditingSection(selectedRow: selectedRow)
            }
        } // Group
    } // var body
} // struct ASAClockDetailEditingSection


// MARK:  -

struct ASABuiltInEventCalendarsEditingSection:  View {
    @ObservedObject var selectedRow:  ASARow
    var builtInEventCalendarFileNames:  Array<String>

    var body:  some View {
        if builtInEventCalendarFileNames.count > 0 {
            Section(header:  Text(NSLocalizedString("HEADER_BuiltInEventCalendars", comment: ""))) {
                ForEach(builtInEventCalendarFileNames, id:
                            \.self) {
                    fileName
                    in
                    ASABuiltInEventCalendarCell(selectedRow: selectedRow, fileName: fileName)
                        .onTapGesture {
                            if selectedRow.builtInEventCalendars.map({$0.fileName}).contains(fileName) {
                                let fileNameIndex = selectedRow.builtInEventCalendars.firstIndex(where: {$0.fileName == fileName})
                                if fileNameIndex != nil {
                                    selectedRow.builtInEventCalendars.remove(at: fileNameIndex!)
                                }
                            } else {
                                let eventCalendar: ASAEventCalendar = ASAEventCalendar(fileName: fileName)
                                if eventCalendar.eventsFile != nil {
                                    selectedRow.builtInEventCalendars.append(eventCalendar)
                                }
                            }
                        }
                }
            } // Section
        } else {
            EmptyView()
        }
    } // var body
} // struct ASABuiltInEventCalendarsEditingSection


// MARK:  -

struct ASAICalendarEventCalendarsEditingSection:  View {
    @ObservedObject var selectedRow:  ASARow
    var iCalendarEventCalendars:  Array<EKCalendar> = ASAEKEventManager.shared.allEventCalendars().sorted(by: {$0.title < $1.title})

    var body:  some View {
        if selectedRow.calendar.usesISOTime && selectedRow.isICalendarCompatible {
            Section(header:  Text(NSLocalizedString("HEADER_iCalendarEventCalendars", comment: ""))) {
                ForEach(iCalendarEventCalendars, id:
                        \.calendarIdentifier) {
                    calendar
                    in
                    ASAICalendarEventCalendarCell(selectedRow: selectedRow, title: calendar.title, color: calendar.color)
                        .onTapGesture {
                            if selectedRow.iCalendarEventCalendars.map({$0.title}).contains(calendar.title) {
                                let fileNameIndex = selectedRow.iCalendarEventCalendars.firstIndex(where: {$0.title == calendar.title})
                                if fileNameIndex != nil {
                                    selectedRow.iCalendarEventCalendars.remove(at: fileNameIndex!)
                                }
                            } else {
                                let desiredEventCalendar: EKCalendar? = ASAEKEventManager.shared.allEventCalendars().first(where: {eventCalendar
                                                                                                                                    in
                                                                                                                            eventCalendar.title == calendar.title})
                                if desiredEventCalendar != nil {
                                    selectedRow.iCalendarEventCalendars.append(desiredEventCalendar!)
                                }
                            }
                        }
                }
            } // Section
        } else {
            EmptyView()
        }
    } // var body
}


// MARK:  -

struct ASABuiltInEventCalendarCell:  View {
    @ObservedObject var selectedRow:  ASARow

    var fileName:  String

    var body: some View {
        let eventCalendar = ASAEventCalendar(fileName: fileName)
        let eventSpecifications = eventCalendar.eventsFile?.eventSpecifications ?? []
        let defaultLocaleIdentifier = Locale.current.identifier
        let eventsFileDefaultLocaleIdentifier = eventCalendar.eventsFile?.defaultLocale ?? defaultLocaleIdentifier
        let eventTitles = eventSpecifications.map {
            $0.eventTitle(requestedLocaleIdentifier: defaultLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocaleIdentifier) ?? ""
        }
        let joinedEventTitles = ListFormatter.localizedString(byJoining: eventTitles)

        HStack(alignment: .top) {
            ASACheckmarkCircleSymbol(on: selectedRow.builtInEventCalendars.map({$0.fileName}).contains(fileName))                    .foregroundColor(eventCalendar.color)
            VStack(alignment: .leading) {
                Text(verbatim: eventCalendar.eventCalendarNameWithoutPlaceName(localeIdentifier: Locale.current.identifier))
                    .font(.headline)
                if eventCalendar.error != nil {
                    Text(verbatim: eventCalendar.error!.localizedDescription)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Text(joinedEventTitles)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(10)
                    .truncationMode(.tail)
            } // VStack
            Spacer()
            
            let formatString : String = NSLocalizedString("n events", comment: "")
            let resultString : String = String.localizedStringWithFormat(formatString, eventCalendar.eventsFile!.eventSpecifications.count)
            Text(resultString)
                .foregroundColor(.secondary)
        } // HStack
    } //var body
} // struct ASABuiltInEventCalendarCell


// MARK:  -

struct ASAICalendarEventCalendarCell:  View {
    @ObservedObject var selectedRow:  ASARow

    var title:  String
    var color:  Color

    var body: some View {
        HStack {
            ASACheckmarkCircleSymbol(on: selectedRow.iCalendarEventCalendars.map({$0.title}).contains(title))
                .foregroundColor(color)
            Text(verbatim: NSLocalizedString(title, comment: "")).font(.headline)
        }
    }
}


// MARK:  -

struct ASAClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockDetailView(selectedRow: ASARow.generic, now: Date(), shouldShowTime: true, deleteable: true, forAppleWatch: true)
    }
}
