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
    @ObservedObject var selectedClock:  ASAClock
    var location: ASALocation
    var usesDeviceLocation: Bool
    var now:  Date
    
    var shouldShowTime:  Bool
    
    @EnvironmentObject var userData:  ASAUserData
    
    @State private var showingActionSheet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var deletable:  Bool
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var forAppleWatch:  Bool
    
    var tempLocation: ASALocation
    
    var body: some View {
        NavigationView {
            List {
                ASAClockDetailEditingSection(selectedClock: selectedClock, location: location, usesDeviceLocation: usesDeviceLocation, now: now, shouldShowTime: shouldShowTime, forAppleWatch: forAppleWatch, tempLocation: tempLocation)
                
                if deletable {
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
                                    self.userData.removeMainClock(uuid: selectedClock.uuid)
                                    self.dismiss()
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
    @ObservedObject var selectedClock:  ASAClock
    var location: ASALocation
    var usesDeviceLocation: Bool
    var now:  Date
    var shouldShowTime:  Bool
    var forAppleWatch:  Bool
    var tempLocation: ASALocation
    
    fileprivate func dateFormats() -> [ASADateFormat] {
        if forAppleWatch {
            return selectedClock.calendar.supportedWatchDateFormats
        }
        
        return selectedClock.calendar.supportedDateFormats
    }
    
    var body: some View {
        Group {
            Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                NavigationLink(destination: ASACalendarChooserView(clock: self.selectedClock, location: location, usesDeviceLocation: usesDeviceLocation, tempCalendarCode: self.selectedClock.calendar.calendarCode)) {
                    ASAClockDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedClock.calendar.calendarCode.localizedName)
                }
                
                if selectedClock.calendar.supportsTimeZones || selectedClock.calendar.supportsLocations {
                    //                    NavigationLink(destination:  ASALocationChooserView(clock:  selectedClock, tempLocationData: tempLocation)) {
                    VStack {
                        ASALocationCell(usesDeviceLocation: usesDeviceLocation, locationData: location)
                        Spacer()
                        ASATimeZoneCell(timeZone: location.timeZone, now: now)
                    } // VStack
                    //                    }
                }
                
                if selectedClock.supportsLocales {
                    NavigationLink(destination: ASALocaleChooserView(clock: selectedClock, location: location, tempLocaleIdentifier: selectedClock.localeIdentifier)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail:  selectedClock.localeIdentifier.localeCountryCodeFlag + " " + selectedClock.localeIdentifier.asSelfLocalizedLocaleIdentifier)
                    }
                }
                if selectedClock.calendar.supportsDateFormats && dateFormats().count > 1 {
                    NavigationLink(destination: ASADateFormatChooserView(clock: selectedClock, location: location, tempDateFormat: selectedClock.dateFormat, calendarCode: selectedClock.calendar.calendarCode, forAppleWatch: forAppleWatch)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedClock.dateFormat.localizedItemName)
                    }
                }
                if selectedClock.calendar.supportsTimeFormats && shouldShowTime && selectedClock.calendar.supportedTimeFormats.count > 1 {
                    NavigationLink(destination: ASATimeFormatChooserView(clock: selectedClock, location: location, tempTimeFormat: selectedClock.timeFormat, calendarCode: selectedClock.calendar.calendarCode)) {
                        ASAClockDetailCell(title:  NSLocalizedString("HEADER_Time_format", comment: ""), detail: selectedClock.timeFormat.localizedItemName)
                    }
                }
            } // Section
            
            if !forAppleWatch {
                ASABuiltInEventCalendarsEditingSection(selectedClock: selectedClock, builtInEventCalendarFileNames: ASAEventCalendar.builtInEventCalendarFileRecords(calendarCode: selectedClock.calendar.calendarCode))
                
                ASAICalendarEventCalendarsEditingSection(selectedClock: selectedClock, location: location, usesDeviceLocation: usesDeviceLocation)
            }
        } // Group
    } // var body
} // struct ASAClockDetailEditingSection


// MARK:  -

struct ASABuiltInEventCalendarsEditingSection:  View {
    @ObservedObject var selectedClock:  ASAClock
    var builtInEventCalendarFileNames:  ASABuiltInEventCalendarFileData
    
    @State var selection = ASARegionCodeRegion.allRegions
    
