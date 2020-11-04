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

                ASAStyledClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowTime, INSET:  INSET)

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


extension Color {
    static var skyBlue:  Color {
        get {
            return Color(red: 38.0 / 255.0, green: 165.0 / 255.0, blue: 203.0 / 255.0)
        } // get
    } // static var skyBlue

    static var midnightBlue:  Color {
        get {
            return Color(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 4.0 / 255.0)
        } // get
    } // static var midnightBlue

    static var sunsetRed:  Color {
        get {
            return Color(red: 189.0 / 255.0, green: 17.0 / 255.0, blue: 89.0 / 255.0)
        } // get
    } // static var sunsetRed

    static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        switch transitionType {
        case .sunset:
            if hour == 0 || hour == 11 {
                return .white
            }

        case .dusk:
            if hour == 23 || hour == 12 {
                return .white
            }

        default:
            debugPrint(#file, #function, transitionType)
        } // switch transitionType

        if hour >= 0 && hour <= 11 {
            return .yellow
        } else {
            return .white
        }
    } // static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

    static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        switch transitionType {
        case .sunset:
            if hour == 0 || hour == 11 {
                return .sunsetRed
            }

        case .dusk:
            if hour == 23 || hour == 12 {
                return .sunsetRed
            }

        default:
            debugPrint(#file, #function, transitionType)
        } // switch transitionType

        if hour >= 0 && hour <= 11 {
            return .midnightBlue
        } else {
            return .skyBlue
        }
    } // static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color
} // extension Color


struct ASAStyledClockDateAndTimeSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var INSET:  CGFloat

    var body:  some View {
        if processedRow.transitionType == .sunset || processedRow.transitionType == .dusk {
            ZStack {
                RoundedRectangle(cornerRadius: 8.0)
                    .foregroundColor(.backgroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour))
                ASAClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowTime)
                    .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour))
            }
        } else {
            HStack {
                Spacer().frame(width: self.INSET)
                ASAClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowTime)
            } // HStack
        }
    } //var body:  some View
} // struct ASAStyledClockDateAndTimeSubcell


struct ASAClockDateAndTimeSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool

    var body: some View {
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
    } // var body
} // struct ASAClockDateAndTimeSubcell


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
