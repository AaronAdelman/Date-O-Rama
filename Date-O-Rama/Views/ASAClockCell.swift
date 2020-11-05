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

    fileprivate func shouldShowClockPizzazztron() -> Bool {
        return shouldShowTime && processedRow.hasValidTime
    } //func shouldShowClockPizzazztron() -> Bool

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

                ASAStyledClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, INSET:  INSET)


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

                    if shouldShowClockPizzazztron() {
                        ASAClockPizzazztron(processedRow:  processedRow)
                    }
                }
            } else {
                HStack {
                    if processedRow.supportsMonths {
                        ASAGridCalendar(daysPerWeek:  processedRow.daysPerWeek, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter())
                    }

                    if shouldShowClockPizzazztron() {
                        ASAClockPizzazztron(processedRow:  processedRow)
                    }
                }
            }

            #endif
        } // HStack
    } // var body
} // struct ASAClockCell


// MARK:  -

fileprivate func nightTime(hour:  Int, transitionType:  ASATransitionType) -> Bool {
    switch transitionType {
    case .sunset, .dusk:
        if transitionType == .dusk {
            if hour == 23 || hour == 12 {
                return false
            }
        }

        if hour >= 0 && hour <= 11 {
            return true
        } else {
            return false
        }

    case .midnight:
        if hour <= 5 || hour >= 18 {
            return true
        } else {
            return false
        }

    case .noon:
        if 6 <= hour && hour <= 17 {
            return true
        } else {
            return false
        }
    } // switch transitionType
} // func nightTime(hour:  Int, transitionType:  ASATransitionType) -> Bool


extension Color {
    static var skyBlue:  Color {
        get {
            return Color(red: 20.0 / 255.0, green: 117.0 / 255.0, blue: 157.0 / 255.0)
        } // get
    } // static var skyBlue

    static var midnightBlue:  Color {
        get {
            return Color(red: 12.0 / 255.0, green: 15.0 / 255.0, blue: 38.0 / 255.0)
        } // get
    } // static var midnightBlue

    static var sunsetRed:  Color {
        get {
            return Color(red: 99.0 / 255.0, green: 29.0 / 255.0, blue: 35.0 / 255.0)
        } // get
    } // static var sunsetRed

    static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        let DAY_COLOR: Color = .white
        let NIGHT_COLOR: Color = .yellow

        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR

        return result
    } // static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

    static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        let DAY_COLOR: Color = .skyBlue
        let NIGHT_COLOR: Color = .midnightBlue

        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR

        return result
    } // static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

    var components:  (CGFloat, CGFloat, CGFloat) {
        get {
            let cg = self.cgColor
            if cg == nil {
                return (0.5, 0.5, 0.5)
            }
            let components = cg!.components
            if components == nil {
                return (0.5, 0.5, 0.5)
            }
            let result = (components![0], components![1], components![2])
            return result
        } // get
    } // var components

    static func blend(startColor:  Color, endColor:  Color, progress:  CGFloat) -> Color {
        let oneOverProgress:  CGFloat = 1.0 - progress

        let startComponents = startColor.components
        let endComponents = endColor.components
        let red   = startComponents.0 * oneOverProgress + endComponents.0 * progress
        let green = startComponents.1 * oneOverProgress + endComponents.1 * progress
        let blue  = startComponents.2 * oneOverProgress + endComponents.2 * progress
        let result = Color(red: Double(red), green: Double(green), blue: Double(blue))
        return result
    } // func blend(startColor:  Color, endColor:  Color, progress:  CGFloat)
} // extension Color


// MARK:  -

struct ASAStyledClockDateAndTimeSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var INSET:  CGFloat

    #if os(watchOS)
    let runningOnWatchOS = true
    #else
    let runningOnWatchOS = false
    #endif

    fileprivate func skyGradientColors(transitionType:  ASATransitionType) -> [Color] {
        let hour: Int = processedRow.hour

        if transitionType == .midnight || transitionType == .noon {
            let color = Color.backgroundColor(transitionType: transitionType, hour: hour)
            return [color, color]
        }

        var topColor:  Color
        var bottomColor:  Color

        let minute: Int = processedRow.minute

        let minutes = hour * 60 + minute

        var eveningTwilightStart:  Int = 0
        var eveningTwilightEnd:  Int   = 0
        var morningTwilightStart:  Int = 0
        var morningTwilightEnd:  Int   = 0

        let LENGTH_OF_DAY = 24 * 60 * 60

        let TWILIGHT_LENGTH_SUNSET_TRANSITION     = 83
        let EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION = 60
        let LATE_TWILIGHT_LENGTH_DUSK_TRANSITION  = 12

        switch transitionType {
        case .sunset:
            eveningTwilightStart = 0
            eveningTwilightEnd = eveningTwilightStart + TWILIGHT_LENGTH_SUNSET_TRANSITION
            morningTwilightEnd = 12 * 60
            morningTwilightStart = morningTwilightEnd - TWILIGHT_LENGTH_SUNSET_TRANSITION

        case .dusk:
            let transitionLength = EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION
            eveningTwilightStart = LENGTH_OF_DAY - EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION
            eveningTwilightEnd = LATE_TWILIGHT_LENGTH_DUSK_TRANSITION
            morningTwilightEnd = 13 * 60
            morningTwilightStart = morningTwilightEnd - transitionLength

        default:
            debugPrint(#file, #function, transitionType)
        } // switch transitionType

        if morningTwilightStart <= minutes && minutes < morningTwilightEnd {
            // Morning twilight
            let progress = CGFloat((minutes - morningTwilightStart) / (morningTwilightEnd - morningTwilightStart))
            topColor = Color.blend(startColor: .midnightBlue, endColor: .skyBlue, progress: progress)
            bottomColor = Color.blend(startColor: .midnightBlue, endColor: .sunsetRed, progress: progress)
        } else if transitionType == .sunset && eveningTwilightStart <= minutes && minutes < eveningTwilightEnd {
            // Evening twilight, sunset transition
            let progress = CGFloat(minutes) / CGFloat(eveningTwilightEnd)
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if transitionType == .dusk && eveningTwilightStart <= minutes {
            // Early evening twilight, dusk transition
            let progress = CGFloat((LENGTH_OF_DAY - minutes) / (EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION))
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if transitionType == .dusk && minutes < eveningTwilightEnd {
            // Late evening twilight, dusk transition
            let progress = CGFloat((EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + minutes) / (EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION))
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if hour >= 0 && hour <= 11 {
            // Night
            topColor = .midnightBlue
            bottomColor = .midnightBlue
        } else {
            // Day
            topColor = .skyBlue
            bottomColor = .skyBlue
        }

        return [topColor, bottomColor]
    } // func skyGradientColors() -> [Color]

    var body:  some View {
        if !runningOnWatchOS && processedRow.hasValidTime && processedRow.transitionType != .noon {
            ASAClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, INSET: INSET)
                .foregroundColor(.foregroundColor(transitionType: processedRow.transitionType, hour: processedRow.hour))
                .padding(.horizontal)
                .background(LinearGradient(gradient: Gradient(colors: skyGradientColors(transitionType: processedRow.transitionType)), startPoint: .top, endPoint: .bottom))
                .cornerRadius(8.0)
        } else {
            HStack {
                Spacer().frame(width: self.INSET)
                ASAClockDateAndTimeSubcell(processedRow: processedRow, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowTime: shouldShowTime, shouldShowPlaceName: shouldShowPlaceName, INSET: INSET)
            } // HStack
        }
    } //var body:  some View
} // struct ASAStyledClockDateAndTimeSubcell


// MARK:  -

struct ASAClockDateAndTimeSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowFormattedDate:  Bool
    var shouldShowTime:  Bool
    var shouldShowPlaceName:  Bool
    var INSET:  CGFloat

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

            ASAPlaceSubcell(processedRow:  processedRow, shouldShowPlaceName:  shouldShowPlaceName, INSET:  INSET)
        } // VStack
    } // var body
} // struct ASAClockDateAndTimeSubcell


// MARK:  -

struct ASAPlaceSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowPlaceName:  Bool
    var INSET:  CGFloat

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

    var body: some View {
        if shouldShowPlaceName {
            HStack {
                VStack(alignment: .leading) {
                    if processedRow.supportsTimeZones || processedRow.supportsLocations {
                        HStack {
                            Spacer().frame(width: self.INSET)

                            if compact {
                                VStack {
                                    if processedRow.usesDeviceLocation {
                                        ASASmallLocationSymbol()
                                    }
                                    Text(verbatim: processedRow.verticalEmojiString)
                                }
                            } else {
                                if processedRow.usesDeviceLocation {
                                    ASASmallLocationSymbol()
                                }
                                Text(verbatim:  processedRow.emojiString)
                            }

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
    }
}


// MARK:  -

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


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic(), now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 20.0, shouldShowTime: true)
    }
} // struct ASAClockCell_Previews
