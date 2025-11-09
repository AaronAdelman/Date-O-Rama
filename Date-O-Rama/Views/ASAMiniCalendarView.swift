//
//  ASAMiniCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


// MARK: - Cells

fileprivate let MINIMUM_SCALE_FACTOR: CGFloat =  0.7
fileprivate let CELL_FONT: Font               = .caption2


struct ASABlankCell:  View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
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
    } // var body
} // struct ASAWeekdayCell


// MARK: -

struct ASAMiniCalendarView:  View {
    var daysPerWeek: Int
    var characterDirection: Locale.LanguageDirection
    var weekdayItems: [ASAMiniCalendarWeekdayModel]
    var ASAMiniCalendarDayModels: [ASAMiniCalendarDayModel]
    
    private var gridLayout: [GridItem] { Array(repeating: GridItem(), count: daysPerWeek) }
        
    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: 0.0) {
            // Weekday header row
            ForEach(weekdayItems, id: \.index) { item in
                ASAWeekdayCell(symbol: item.symbol, isWeekend: item.isWeekend)
            }

            // Day cells
            ForEach(ASAMiniCalendarDayModels.indices, id: \.self) { idx in
                let item = ASAMiniCalendarDayModels[idx]
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
        // TODO: Update with new initializer parameters: daysPerWeek, characterDirection, weekdayItems, ASAMiniCalendarDayModels
        /*
        ASAMiniCalendarView(daysPerWeek: 7,
                            characterDirection: .leftToRight,
                            weekdayItems: [ASAMiniCalendarWeekdayModel(symbol: "S", index: 0), ASAMiniCalendarWeekdayModel(symbol: "M", index: 1), ASAMiniCalendarWeekdayModel(symbol: "T", index: 2), ASAMiniCalendarWeekdayModel(symbol: "W", index: 3), ASAMiniCalendarWeekdayModel(symbol: "T", index: 4), ASAMiniCalendarWeekdayModel(symbol: "F", index: 5), ASAMiniCalendarWeekdayModel(symbol: "S", index: 6)],
                            ASAMiniCalendarDayModels: [
                                ASAMiniCalendarDayModel(text: "1", isWeekend: false, isAccented: false),
                                ASAMiniCalendarDayModel(text: "2", isWeekend: false, isAccented: false),
                                ASAMiniCalendarDayModel(text: "3", isWeekend: false, isAccented: false),
                                ASAMiniCalendarDayModel(text: "4", isWeekend: false, isAccented: false),
                                ASAMiniCalendarDayModel(text: "5", isWeekend: false, isAccented: false),
                                ASAMiniCalendarDayModel(text: "6", isWeekend: true, isAccented: false),
                                ASAMiniCalendarDayModel(text: "7", isWeekend: true, isAccented: true),
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

