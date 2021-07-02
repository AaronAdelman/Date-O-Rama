//
//  ASAMiniCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


// MARK: - Cells

fileprivate let MINIMUM_CELL_WIDTH:  CGFloat   = 15.0
fileprivate let MINIMUM_SCALE_FACTOR:  CGFloat =  0.6
fileprivate let CELL_FONT:  Font = .system(size: 11.0, weight: .bold, design: .default)

struct ASABlankCell:  View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth:  MINIMUM_CELL_WIDTH)
    } // var body
} // struct ASABlankCell

struct ASAOrdinaryCell:  View {
    var number:  Int
//    var font:  Font
    var numberFormatter:  NumberFormatter
    var localeIdentifier:  String
    var calendarCode:  ASACalendarCode
    var shouldNoteAsWeekEnd: Bool

    fileprivate func formattedNumber() -> String {
        if calendarCode.isHebrewCalendar && localeIdentifier.hasPrefix("he") {
            return number.HebrewNumeral
        }

        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    } // formattedNumber() -> String

    var body: some View {
        Text(formattedNumber())
            .font(CELL_FONT)
//            .foregroundColor(Color("calendarOrdinaryCellText"))
            .lineLimit(1)
            .frame(minWidth:  MINIMUM_CELL_WIDTH)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
//            .foregroundColor(shouldNoteAsWeekEnd ? .secondary : .primary)
            .foregroundColor(shouldNoteAsWeekEnd ? .blue : .primary)
    } // var body
} // struct ASAOrdinaryCell

struct ASAAccentedCell:  View {
    var number:  Int
//    var font:  Font
    var numberFormatter:  NumberFormatter
    var localeIdentifier:  String
    var calendarCode:  ASACalendarCode
    var shouldNoteAsWeekEnd: Bool

    fileprivate func formattedNumber() -> String {
        if calendarCode.isHebrewCalendar && localeIdentifier.hasPrefix("he") {
            return number.HebrewNumeral
        }

        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    } // formattedNumber() -> String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2.0, style: .circular)
//                .foregroundColor(Color("calendarAccentedCellBackground"))
                .foregroundColor(shouldNoteAsWeekEnd ? . purple : .red)

            Text(formattedNumber())
                .font(CELL_FONT)
//                .foregroundColor(shouldNoteAsWeekEnd ? Color.yellow : Color("calendarAccentedCellText"))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(minWidth:  MINIMUM_CELL_WIDTH)
                .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
        } // ZStack
    } // var body
} // struct ASAAccentedCell

struct ASAWeekdayCell:  View {
    var symbol:  String

    var body: some View {
        Text(symbol)
            .font(CELL_FONT).fontWeight(.black)
//            .foregroundColor(Color("calendarWeekdayCellText"))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .frame(minWidth:  MINIMUM_CELL_WIDTH)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
    } // var body
} // struct ASAWeekdayCell


// MARK: -

extension Int {
    func weekdayFixed(daysPerWeek:  Int) -> Int {
        if self == 0  {
            return daysPerWeek
        }
        return self
    } // func weekdayFixed(daysPerWeek:  Int) -> Int
} // extension Int


// MARK:  -

struct ASAWeekdayData {
    var symbol:  String
    var index:  Int
}

struct ASAMiniCalendarView:  View {
    var daysPerWeek:  Int
    var day:  Int
    var weekday:  Int
    var daysInMonth:  Int
    var numberFormatter:  NumberFormatter
    var localeIdentifier:  String
    var calendarCode:  ASACalendarCode
    var weekdaySymbols:  Array<String>
    var weekendDays: Array<Int>
    var regionCode: String?

    var weekdayOfDay1:  Int {
        get {
            assert(daysPerWeek > 0)
            assert(day > 0)
            assert(weekday > 0)
            assert(weekday <= daysPerWeek)

            let correspondingDayInWeek1 = (day % daysPerWeek).weekdayFixed(daysPerWeek: daysPerWeek)

            let possibility1 = (weekday - correspondingDayInWeek1 + 1).weekdayFixed(daysPerWeek: daysPerWeek)
            if possibility1 > 0 && possibility1 <= daysPerWeek {
                return possibility1
            }
            let possibility2 = possibility1 + daysPerWeek
            assert(possibility2 > 0)
            assert(possibility2 <= daysPerWeek)
            return possibility2
        } // get
    } // var weekdayOfDay1

    private var processedWeekdaySymbols:  Array<ASAWeekdayData> {
        var result:  Array<ASAWeekdayData> = []
        for i in 0..<self.weekdaySymbols.count {
            result.append(ASAWeekdayData(symbol: self.weekdaySymbols[i], index: i))
        } // for i
        return result
    }

    private var gridLayout:  Array<GridItem> {
        get {
            let temp:  Array<GridItem> = Array(repeating: GridItem(), count: daysPerWeek)
            return temp
        } // get
    } // var gridLayout


    fileprivate func gridRange() -> ClosedRange<Int> {
        let gridFirstDay = -(weekdayOfDay1 - 2)

        let preexistingDays = daysInMonth - gridFirstDay + 1
        let neededDays = Int(ceil(Double(preexistingDays) / (Double(daysPerWeek)))) * daysPerWeek
        let gridLastDay = (neededDays - preexistingDays) + daysInMonth

        return gridFirstDay...gridLastDay
    } // func gridRange() -> ClosedRange<Int>

    var characterDirection:  Locale.LanguageDirection {
        return Locale.characterDirection(forLanguage: localeIdentifier)
    } // var characterDirection

    var body: some View {
        let canNoteWeekendDays: Bool = (regionCode == Locale.current.regionCode)
        
        let gridFirstDay = -(weekdayOfDay1 - 2)

        
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            ForEach(processedWeekdaySymbols, id: \.index) {
                ASAWeekdayCell(symbol: $0.symbol)
            }

            let range = self.gridRange()
            ForEach(range, id: \.self) {
                let shouldNoteAsWeekEnd: Bool = {
                    var temp = false
                    if canNoteWeekendDays {
//                        debugPrint(#file, #function, $0, daysPerWeek, weekendDays)
                        if weekendDays.contains(($0 - gridFirstDay) % daysPerWeek + 1) {
                            temp = true
                        }
                    }
                    return temp
                }($0)

                
                if $0 < 1 || $0 > daysInMonth {
                    ASABlankCell()
                } else if $0 == day {
                    ASAAccentedCell(number: $0,
                                    numberFormatter: numberFormatter, localeIdentifier: localeIdentifier, calendarCode: calendarCode, shouldNoteAsWeekEnd: shouldNoteAsWeekEnd)
                } else {
                    ASAOrdinaryCell(number: $0,
                                    numberFormatter: numberFormatter, localeIdentifier: localeIdentifier, calendarCode: calendarCode, shouldNoteAsWeekEnd: shouldNoteAsWeekEnd)
                }
            }
        }
        .environment(\.layoutDirection, (self.characterDirection == Locale.LanguageDirection.leftToRight ? .leftToRight :  .rightToLeft))
    }
} // struct ASAMiniCalendarView


struct ASAMiniCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMiniCalendarView(daysPerWeek: 7, day: 3, weekday: 4, daysInMonth: 31, numberFormatter: NumberFormatter(), localeIdentifier: "en_US", calendarCode: .Gregorian, weekdaySymbols: Calendar(identifier: .gregorian).veryShortStandaloneWeekdaySymbols, weekendDays: [6, 7], regionCode: "IL")
    }
}
