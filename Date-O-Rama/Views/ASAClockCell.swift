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
        }
    }
}

struct ASAClockCell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool

    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    var shouldShowTimeToNextDay:  Bool

    var forComplications:  Bool

    var body: some View {
        #if os(watchOS)
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, shouldShowTimeToNextDay: shouldShowTimeToNextDay, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
        #else
        let EDGE_INSETS_1: EdgeInsets = EdgeInsets(top: 4.0, leading: 16.0, bottom: 4.0, trailing: 16.0)
        let EDGE_INSETS_2: EdgeInsets = EdgeInsets(top: -5.5, leading: -20.0, bottom: -5.5, trailing: -40.0)
        let MINIMUM_HEIGHT:  CGFloat = 40.0
        if forComplications {
            ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, shouldShowTimeToNextDay: shouldShowTimeToNextDay, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
                .frame(minHeight:  MINIMUM_HEIGHT)
                .foregroundColor(Color.white)
                .padding(EDGE_INSETS_1)
                .background(Color.black)
                .padding(EDGE_INSETS_2)
        } else {
            ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, shouldShowTimeToNextDay: shouldShowTimeToNextDay, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications: forComplications)
                .frame(minHeight:  MINIMUM_HEIGHT)
                .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour, calendarType: processedRow.calendarType, month:  processedRow.month, latitude:  processedRow.latitude, calendarCode:  processedRow.calendarCode))
                .padding(EDGE_INSETS_1)
                .background(ASASkyGradient(processedRow: processedRow))
                .padding(EDGE_INSETS_2)
        }
        #endif
    } // var body
} // struct ASAClockCell


// MARK: -

struct ASANextEventTitle:  View {
    var body: some View {
        Text("Next event today:")
            .font(.subheadlineMonospacedDigit)
    }
}

struct ASAClockCellBody:  View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool

    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    var shouldShowTimeToNextDay:  Bool
    var canSplitTimeFromDate:  Bool

    var forComplications:  Bool

    @State var shouldShowEvents:  ASAClockCellEventVisibility = .next

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
                    NavigationLink(destination:  ASAWatchEventsList(processedRow:  processedRow)) {
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

            #if os(watchOS)
            #else
            if processedRow.events.count > 0 && !forComplications {
                HStack {
                    Text("Show Events")
                    Picker(selection: $shouldShowEvents, label: Text("")) {
                        ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                            possibility
                            in
                            Text(possibility.emoji)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                if shouldShowEvents == .all {
                    ASAClockEventsForEach(processedRow: processedRow, visibility:  .all)
                } else if shouldShowEvents == .allDay {
                    ASAClockEventsForEach(processedRow: processedRow, visibility:  .allDay)
                } else if shouldShowEvents == .future {
                    ASAClockEventsForEach(processedRow: processedRow, visibility:  .future)
                } else if shouldShowEvents == .next {
                    let nextEvent = processedRow.events.nextEvent(now: now)
                    if nextEvent != nil {
                        ASAEventCell(event: nextEvent!, primaryRow: processedRow.row, secondaryRow: ASAClockEventsForEach.genericRow, eventsViewShouldShowSecondaryDates: !processedRow.row.calendar.usesISOTime, forClock: true, rangeStart: processedRow.starOfDay, rangeEnd:  processedRow.startOfNextDay)
                    }
                }
            }

            if self.shouldShowTimeToNextDay {
                HStack {
                    Text("Time to next day:")
                        .font(.subheadlineMonospacedDigit)
                    Text(processedRow.startOfNextDay, style: .timer)
                        .font(.subheadlineMonospacedDigit)
                } // HStack
            }
            #endif
        } // VStack
    } // var body
} // struct ASAClockCellBody


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedRow
    var visibility:  ASAClockCellEventVisibility

    static let genericRow = ASARow.generic

    var body: some View {
        let events:  Array<ASAEventCompatible> = {
            switch self.visibility {
            case .allDay:
                return processedRow.events.allDayOnly

            case .future:
                return processedRow.events.futureOnly

            default:
                return processedRow.events
            } // switch visibility
        }()

        ForEach(events, id: \.eventIdentifier) {
            event
            in
            ASAEventCell(event: event, primaryRow: processedRow.row, secondaryRow: ASAClockEventsForEach.genericRow, eventsViewShouldShowSecondaryDates: !processedRow.row.calendar.usesISOTime, forClock: true, rangeStart: processedRow.starOfDay, rangeEnd:  processedRow.startOfNextDay)
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
                        
                        ASAClockCellText(string:  processedRow.timeString ?? "", font:  Font.headlineMonospacedDigit, lineLimit:  1)

                        if processedRow.supportsTimeZones && shouldShowTimeZone {
                            ASAClockCellText(string:  "·", font:  Font.headlineMonospacedDigit, lineLimit:  1)

                            ASAClockCellText(string:  processedRow.timeZoneString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                        }
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
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic, now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, shouldShowTimeToNextDay: true, forComplications: false)
    }
} // struct ASAClockCell_Previews
