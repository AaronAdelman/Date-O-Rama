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

    var INSET:  CGFloat
    var shouldShowTime:  Bool
    var shouldShowCalendarPizzazztron:  Bool

    #if os(watchOS)
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    fileprivate func shouldShowClockPizzazztron() -> Bool {
        return shouldShowTime && processedRow.hasValidTime
    } //func shouldShowClockPizzazztron() -> Bool

    #if os(watchOS)
    let runningOnWatchOS = true
    #else
    let runningOnWatchOS = false
    #endif

    var body: some View {
        if !runningOnWatchOS && processedRow.hasValidTime && processedRow.transitionType != .noon {
            ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, INSET: INSET, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
                .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour))
                .padding(EdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0))
                .background(ASASkyGradient(processedRow: processedRow))
                .cornerRadius(8.0)
        } else {
            HStack {
                Spacer().frame(width: self.INSET)
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, INSET: INSET, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
            } // HStack
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

    var INSET:  CGFloat
    var shouldShowTime:  Bool
    var shouldShowCalendarPizzazztron:  Bool

    #if os(watchOS)
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    fileprivate func shouldShowClockPizzazztron() -> Bool {
        return shouldShowTime && processedRow.hasValidTime
    } //func shouldShowClockPizzazztron() -> Bool

    var body: some View {
        HStack {
            ASAClockMainSubcell(processedRow: processedRow, shouldShowCalendar: shouldShowCalendar, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, INSET:  INSET, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)

            #if os(watchOS)
            #else
            if (processedRow.supportsMonths || shouldShowTime) {
                Spacer()
            }

            ASAClockPizzazztronSubcell(processedRow: processedRow, shouldShowTime: shouldShowTime, shouldShowCalendarPizzazztron: shouldShowCalendarPizzazztron)
            #endif
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
        if compact {
            VStack {
                if processedRow.supportsMonths && shouldShowCalendarPizzazztron {
                    ASAGridCalendar(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter())
                }

                if shouldShowClockPizzazztron() {
                    ASAClockPizzazztron(processedRow:  processedRow)
                    Spacer().frame(height:  4.0)
                }
            }
        } else {
            HStack {
                if processedRow.supportsMonths && shouldShowCalendarPizzazztron {
                    ASAGridCalendar(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter())
                }

                if shouldShowClockPizzazztron() {
                    ASAClockPizzazztron(processedRow:  processedRow)
                }
            }
        }
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
    var INSET:  CGFloat
    var shouldShowCalendarPizzazztron:  Bool

    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowCalendar {
                HStack {
                    #if os(watchOS)
                    #else
                    ASACalendarSymbol()
                    #endif
                    ASAClockCellText(string:  processedRow.calendarString, font:  .subheadline, lineLimit:  1)
                }
            }

            if processedRow.canSplitTimeFromDate {
                if shouldShowFormattedDate {
                    ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit(), lineLimit:  2)
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

                        ASAClockCellText(string:  processedRow.timeString ?? "", font:  Font.headline.monospacedDigit(), lineLimit:  2)
                    }
                }
            } else if shouldShowFormattedDate {
                HStack {
                    #if os(watchOS)
                    if !shouldShowPlaceName {
                        if processedRow.usesDeviceLocation {
                            ASASmallLocationSymbol()
                        }
                    }
                    #endif

                    ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit(), lineLimit:  2)
                }
            }

            ASAPlaceSubcell(processedRow:  processedRow, shouldShowPlaceName:  shouldShowPlaceName, INSET:  INSET, shouldShowCalendarPizzazztron:  shouldShowCalendarPizzazztron)
        } // VStack
    } // var body
} // struct ASAClockDateAndTimeSubcell


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 20.0, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
    }
} // struct ASAClockCell_Previews
