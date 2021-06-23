//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit


// MARK:  -

struct ASAClockCell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    //    var shouldShowTimeToNextDay:  Bool
    
    var forComplications:  Bool
    
    var body: some View {
        #if os(watchOS)
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
        #else
        let EDGE_INSETS_1: EdgeInsets = EdgeInsets(top: 4.0, leading: 16.0, bottom: 4.0, trailing: 16.0)
        let MINIMUM_HEIGHT: CGFloat = 40.0
        
        if forComplications {
            NavigationLink(
                destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: false, deleteable: false, forAppleWatch: true)
                    .onReceive(processedRow.row.objectWillChange) { _ in
                        // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                        let userData = ASAUserData.shared
                        userData.objectWillChange.send()
                        userData.savePreferences(code: .complications)
                    }
            ) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .padding(EDGE_INSETS_1)
                    .colorScheme(.dark)
            }
        } else {
            NavigationLink(
                destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                    .onReceive(processedRow.row.objectWillChange) { _ in
                        // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                        let userData = ASAUserData.shared
                        userData.objectWillChange.send()
                        userData.savePreferences(code: .clocks)
                    }
            ) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications: forComplications)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .padding(EDGE_INSETS_1)
            }
        }
        #endif
    } // var body
} // struct ASAClockCell


// MARK: -

struct ASAClockCellBody:  View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    //    var shouldShowTimeToNextDay:  Bool
    var canSplitTimeFromDate:  Bool
    
    var forComplications:  Bool
    
    //    @State var shouldShowEvents:  ASAClockCellEventVisibility = .next
    
    #if os(watchOS)
    let compact = true
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif
    
    fileprivate func shouldShowMiniClock() -> Bool {
        return !compact && shouldShowTime && processedRow.hasValidTime
    } //func shouldShowMiniClock() -> Bool
    
    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.row.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if shouldShowCalendar {
                    ASAClockCellText(string:  processedRow.calendarString, font:  .subheadlineMonospacedDigit, lineLimit:  1)
                }
                
                if canSplitTimeFromDate {
                    if shouldShowFormattedDate {
                        #if os(watchOS)
                        let LINE_LIMIT = 1
                        #else
                        let LINE_LIMIT = 2
                        #endif
                        ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  LINE_LIMIT)
                    }
                    if shouldShowTime {
                        HStack {
                            if !shouldShowPlaceName && processedRow.usesDeviceLocation {
                                ASALocationSymbol()
                            }
                            
                            let timeString: String = processedRow.timeString ?? ""
                            let string = (processedRow.supportsTimeZones && shouldShowTimeZone) ? timeString + " · " + processedRow.timeZoneString : timeString
                            ASAClockCellText(string:  string, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                        }
                    }
                } else {
                    HStack {
                        if !shouldShowPlaceName && processedRow.usesDeviceLocation {
                            ASALocationSymbol()
                        }
                        
                        if shouldShowFormattedDate {
                            ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                        }
                    }
                }
                
                ASAPlaceSubcell(processedRow:  processedRow, shouldShowPlaceName:  shouldShowPlaceName
                )
            } // VStack
            
            #if os(watchOS)
            if processedRow.events.count > 0 {
                NavigationLink(destination:  ASAWatchEventsList(processedRow:  processedRow, now: now)) {
                    ASACompactForwardChevronSymbol()
                }
            }
            #else
            if processedRow.supportsTimes {
                if processedRow.supportsMonths && shouldShowMiniCalendar {
                    Spacer()
                    ASAMiniCalendarView(daysPerWeek:  processedRow.daysPerWeek ?? 1, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier, calendarCode: processedRow.calendarCode, weekdaySymbols: processedRow.veryShortStandaloneWeekdaySymbols)
                }
                
                if shouldShowMiniClock() {
                    Spacer()
                    ASAMiniClockView(processedRow:  processedRow, numberFormatter: numberFormatter())
                }
            }
            
//            Spacer().frame(width:  16.0)
//            #endif
//
//            #if os(watchOS)
//            #else
//            Spacer()
//            ASAForwardChevronSymbol()
////                .foregroundColor(.white)
            #endif
        } // HStack
    } // var body
} // struct ASAClockCellBodyPublished<ASAClockCellEventVisibility>.Pub


// MARK:  -

struct ASAClockEventsSubcell: View {
    var processedRow:  ASAProcessedRow
    var forComplications: Bool
    @Binding var now:  Date
    @State var eventVisibility: ASAClockCellEventVisibility = .next

    var body: some View {
        #if os(watchOS)
        EmptyView()
        #else
        if processedRow.events.count > 0 && !forComplications {
            Picker(selection: $eventVisibility, label: Text("")) {
                ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                    possibility
                    in
                    Text(possibility.emoji)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            ASAClockEventsForEach(processedRow: processedRow, visibility: eventVisibility, now: $now)
        }
        #endif
    } // var body
} // struct ASAClockEventsSubcell


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedRow
    var visibility:  ASAClockCellEventVisibility
    @Binding var now:  Date
    
    static let genericRow = ASARow.generic
    
    var body: some View {
        let events:  Array<ASAEventCompatible> = {
            switch self.visibility {
            case .allDay:
                return processedRow.events.allDayOnly
                
            case .future:
                return processedRow.events.futureOnly(now: now)
                
            case .all:
                return processedRow.events
                
            case .next:
                return processedRow.events.nextEvents(now: now)
                
            case .none:
                return []
            } // switch visibility
        }()
        
        ForEach(events, id: \.eventIdentifier) {
            event
            in
            let primaryRow: ASARow = processedRow.row
            let secondaryRow = ASAClockEventsForEach.genericRow
            let shouldShowSecondaryDates = processedRow.calendarCode != .Gregorian
            let rangeStart: Date = processedRow.startOfDay
            let rangeEnd: Date = processedRow.startOfNextDay
            
            ASALinkedEventCell(event: event, primaryRow: primaryRow, secondaryRow: secondaryRow, eventsViewShouldShowSecondaryDates: shouldShowSecondaryDates, now: $now, rangeStart: rangeStart, rangeEnd: rangeEnd, isForClock: true)
        } // ForEach
    } // var body
} // struct ASAClockEventsForEach


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic, now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: false)
    }
} // struct ASAClockCell_Previews
