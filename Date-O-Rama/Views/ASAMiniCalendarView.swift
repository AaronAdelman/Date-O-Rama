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
fileprivate let MINIMUM_SCALE_FACTOR: CGFloat =  0.7
fileprivate let CELL_FONT: Font               = .caption2


struct ASABlankCell:  View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
//            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
    } // var body
} // struct ASABlankCell

struct ASAOrdinaryCell:  View {
    var text: String
    var shouldNoteAsWeekend: Bool
    
    var body: some View {
        Text(text)
            .font(CELL_FONT)
            .padding(1.0)
            .foregroundColor(shouldNoteAsWeekend ? .secondary : .primary)
            .lineLimit(1)
//            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
    } // var body
} // struct ASAOrdinaryCell

struct ASAAccentedCell:  View {
    var text: String
    var shouldNoteAsWeekend: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(shouldNoteAsWeekend ? .pink : .red)
            
            Text(text)
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
            .fontWeight(.bold)
            .padding(1.0)
            .foregroundColor(isWeekend ? .secondary : .primary)
            .lineLimit(1)
            .minimumScaleFactor(MINIMUM_SCALE_FACTOR)
//            .frame(minWidth:  MINIMUM_CELL_DIMENSION, minHeight: MINIMUM_CELL_DIMENSION)
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
    var localeIdentifier:  String
    var weekdaySymbols:  Array<String>
    var weekendDays: Array<Int>
    var numberFormat: ASANumberFormat
    var monthIsBlank: Bool
    var blankWeekdaySymbol: String?
    
    // These control the maximum grid size based on cell/font assumptions
    private var maxColumns: Int { 10 }
    private var maxRows: Int { 5 }
    private var estimatedCellSize: CGFloat { 22 } // Slightly above MINIMUM_CELL_DIMENSION to allow for font/padding
    private var maxGridWidth: CGFloat { estimatedCellSize * CGFloat(maxColumns) }
    private var maxGridHeight: CGFloat { estimatedCellSize * CGFloat(maxRows) }
    
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
        let daysPerRow = monthIsBlank ? daysInMonth : daysPerWeek
        let temp:  Array<GridItem> = Array(repeating: GridItem(), count: daysPerRow)
        return temp
    } // var gridLayout
    
    fileprivate func gridRange(gridFirstDay: Int) -> ClosedRange<Int> {
        if monthIsBlank {
            assert(5 <= daysInMonth)
            assert(daysInMonth <= 6)
            return 1...daysInMonth
        }
        
        var firstDay = gridFirstDay
        var lastDay = daysInMonth
        if lastDay < firstDay {
            let temp = lastDay
            lastDay = firstDay
            firstDay = temp
        }
        
        return firstDay...lastDay
    } // func gridRange() -> ClosedRange<Int>
    
    var characterDirection:  Locale.LanguageDirection {
        return Locale.Language(identifier: localeIdentifier).characterDirection
  } // var characterDirection

    struct CellItem {
        let text: String
        let isWeekend: Bool
        let isAccented: Bool
    }

    var body: some View {
        let numberFormatter: NumberFormatter = {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: localeIdentifier)
            return numberFormatter
        }()

        let formatNumber: (Int) -> String = {
            return { number in
                if numberFormat == .shortHebrew {
                    return number.shortHebrewNumeral
                }
                return numberFormatter.string(from: NSNumber(integerLiteral: number)) ?? ""
            }
        }()
        
        let gridFirstDay = {
            if monthIsBlank {
                return 1
            }
            
            return -(weekdayOfDay1 - 2)
        }()
        
        let gridRange = self.gridRange(gridFirstDay: gridFirstDay)
        
        let cellItems: [CellItem?] = gridRange.map { value in
            if value < 1 || value > daysInMonth { return nil }
            let isWeekend: Bool = monthIsBlank ? true : weekendDays.contains(((value - gridFirstDay) % daysPerWeek) + 1)
            let isAccented = (value == day)
            return CellItem(text: formatNumber(value), isWeekend: isWeekend, isAccented: isAccented)
        }
        
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            let weekdayCellRange = monthIsBlank ? gridRange : 0...(processedWeekdaySymbols.count - 1)
                ForEach(weekdayCellRange, id: \.self) {
                    index
                    in
                    let symbol: String = monthIsBlank ? self.blankWeekdaySymbol! : processedWeekdaySymbols[index].symbol
                    let isWeekend: Bool = monthIsBlank ? true : weekendDays.contains(index + 1)
                    ASAWeekdayCell(symbol: symbol, isWeekend:
                                    isWeekend)
                }
        
            ForEach(cellItems.indices, id: \.self) { idx in
                if let item = cellItems[idx] {
                    if item.isAccented {
                        ASAAccentedCell(text: item.text, shouldNoteAsWeekend: item.isWeekend)
                    } else {
                        ASAOrdinaryCell(text: item.text, shouldNoteAsWeekend: item.isWeekend)
                    }
                } else {
                    ASABlankCell()
                }
            }
        }
        .environment(\.layoutDirection, (self.characterDirection == Locale.LanguageDirection.leftToRight ? .leftToRight :  .rightToLeft))
        .frame(maxWidth: maxGridWidth, maxHeight: maxGridHeight, alignment: .center)
    }
} // struct ASAMiniCalendarView


struct ASAMiniCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMiniCalendarView(daysPerWeek: 7, day: 30, weekday: 1, daysInMonth: 30, localeIdentifier: "en_US", weekdaySymbols: Calendar(identifier: .gregorian).veryShortStandaloneWeekdaySymbols, weekendDays: [6, 7], numberFormat: .system, monthIsBlank: false)
    }
}

