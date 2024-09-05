//
//  ASAMiniCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


// MARK: - Cells

fileprivate let MINIMUM_CELL_DIMENSION: CGFloat = 17.0
fileprivate let MINIMUM_SCALE_FACTOR: CGFloat   =  0.7
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
            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
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
                .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
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
            .fontWeight(.bold)
            .padding(1.0)
            .foregroundColor(isWeekend ? .secondary : .primary)
            .lineLimit(1)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
    } // var body
} // struct ASAWeekdayCell


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
    var monthIsBlank: Bool
    var blankWeekdaySymbol: String?
    
    var weekdayOfDay1:  Int {
            assert(daysPerWeek > 0)
            assert(day > 0)
            assert(weekday > 0)
            assert(weekday <= daysPerWeek)
            
            return weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
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
            let daysPerRow = monthIsBlank ? daysInMonth : daysPerWeek
            let temp:  Array<GridItem> = Array(repeating: GridItem(), count: daysPerRow)
            return temp
        } // get
    } // var gridLayout
    
    
    fileprivate func gridFirstDay() -> Int {
        if monthIsBlank {
            return 1
        }
        
        return -(weekdayOfDay1 - 2)
    }
    
    fileprivate func gridRange() -> ClosedRange<Int> {
        if monthIsBlank {
            assert(5 <= daysInMonth)
            assert(daysInMonth <= 6)
            return 1...daysInMonth
        }
        
        var gridFirstDay = gridFirstDay()
        
        let preexistingDays = daysInMonth - gridFirstDay + 1
        let neededDays = Int(ceil(Double(preexistingDays) / (Double(daysPerWeek)))) * daysPerWeek
        var gridLastDay = daysInMonth
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
            let weekdayCellRange = monthIsBlank ? self.gridRange() : 0...(processedWeekdaySymbols.count - 1)
                ForEach(weekdayCellRange, id: \.self) {
                    index
                    in
                    let symbol: String = monthIsBlank ? self.blankWeekdaySymbol! : processedWeekdaySymbols[index].symbol
                    let isWeekend: Bool = monthIsBlank ? true : weekendDays.contains(index + 1)
                    ASAWeekdayCell(symbol: symbol, isWeekend:
                                    isWeekend)
                }
        
            ForEach(self.gridRange(), id: \.self) {
                let shouldNoteAsWeekEnd: Bool = {
                    if monthIsBlank {
                        return true
                    }
                    
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
        ASAMiniCalendarView(daysPerWeek: 7, day: 30, weekday: 1, daysInMonth: 30, numberFormatter: NumberFormatter(), localeIdentifier: "en_US",
                            weekdaySymbols: Calendar(identifier: .gregorian).veryShortStandaloneWeekdaySymbols, weekendDays: [6, 7],
                            numberFormat: .system, monthIsBlank: false)
    }
}
