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
            .aspectRatio(1.0, contentMode: .fill)
            .foregroundColor(.clear)
    } // var body
} // struct ASABlankCell

struct ASAOrdinaryCell:  View {
    var number:  Int
    var font:  Font

    var body: some View {
        //        ZStack {
        //            Rectangle()
        //                .aspectRatio(1.0, contentMode: .fill)
        //                .foregroundColor(Color(red: 255.0/255.0, green: 247.0/255.0, blue: 223.0/255.0))
        //                .shadow(color: .black, radius: 1.0, x: 1.0, y: 1.0)
        Text("\(number)")
            .font(font)
            .aspectRatio(1.0, contentMode: .fill)
        //            .foregroundColor(Color(red: 255.0/255.0, green: 247.0/255.0, blue: 223.0/255.0))
        //        }
    } // var body
} // struct ASAOrdinaryCell

struct ASAAccentedCell:  View {
    var number:  Int
    var font:  Font

    var body: some View {
        //        ZStack {
        //            Rectangle()
        //                .aspectRatio(1.0, contentMode: .fill)
        //                .foregroundColor(.accentColor)
        //                .shadow(color: .black, radius: 1.0, x: 1.0, y: 1.0)
        Text("\(number)")
            .font(font)
            .bold()
            //                .foregroundColor(.white)
            .aspectRatio(1.0, contentMode: .fill)
        //            .foregroundColor(.accentColor)
        //        }
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

    var gridFirstDay:  Int {
        get {
            return -(weekdayOfDay1 - 2)
        } // get
    } // var gridFirstDay

    var gridLastDay:  Int {
        get {
            let preexistingDays = daysInMonth - gridFirstDay + 1
            let neededDays = Int(ceil(Double(preexistingDays) / (Double(daysPerWeek)))) * daysPerWeek
            let result = (neededDays - preexistingDays) + daysInMonth
            return result
        } // get
    } // var gridLastDay

    private var gridLayout:  Array<GridItem> {
        get {
            let temp:  Array<GridItem> = Array(repeating: GridItem(), count: daysPerWeek)
            return temp
        } // get
    } // var gridLayout

    let font:  Font = .caption2

    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: 1.0) {
            ForEach((gridFirstDay...gridLastDay), id: \.self) {
                if $0 < 1 || $0 > daysInMonth {
                    ASABlankCell()
                } else if $0 == day {
                    ASAAccentedCell(number: $0, font: font)
                } else {
                    ASAOrdinaryCell(number: $0, font: font)
                }
            }
        }
    }
} // struct ASAGridCalendar


struct ASAGridCalendar_Previews: PreviewProvider {
    static var previews: some View {
        ASAGridCalendar(daysPerWeek: 7, day: 3, weekday: 4, daysInMonth: 31)
    }
}
