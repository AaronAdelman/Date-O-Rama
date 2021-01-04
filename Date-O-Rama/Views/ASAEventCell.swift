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

    #if os(watchOS)
    let labelColor = Color.white
    let secondaryLabelColor = Color(UIColor.lightGray)
    let compact = true
    #else
    let labelColor = Color(UIColor.label)
    let secondaryLabelColor = Color(UIColor.secondaryLabel)
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif

    var body: some View {
        #if os(watchOS)
        HStack {
            ASAEventColorRectangle(color: event.color)

            VStack(alignment: .leading) {
                Text(event.title).font(.callout).bold().foregroundColor(labelColor)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.4)
                    .lineLimit(3)

                Text(event.calendarTitleWithLocation
                ).font(.subheadlineMonospacedDigit).foregroundColor(secondaryLabelColor)
                .allowsTightening(true)
                .minimumScaleFactor(0.4)
                .lineLimit(2)

                ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor)

                if self.eventsViewShouldShowSecondaryDates {
                    ASATimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor)
                }

            } // VStack
        } // HStack
        #else
        HStack {
            ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor)

            if self.eventsViewShouldShowSecondaryDates {
                ASATimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: labelColor)
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
                        .lineLimit(2)
                }

                Text(event.calendarTitleWithLocation
                ).font(.subheadlineMonospacedDigit).foregroundColor(secondaryLabelColor)
                .allowsTightening(true)
                .minimumScaleFactor(0.4)
                .lineLimit(2)
            } // VStack
        } // HStack
        #endif
    } // var body
} // struct ASAEventCell

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}
