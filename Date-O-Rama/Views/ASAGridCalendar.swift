//
//  ASAGridCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

// MARK: - Cells

struct ASABlankCell:  View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
    } // var body
} // struct ASABlankCell

struct ASAOrdinaryCell:  View {
    var number:  Int
    var font:  Font
    var numberFormatter:  NumberFormatter

    var body: some View {
        Text(numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? "")
            .font(font)
            .foregroundColor(.primary)
            .lineLimit(1)
    } // var body
} // struct ASAOrdinaryCell

struct ASAAccentedCell:  View {
    var number:  Int
    var font:  Font
    var numberFormatter:  NumberFormatter

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2.0, style: .circular)
                .foregroundColor(.red)

            Text(numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? "")
                .font(font)
                .foregroundColor(.white)
                .lineLimit(1)
        } // ZStack
    } // var body
} // struct ASAAccentedCell


// MARK: -

extension Int {
    func weekdayFixed(daysPerWeek:  Int) -> Int {
        if self == 0  {
            return daysPerWeek
        }
        return self
    } // func weekdayFixed(daysPerWeek:  Int) -> Int
} // extension Int


struct ASAGridCalendar:  View {
    var daysPerWeek:  Int
    var day:  Int
    var weekday:  Int
    var daysInMonth:  Int
    var numberFormatter:  NumberFormatter

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

    private var gridLayout:  Array<GridItem> {
        get {
            let temp:  Array<GridItem> = Array(repeating: GridItem(), count: daysPerWeek)
            return temp
        } // get
    } // var gridLayout

    let font:  Font = Font.system(size: 10.0).weight(.semibold)

    fileprivate func gridRange() -> ClosedRange<Int> {
        let gridFirstDay = -(weekdayOfDay1 - 2)

        let preexistingDays = daysInMonth - gridFirstDay + 1
        let neededDays = Int(ceil(Double(preexistingDays) / (Double(daysPerWeek)))) * daysPerWeek
        let gridLastDay = (neededDays - preexistingDays) + daysInMonth

        return gridFirstDay...gridLastDay
    } // func gridRange() -> ClosedRange<Int>

    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            ForEach((gridRange()), id: \.self) {
                if $0 < 1 || $0 > daysInMonth {
                    ASABlankCell()
                } else if $0 == day {
                    ASAAccentedCell(number: $0, font: font, numberFormatter: numberFormatter)
                } else {
                    ASAOrdinaryCell(number: $0, font: font, numberFormatter: numberFormatter)
                }
            }
        }
    }
} // struct ASAGridCalendar


struct ASAGridCalendar_Previews: PreviewProvider {
    static var previews: some View {
        ASAGridCalendar(daysPerWeek: 7, day: 3, weekday: 4, daysInMonth: 31, numberFormatter: NumberFormatter())
    }
}
