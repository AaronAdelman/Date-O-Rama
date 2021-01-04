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

    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        HStack {
            ASATimesSubcell(event: event, row: self.primaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: Color(UIColor.label))
            if self.eventsViewShouldShowSecondaryDates {
                ASATimesSubcell(event: event, row: self.secondaryRow, timeWidth: self.timeWidth, timeFontSize: self.timeFontSize, labelColor: Color(UIColor.label))
            }
            ASAEventColorRectangle(color: event.color)
            VStack(alignment: .leading) {
                if self.sizeClass == .compact {
                    Text(event.title).font(.callout).bold().foregroundColor(Color(UIColor.label))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                } else {
                    Text(event.title).font(.headline).foregroundColor(Color(UIColor.label))
                        .allowsTightening(true)
                        .minimumScaleFactor(0.4)
                }
                Text(event.calendarTitleWithLocation
                ).font(.subheadlineMonospacedDigit).foregroundColor(Color(UIColor.secondaryLabel))
                .allowsTightening(true)
                .minimumScaleFactor(0.4)
                .lineLimit(2)
            } // VStack
        } // HStack
    }
} // struct ASAEventCell

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}