    var body:  some View {
        if builtInEventCalendarFileNames.records.count > 0 {
            Section(header:  Text(NSLocalizedString("HEADER_BuiltInEventCalendars", comment: ""))) {
                if selectedClock.calendar.calendarCode == .Gregorian {
                    Picker(selection: $selection, label:
                            Text("Show built-in event calendars:"), content: {
                        ForEach(ASARegionCodeRegion.allCases) {
                            Text($0.text).tag($0)
                        }
                    })
                }
                
                let records = selectedClock.calendar.calendarCode == .Gregorian ? builtInEventCalendarFileNames.records.filter({$0.fileName.regionCodeRegion == selection}) : builtInEventCalendarFileNames.records
                ForEach(records, id: \.fileName) {
                    record
                    in
                    ASABuiltInEventCalendarCell(selectedClock: selectedClock, record: record)
                        .onTapGesture {
                            if selectedClock.builtInEventCalendars.map({$0.fileName}).contains(record.fileName) {
                                let fileNameIndex = selectedClock.builtInEventCalendars.firstIndex(where: {$0.fileName == record.fileName})
                                if fileNameIndex != nil {
                                    selectedClock.builtInEventCalendars.remove(at: fileNameIndex!)
                                }
                            } else {
                                let eventCalendar: ASAEventCalendar = ASAEventCalendar(fileName: record.fileName)
                                if eventCalendar.eventsFile != nil {
                                    selectedClock.builtInEventCalendars.append(eventCalendar)
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
    @ObservedObject var selectedClock:  ASAClock
    var location: ASALocation
    var usesDeviceLocation: Bool
    var iCalendarEventCalendars:  Array<EKCalendar> = ASAEKEventManager.shared.allEventCalendars().sorted(by: {$0.title < $1.title})
    
    var body: some View {
        if selectedClock.supportsExternalEvents(location: location, usesDeviceLocation: usesDeviceLocation) {
            Section(header:  Text(NSLocalizedString("HEADER_iCalendarEventCalendars", comment: ""))) {
                ForEach(iCalendarEventCalendars, id:
                            \.calendarIdentifier) {
                    calendar
                    in
                    ASAICalendarEventCalendarCell(selectedClock: selectedClock, title: calendar.title, color: calendar.color)
                        .onTapGesture {
                            if selectedClock.iCalendarEventCalendars.map({$0.title}).contains(calendar.title) {
                                let fileNameIndex = selectedClock.iCalendarEventCalendars.firstIndex(where: {$0.title == calendar.title})
                                if fileNameIndex != nil {
                                    selectedClock.iCalendarEventCalendars.remove(at: fileNameIndex!)
                                }
                            } else {
                                let desiredEventCalendar: EKCalendar? = ASAEKEventManager.shared.allEventCalendars().first(where: {eventCalendar
                                    in
                                    eventCalendar.title == calendar.title})
                                if desiredEventCalendar != nil {
                                    selectedClock.iCalendarEventCalendars.append(desiredEventCalendar!)
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
    @ObservedObject var selectedClock:  ASAClock
    
    var record: ASABuiltInEventCalendarFileRecord
    
    var body: some View {
        HStack(alignment: .top) {
            ASACheckmarkCircleSymbol(on: selectedClock.builtInEventCalendars.map({$0.fileName}).contains(record.fileName))
                .foregroundColor(record.color)
            VStack(alignment: .leading) {
                HStack {
                    let emoji: String? = record.emoji
                    if emoji != nil {
                        Text(verbatim: emoji!)
                    }
                    Text(verbatim: record.eventCalendarNameWithoutPlaceName)
                        .font(.headline)
                }
            } // VStack
            Spacer()
            
            let formatString : String = NSLocalizedString("n events", comment: "")
            let resultString : String = String.localizedStringWithFormat(formatString, record.numberOfEventSpecifications)
            Text(resultString)
                .foregroundColor(.secondary)
        } // HStack
    } //var body
} // struct ASABuiltInEventCalendarCell


// MARK:  -

struct ASAICalendarEventCalendarCell:  View {
    @ObservedObject var selectedClock:  ASAClock
    
    var title:  String
    var color:  Color
    
    var body: some View {
        HStack {
            ASACheckmarkCircleSymbol(on: selectedClock.iCalendarEventCalendars.map({$0.title}).contains(title))
                .foregroundColor(color)
            Text(verbatim: NSLocalizedString(title, comment: "")).font(.headline)
        }
    }
}


// MARK:  -

struct ASAClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockDetailView(selectedClock: ASAClock.generic, location: .NullIsland, usesDeviceLocation: false, now: Date(), shouldShowTime: true, deletable: true, forAppleWatch: true, tempLocation: ASALocation.NullIsland)
    }
}
