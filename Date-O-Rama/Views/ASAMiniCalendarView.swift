//
//  ASAMiniCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


// MARK: - Cells

//fileprivate let MINIMUM_CELL_DIMENSION: CGFloat = 17.0
fileprivate let MINIMUM_SCALE_FACTOR: CGFloat   =  0.6
fileprivate let CELL_FONT: Font = .caption2


struct ASABlankCell:  View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
//            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
    } // var body
} // struct ASABlankCell

struct ASAOrdinaryCell:  View {
    var number:  Int
    var numberFormatter:  NumberFormatter
    var shouldNoteAsWeekend: Bool
    var numberFormat: ASAMiniCalendarNumberFormat
    
    fileprivate func formattedNumber() -> String {
        if numberFormat == .shortHebrew {
            return number.shortHebrewNumeral
        }
        
        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    } // formattedNumber() -> String
    
    var body: some View {
        Text(formattedNumber())
            .font(CELL_FONT)
            .padding(1.0)
            .foregroundColor(shouldNoteAsWeekend ? .secondary : .primary)
            .lineLimit(1)
//            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
    } // var body
} // struct ASAOrdinaryCell

struct ASAAccentedCell:  View {
    var number:  Int
    var numberFormatter:  NumberFormatter
    var shouldNoteAsWeekend: Bool
    var numberFormat: ASAMiniCalendarNumberFormat
    
    fileprivate func formattedNumber() -> String {
        if numberFormat == .shortHebrew {
            return number.shortHebrewNumeral
        }
        
        return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
    } // formattedNumber() -> String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(shouldNoteAsWeekend ? .pink : .red)
            
            Text(formattedNumber())
                .font(CELL_FONT)
                .padding(1.0)
                .foregroundColor(.white)
                .lineLimit(1)
//                .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
                .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
        } // ZStack
    } // var body
} // struct ASAAccentedCell

struct ASAWeekdayCell:  View {
    var symbol:  String
    var isWeekend: Bool
    
    var body: some View {
        Text(symbol)
            .font(CELL_FONT)
            .fontWeight(.black)
            .padding(1.0)
            .foregroundColor(isWeekend ? .secondary : .primary)
            .lineLimit(1)
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


// MARK: -

struct ASAMiniCalendarView:  View {
    var daysPerWeek:  Int
    var day:  Int
    var weekday:  Int
    var daysInMonth:  Int
    var numberFormatter:  NumberFormatter
    var localeIdentifier:  String
    var weekdaySymbols:  Array<String>
    var weekendDays: Array<Int>
    var numberFormat: ASAMiniCalendarNumberFormat
    
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
    
    
    fileprivate func gridFirstDay() -> Int {
        return -(weekdayOfDay1 - 2)
    }
    
    fileprivate func gridRange() -> ClosedRange<Int> {
        var gridFirstDay = gridFirstDay()
        
        let preexistingDays = daysInMonth - gridFirstDay + 1
        let neededDays = Int(ceil(Double(preexistingDays) / (Double(daysPerWeek)))) * daysPerWeek
        var gridLastDay = (neededDays - preexistingDays) + daysInMonth
        if gridLastDay < gridFirstDay {
            let temp = gridLastDay
            gridLastDay = gridFirstDay
            gridFirstDay = temp
        }
        
        return gridFirstDay...gridLastDay
    } // func gridRange() -> ClosedRange<Int>
    
    var characterDirection:  Locale.LanguageDirection {
        return Locale.characterDirection(forLanguage: localeIdentifier)
    } // var characterDirection
    
    var body: some View {
        let gridFirstDay = gridFirstDay()
        
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            ForEach(0..<processedWeekdaySymbols.count, id: \.self) {
                index
                in
                ASAWeekdayCell(symbol: processedWeekdaySymbols[index].symbol, isWeekend:
                                weekendDays.contains(index + 1))
            }
            
            let range = self.gridRange()
            ForEach(range, id: \.self) {
                let shouldNoteAsWeekEnd: Bool = {
                    var temp = false
                    //                        debugPrint(#file, #function, $0, daysPerWeek, weekendDays)
                    if weekendDays.contains(($0 - gridFirstDay) % daysPerWeek + 1) {
                        temp = true
                    }
                    return temp
                }($0)
                
                if $0 < 1 || $0 > daysInMonth {
                    ASABlankCell()
                } else if $0 == day {
                    ASAAccentedCell(number: $0,
                                    numberFormatter: numberFormatter,
                                    shouldNoteAsWeekend: shouldNoteAsWeekEnd, numberFormat: numberFormat)
                } else {
                    ASAOrdinaryCell(number: $0,
                                    numberFormatter: numberFormatter,
                                    shouldNoteAsWeekend: shouldNoteAsWeekEnd, numberFormat: numberFormat)
                }
            }
        }
        .environment(\.layoutDirection, (self.characterDirection == Locale.LanguageDirection.leftToRight ? .leftToRight :  .rightToLeft))
    }
} // struct ASAMiniCalendarView


struct ASAMiniCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMiniCalendarView(daysPerWeek: 7, day: 3, weekday: 4, daysInMonth: 31, numberFormatter: NumberFormatter(), localeIdentifier: "en_US",
                            weekdaySymbols: Calendar(identifier: .gregorian).veryShortStandaloneWeekdaySymbols, weekendDays: [6, 7],
                            numberFormat: .system)
    }
}
