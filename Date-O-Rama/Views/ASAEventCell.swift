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
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var eventsViewShouldShowSecondaryDates: Bool
    var forClock:  Bool

    #if os(watchOS)
    let labelColor = Color.white
    let secondaryLabelColor = Color(UIColor.lightGray)
    let compact = true
    #else
    var labelColor:  Color {
        get {
            if self.forClock {
                return Color("label")
            } else {
                return Color(UIColor.label)
            }
        }
    }
    var secondaryLabelColor:  Color {
        get {
            if self.forClock {
                return Color("secondaryLabel")
            } else {
                return Color(UIColor.secondaryLabel)
            }
        }
    }
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
        #if os(watchOS)
        HStack {
            ASAEventColorRectangle(color: event.color)

            VStack(alignment: .leading) {
                Text(event.title).font(.callout).bold().foregroundColor(labelColor)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.4)
                    .lineLimit(3)

                ASAEventCellCalendarTitle(event: event, color: secondaryLabelColor)

                ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor, forClock: forClock, primary:  true, eventIsTodayOnly: eventIsTodayOnly())

                if self.eventsViewShouldShowSecondaryDates {
                    ASATimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor, forClock: forClock, primary:  false, eventIsTodayOnly: eventIsTodayOnly())
                }

            } // VStack
        } // HStack
        #else
        HStack {
            ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor, forClock: forClock, primary:  true, eventIsTodayOnly: eventIsTodayOnly())

            if self.eventsViewShouldShowSecondaryDates {
                ASATimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor, forClock: forClock, primary:  false, eventIsTodayOnly: eventIsTodayOnly())
            }

            ASAEventColorRectangle(color: event.color)

            VStack(alignment: .leading) {
                if self.compact {
                    Text(event.title).font(.callout).bold().foregroundColor(labelColor)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                } else {
                    Text(event.title).font(.headline).foregroundColor(labelColor)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                }

                ASAEventCellCalendarTitle(event: event, color: secondaryLabelColor)
            } // VStack
        } // HStack
        #endif
    } // var body
} // struct ASAEventCell

struct ASAEventCellCalendarTitle:  View {
    var event:  ASAEventCompatible
    var color:  Color

    var body: some View {
        Text(event.calendarTitleWithLocation
        ).font(.subheadlineMonospacedDigit).foregroundColor(color)
        .allowsTightening(true)
        .minimumScaleFactor(0.4)
        .lineLimit(2)
    }
}

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}
