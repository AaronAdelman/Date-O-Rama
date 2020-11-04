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

    let ROW_HEIGHT = 30.0 as CGFloat

    #if os(watchOS)
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.row.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter

    var body: some View {
        HStack {

            VStack(alignment: .leading) {
                if shouldShowCalendar {
                    HStack {
                        #if os(watchOS)
                        #else
                        ASACalendarSymbol()
                        #endif
                        ASAClockCellText(string:  processedRow.calendarString, font:  .subheadline)
                    }
                }

                HStack {
                    Spacer().frame(width: self.INSET)

                    VStack(alignment: .leading) {
                        if processedRow.canSplitTimeFromDate {
                            if shouldShowFormattedDate {
                                ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit())
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

                                    ASAClockCellText(string:  processedRow.timeString ?? "", font:  Font.headline.monospacedDigit())
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

                                ASAClockCellText(string:  processedRow.dateString, font:  Font.headline.monospacedDigit())
                            }
                        }
                    } // VStack
                } // HStack

                if shouldShowPlaceName {
                    HStack {
                        VStack(alignment: .leading) {
                            if processedRow.supportsTimeZones || processedRow.supportsLocations {
                                HStack {
                                    Spacer().frame(width: self.INSET)
                                    if processedRow.usesDeviceLocation {
                                        ASASmallLocationSymbol()
                                    }
                                    Text(verbatim:  processedRow.emojiString)

                                    Text(processedRow.locationString).font(.subheadline)
                                } // HStack
                            }
                        }
                    }
                } else if processedRow.usesDeviceLocation {
                    #if os(watchOS)
                    #else
                    HStack {
                        Spacer().frame(width: self.INSET)
                        ASASmallLocationSymbol()
                    } // HStack
                    #endif
                }
            } // VStack

            #if os(watchOS)
            #else
            if processedRow.supportsMonths || shouldShowTime {
                Spacer()
            }

            if self.sizeClass == .compact {
                VStack {
                    if processedRow.supportsMonths {
                        ASAGridCalendar(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter())
                    }

                    if shouldShowTime {
                        ASAClockPizzazztron(processedRow:  processedRow)
                    }
                }
            } else {
                HStack {
                    if processedRow.supportsMonths {
                        ASAGridCalendar(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter())
                    }

                    if shouldShowTime {
                        ASAClockPizzazztron(processedRow:  processedRow)
                    }
                }
            }

            #endif
        } // HStack
    } // var body
} // struct ASAClockCell


struct ASAClockPizzazztron:  View {
    var processedRow:  ASAProcessedRow

    func progress() -> Double {
        let secondsIntoDay:  Double = Double((processedRow.hour * 60 + processedRow.minute) * 60 + processedRow.second)
        let secondsPerDay = 24.0 * 60.0 * 60.0
        return secondsIntoDay / secondsPerDay
    } // func progress() -> Double

    var body: some View {
        #if os(watchOS)
        EmptyView()
        #else
        if processedRow.calendarType == .JulianDay {
            ProgressView(value: progress())
        } else {
            Watch(hour:  processedRow.hour, minute:  processedRow.minute, second:  processedRow.second)
        }
        #endif
    } // var body
} // struct ASAClockPizzazztron


struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 20.0, shouldShowTime: true)
    }
} // struct ASAClockCell_Previews
