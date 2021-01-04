//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit

struct ASAClockCell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool

    var shouldShowTime:  Bool
    var shouldShowCalendarPizzazztron:  Bool

    var forComplications:  Bool

    var body: some View {
        #if os(watchOS)
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications:  forComplications)
        #else
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, forComplications: forComplications)
            .frame(minHeight:  40.0)
            .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour, calendarType: processedRow.calendarType, month:  processedRow.month, latitude:  processedRow.latitude, calendarCode:  processedRow.calendarCode))
            .padding(EdgeInsets(top: 4.0, leading: 16.0, bottom: 4.0, trailing: 16.0))
            .background(ASASkyGradient(processedRow: processedRow))
            .padding(EdgeInsets(top: -5.5, leading: -20.0, bottom: -5.5, trailing: -40.0))
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
    var shouldShowCalendarPizzazztron:  Bool
    var canSplitTimeFromDate:  Bool

    var forComplications:  Bool

    @State var shouldShowEvents:  Bool = false

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

    fileprivate func shouldShowClockPizzazztron() -> Bool {
        return !compact && shouldShowTime && processedRow.hasValidTime
    } //func shouldShowClockPizzazztron() -> Bool

    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.row.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter

    @State private var showingEvents:  Bool = false

    var body: some View {
        VStack(alignment:  .leading) {
            HStack {
                ASAClockMainSubcell(processedRow: processedRow, shouldShowCalendar: shouldShowCalendar, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron, canSplitTimeFromDate: canSplitTimeFromDate)

                if (processedRow.supportsMonths || shouldShowTime) {
                    Spacer()
                }

                #if os(watchOS)
                #else
                if processedRow.supportsTimes {
                    if processedRow.supportsMonths && shouldShowCalendarPizzazztron {
                        ASACalendarPizzazztron(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier, calendarCode: processedRow.calendarCode, weekdaySymbols: processedRow.veryShortStandaloneWeekdaySymbols)
                    }

                    if shouldShowClockPizzazztron() {
                        Spacer()

                        ASAClockPizzazztron(processedRow:  processedRow, numberFormatter: numberFormatter())
                    }
                }
                #endif

                Spacer().frame(width:  16.0)
            } // HStack

            if processedRow.events.count > 0 && !forComplications {
                HStack {
                    Toggle(isOn: $shouldShowEvents) {
                        Text("Show Events")
                    }
                    .padding(EdgeInsets(top: 1.0, leading: 4.0, bottom: 1.0, trailing: 1.0))
                    .overlay(
                        Capsule()
                            .stroke(Color("toggleBorder"), lineWidth: 1.0)
                    )
                    #if os(watchOS)
                    #else
                    Spacer()
                        .frame(width:  128.0)
                    #endif
                } // HStack
                if shouldShowEvents {
                    ASAClockEventsForEach(processedRow: processedRow)
                }
            }
        } // VStack
    } // var body
} // struct ASAClockCellBody


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedRow

    #if os(watchOS)
    let TIME_WIDTH:  CGFloat = 50.0
    #else
    let TIME_WIDTH:  CGFloat = 90.0
    #endif

    var body: some View {
        ForEach(processedRow.events, id: \.eventIdentifier) {
            event
            in
            ASAClockEventCell(event: event, primaryRow: processedRow.row, timeWidth: TIME_WIDTH, timeFontSize:  .body, eventsViewShouldShowSecondaryDates: false)
        } // ForEach
    }
}


// MARK:  -

struct ASAClockMainSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowCalendar:  Bool
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    var shouldShowCalendarPizzazztron:  Bool
    var canSplitTimeFromDate:  Bool

    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowCalendar {
                HStack {
                    #if os(watchOS)
                    #else
                    ASACalendarSymbol()
                    #endif
                    ASAClockCellText(string:  processedRow.calendarString, font:  .subheadlineMonospacedDigit, lineLimit:  1)
                }
            }

            if canSplitTimeFromDate {
                if shouldShowFormattedDate {
                    ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                }
                if shouldShowTime {
                    HStack {
                        if !shouldShowPlaceName && processedRow.usesDeviceLocation {
                            ASASmallLocationSymbol()
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
                        ASASmallLocationSymbol()
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

struct ASAClockEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
//    var secondaryRow:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var eventsViewShouldShowSecondaryDates: Bool

    var body: some View {
        HStack {
            ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: Color.white)
//            if self.eventsViewShouldShowSecondaryDates {
//                ASAClockStartAndEndTimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize)
//            }
            ASAEventColorRectangle(color: event.color)
            VStack(alignment: .leading) {
                    Text(event.title).font(.callout).bold()
//                        .foregroundColor(Color(UIColor.label))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                Text(event.calendarTitleWithoutLocation
).font(.subheadlineMonospacedDigit)
//                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .allowsTightening(true)
                    .minimumScaleFactor(0.4)
                    .lineLimit(2)
            } // VStack
        } // HStack
    }
}


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic, now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowCalendarPizzazztron: true, forComplications: false)
    }
} // struct ASAClockCell_Previews
