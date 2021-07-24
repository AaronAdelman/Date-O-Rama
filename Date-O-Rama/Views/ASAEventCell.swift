//
//  ASAEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
    var secondaryRow:  ASARow
    var eventsViewShouldShowSecondaryDates: Bool
    var isForClock:  Bool
    @Binding var now:  Date

    #if os(watchOS)
    let compact = true
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif

    var rangeStart:  Date
    var rangeEnd:  Date

    func eventIsTodayOnly() -> Bool {
        return rangeStart <= event.startDate && event.endDate <= rangeEnd
    }

    var body: some View {
        let eventSymbol = event.symbol

        #if os(watchOS)
        HStack {
            ASAColorRectangle(color: event.color)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if eventSymbol != nil {
                        Text(eventSymbol!)
                            .font(.callout)
                            .bold()
                            .modifier(ASAScalable(lineLimit: 2))
                    }
                    Text(event.title)
                        .font(.callout)
                        .bold()
                        .modifier(ASAScalable(lineLimit: 2))
                }
                if !event.isAllDay {
                    ASATimesSubcell(event: event, row: self.primaryRow, isForClock: isForClock, isPrimaryRow:  true, eventIsTodayOnly: eventIsTodayOnly())
                    
                    if self.eventsViewShouldShowSecondaryDates {
                        ASATimesSubcell(event: event, row: self.secondaryRow, isForClock: isForClock, isPrimaryRow:  false, eventIsTodayOnly: eventIsTodayOnly())
                    }
                }
            } // VStack
        } // HStack
        #else
        HStack {
            ASATimesSubcell(event: event, row: self.primaryRow, isForClock: isForClock, isPrimaryRow:  true, eventIsTodayOnly: eventIsTodayOnly())

            if self.eventsViewShouldShowSecondaryDates {
                ASATimesSubcell(event: event, row: self.secondaryRow, isForClock: isForClock, isPrimaryRow:  false, eventIsTodayOnly: eventIsTodayOnly())
            }

            ASAColorRectangle(color: event.color)

            VStack(alignment: .leading) {
                let LINE_LIMIT = 3
                let TITLE_FONT: Font = self.compact ? .callout.bold() : .headline
                
                HStack(alignment: .top) {
                    if eventSymbol != nil {
                        Text(eventSymbol!)
                            .font(TITLE_FONT)
                            .modifier(ASAScalable(lineLimit: LINE_LIMIT))
                    }
                    Text(event.title)
                        .font(TITLE_FONT)
                        .modifier(ASAScalable(lineLimit: LINE_LIMIT))
                }
                
                if event.location != nil {
                    Text(event.location!).font(.callout)
                        .foregroundColor(.secondary)
                        .modifier(ASAScalable(lineLimit: 1))
                }

                ASAEventCellCalendarTitle(event: event, isForClock: isForClock)
            } // VStack
        } // HStack
        #endif
    } // var body
} // struct ASAEventCell


// MARK:  -

struct ASAEventCellCalendarTitle:  View {
    var event:  ASAEventCompatible
    var isForClock:  Bool

    #if os(watchOS)
    let LINE_LIMIT = 1
    #else
    let LINE_LIMIT = 2
    #endif

    var body: some View {
        let title: String = isForClock ? event.calendarTitleWithoutLocation : event.calendarTitleWithLocation
        Text(title).font(.subheadlineMonospacedDigit)
            .foregroundColor(.secondary)
        .modifier(ASAScalable(lineLimit: LINE_LIMIT))
    }
}

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}
