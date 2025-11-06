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
    var isWeekend: Bool
}


// MARK: -

struct ASAMiniCalendarView:  View {
    var daysPerWeek: Int
    var characterDirection: Locale.LanguageDirection
    var weekdayItems: [ASAWeekdayData]
    var cellItems: [CellItem]
    
    private var gridLayout: [GridItem] { Array(repeating: GridItem(), count: daysPerWeek) }
    
    struct CellItem {
        let text: String
        let isWeekend: Bool
        let isAccented: Bool
    }
    
    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            // Weekday header row
            ForEach(weekdayItems, id: \.index) { item in
                ASAWeekdayCell(symbol: item.symbol, isWeekend: item.isWeekend)
            }

            // Day cells
            ForEach(cellItems.indices, id: \.self) { idx in
                let item = cellItems[idx]
                if item.text == ""{
                    ASABlankCell()
                } else if item.isAccented {
                    ASAAccentedCell(text: item.text, shouldNoteAsWeekend: item.isWeekend)
                } else {
                    ASAOrdinaryCell(text: item.text, shouldNoteAsWeekend: item.isWeekend)
                }
            }
        }
        .environment(\.layoutDirection, (self.characterDirection == Locale.LanguageDirection.leftToRight ? .leftToRight :  .rightToLeft))
        .frame(maxWidth: CGFloat(daysPerWeek) * 22, maxHeight: 22 * 5, alignment: .center)
    }
} // struct ASAMiniCalendarView


struct ASAMiniCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Update with new initializer parameters: daysPerWeek, characterDirection, weekdayItems, cellItems
        /*
        ASAMiniCalendarView(daysPerWeek: 7,
                            characterDirection: .leftToRight,
                            weekdayItems: [ASAWeekdayData(symbol: "S", index: 0), ASAWeekdayData(symbol: "M", index: 1), ASAWeekdayData(symbol: "T", index: 2), ASAWeekdayData(symbol: "W", index: 3), ASAWeekdayData(symbol: "T", index: 4), ASAWeekdayData(symbol: "F", index: 5), ASAWeekdayData(symbol: "S", index: 6)],
                            cellItems: [
                                ASAMiniCalendarView.CellItem(text: "1", isWeekend: false, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "2", isWeekend: false, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "3", isWeekend: false, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "4", isWeekend: false, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "5", isWeekend: false, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "6", isWeekend: true, isAccented: false),
                                ASAMiniCalendarView.CellItem(text: "7", isWeekend: true, isAccented: true),
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                                nil,
                            ])
        */
    }
}

