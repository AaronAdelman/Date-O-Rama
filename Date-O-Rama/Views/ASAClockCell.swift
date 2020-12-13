//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockCell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool

    var shouldShowTime:  Bool
    var shouldShowCalendarPizzazztron:  Bool

    #if os(watchOS)
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    #if os(watchOS)
    let runningOnWatchOS = true
    #else
    let runningOnWatchOS = false
    #endif

    var body: some View {
        if !runningOnWatchOS && processedRow.hasValidTime {
            ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
                .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour, calendarType: processedRow.calendarType))
                .padding(EdgeInsets(top: 4.0, leading: 16.0, bottom: 4.0, trailing: 16.0))
                .background(ASASkyGradient(processedRow: processedRow))
                .padding(EdgeInsets(top: -5.5, leading: -20.0, bottom: -5.5, trailing: -40.0))
        } else {
            ASAClockMainSubcell(processedRow: processedRow, shouldShowCalendar: shouldShowCalendar, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
        }
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

//    #if os(watchOS)
//    #else
//    @Environment(\.horizontalSizeClass) var sizeClass
//    #endif

    var body: some View {
        HStack {
            ASAClockMainSubcell(processedRow: processedRow, shouldShowCalendar: shouldShowCalendar, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)

            if (processedRow.supportsMonths || shouldShowTime) {
                Spacer()
            }

            if processedRow.supportsTimes {                ASAClockPizzazztronSubcell(processedRow: processedRow, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
            }

            Spacer().frame(width:  16.0)
        } // HStack
    }
}


// MARK: -

struct ASAClockPizzazztronSubcell:  View {
    #if os(watchOS)
    let compact = false
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif

    var processedRow:  ASAProcessedRow
    var shouldShowTime:  Bool
    var shouldShowCalendarPizzazztron:  Bool

    fileprivate func shouldShowClockPizzazztron() -> Bool {
        return shouldShowTime && processedRow.hasValidTime
    } //func shouldShowClockPizzazztron() -> Bool

    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.row.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter

    var body:  some View {
        #if os(watchOS)
        EmptyView()
        #else
            HStack {
                if processedRow.supportsMonths && shouldShowCalendarPizzazztron {
                    ASACalendarPizzazztron(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier, calendarCode: processedRow.calendarCode)
                }

                if shouldShowClockPizzazztron() {
                    ASAClockPizzazztron(processedRow:  processedRow)
                }
            }
//        }
        #endif
    } // var body
} // struct ASAClockPizzazztronCell


// MARK:  -

struct ASAClockMainSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowCalendar:  Bool
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    var shouldShowCalendarPizzazztron:  Bool

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

            if processedRow.canSplitTimeFromDate {
                if shouldShowFormattedDate {
                    ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                }
                if shouldShowTime {
                    HStack {
                        #if os(watchOS)
                        if !shouldShowPlaceName {
                            if processedRow.usesDeviceLocation {
                                ASASmallLocationSymbol()
                            }
                        }
                        #endif

                        ASAClockCellText(string:  processedRow.timeString ?? "", font:  Font.headlineMonospacedDigit, lineLimit:  1)

                        if processedRow.supportsTimeZones && shouldShowTimeZone {
                            ASAClockCellText(string:  "·", font:  Font.headlineMonospacedDigit, lineLimit:  1)

                            ASAClockCellText(string:  processedRow.timeZoneString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                        }
                    }
                }
            } else
//            if shouldShowFormattedDate
            {
                HStack {
                    #if os(watchOS)
                    if !shouldShowPlaceName {
                        if processedRow.usesDeviceLocation {
                            ASASmallLocationSymbol()
                        }
                    }
                    #endif

                    ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                }
//            } else {
//                Text("Bleh")
            }

            ASAPlaceSubcell(processedRow:  processedRow, shouldShowPlaceName:  shouldShowPlaceName, shouldShowCalendarPizzazztron:  shouldShowCalendarPizzazztron)
        } // VStack
    } // var body
} // struct ASAClockDateAndTimeSubcell


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
    }
} // struct ASAClockCell_Previews
