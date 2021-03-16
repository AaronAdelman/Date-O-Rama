//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit

enum ASAClockCellEventVisibility:  String, CaseIterable {
    case none
    case allDay
    case next
    case future
    case all
    
    #if os(watchOS)
    static var watchCases:  Array<ASAClockCellEventVisibility> = [allDay, next, future, all]
    
    var text:  String {
        var raw:  String = ""
        switch self {
        case .none:
            raw = "ASAClockCellEventVisibility.none"
        case .allDay:
            raw = "ASAClockCellEventVisibility.allDay"
        case .next:
            raw = "ASAClockCellEventVisibility.next"
        case .future:
            raw = "ASAClockCellEventVisibility.future"
        case .all:
            raw = "ASAClockCellEventVisibility.all"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    #else
    var emoji:  String {
        switch self {
        case .none:
            return "0️⃣"
            
        case .allDay:
            return "📅"
            
        case .next:
            return "🔽"
            
        case .future:
            return "⬇️"
            
        case .all:
            return "↕️"
        } // switch self
    } // var emoji
    #endif
} // enum ASAClockCellEventVisibility


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
        HStack {
            ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
            Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
        } // HStack
        #else
        let EDGE_INSETS_1: EdgeInsets = EdgeInsets(top: 4.0, leading: 16.0, bottom: 4.0, trailing: 16.0)
        let MINIMUM_HEIGHT: CGFloat = 40.0
        let SPACER_WIDTH: CGFloat = 16.0
        
        if forComplications {
            ZStack {
                HStack {
                    ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
                        .frame(minHeight:  MINIMUM_HEIGHT)
                        .padding(EDGE_INSETS_1)
                    
                    ASAForwardChevronSymbol()
                        .foregroundColor(.white)
                    Spacer()
                        .frame(width:  SPACER_WIDTH)
                } // HStack
                .colorScheme(.dark)
                NavigationLink(
                    destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: false, deleteable: false, forAppleWatch: true)
                        .onReceive(processedRow.row.objectWillChange) { _ in
                            // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                            let userData = ASAUserData.shared
                            userData.objectWillChange.send()
                            userData.savePreferences(code: .complications)
                        }
                ) {
                }
                .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
            } // ZStack
        } else {
            ZStack {
                HStack {
                    ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications: forComplications)
                        .frame(minHeight:  MINIMUM_HEIGHT)
                        .padding(EDGE_INSETS_1)
                    
                    ASAForwardChevronSymbol()
                        .foregroundColor(.white)
                    Spacer()
                        .frame(width:  SPACER_WIDTH)
                } // HStack
                .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour, calendarType: processedRow.calendarType, month:  processedRow.month, latitude:  processedRow.latitude, calendarCode:  processedRow.calendarCode))
                .background(ASASkyGradient(processedRow: processedRow))
                NavigationLink(
                    destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                        .onReceive(processedRow.row.objectWillChange) { _ in
                            // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                            let userData = ASAUserData.shared
                            userData.objectWillChange.send()
                            userData.savePreferences(code: .clocks)
                        }
                ) {
                }
                .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
            } // ZStack
            .listRowInsets(.zero)

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
        VStack(alignment:  .leading) {
            HStack {
                ASAClockMainSubcell(processedRow: processedRow, shouldShowCalendar: shouldShowCalendar, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: canSplitTimeFromDate)
                
                if (processedRow.supportsMonths || shouldShowTime) {
                    Spacer()
                }
                
                #if os(watchOS)
                if processedRow.events.count > 0 {
                    NavigationLink(destination:  ASAWatchEventsList(processedRow:  processedRow, now: now)) {
                        Image(systemName: "chevron.forward.circle.fill")
                    }
                }
                #else
                if processedRow.supportsTimes {
                    if processedRow.supportsMonths && shouldShowMiniCalendar {
                        ASAMiniCalendarView(daysPerWeek:  processedRow.daysPerWeek ?? 1, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier, calendarCode: processedRow.calendarCode, weekdaySymbols: processedRow.veryShortStandaloneWeekdaySymbols)
                    }
                    
                    if shouldShowMiniClock() {
                        Spacer()
                        
                        ASAMiniClockView(processedRow:  processedRow, numberFormatter: numberFormatter())
                    }
                }
                
                Spacer().frame(width:  16.0)
                #endif
            } // HStack
            
//            ASAClockEventsSubcell(processedRow: processedRow, forComplications: forComplications, now: $now, eventVisibility: processedRow.row.eventVisibility)
        } // VStack
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
            HStack {
                Text("Show Events")
                Picker(selection: $eventVisibility, label: Text("")) {
                    ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                        possibility
                        in
                        Text(possibility.emoji)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            ASAClockEventsForEach(processedRow: processedRow, visibility: eventVisibility, now: $now)
        } else {
            EmptyView()
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
                return processedRow.events.futureOnly
                
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
            let secondaryRow = ASAClockEventsForEach.genericRow
            let shouldShowSecondaryDates = processedRow.calendarCode != .Gregorian
            

            #if os(watchOS)
            ASAEventCell(event: event, primaryRow: processedRow.row, secondaryRow: secondaryRow, eventsViewShouldShowSecondaryDates: shouldShowSecondaryDates, forClock: true, now: $now, rangeStart: processedRow.startOfDay, rangeEnd:  processedRow.startOfNextDay)
            #else
            ASALinkedEventCell(event: event, primaryRow: processedRow.row, secondaryRow: secondaryRow, eventsViewShouldShowSecondaryDates: shouldShowSecondaryDates, now: $now, rangeStart: processedRow.startOfDay, rangeEnd: processedRow.startOfNextDay)
            #endif
        } // ForEach
    } // var body
} // struct ASAClockEventsForEach


// MARK:  -

struct ASAClockMainSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowCalendar:  Bool
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    var shouldShowMiniCalendar:  Bool
    var canSplitTimeFromDate:  Bool
    
    var body: some View {
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
                        ASAClockCellText(string:  string, font:  Font.headlineMonospacedDigit, lineLimit:  1)
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
    } // var body
} // struct ASAClockMainSubcell


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic, now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: false)
    }
} // struct ASAClockCell_Previews
