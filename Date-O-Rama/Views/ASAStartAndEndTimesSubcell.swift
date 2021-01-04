//
//  ASAStartAndEndTimesSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAStartAndEndTimesSubcell:  View {
    var event:  ASAEventCompatible
    var row:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font

    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay && row.calendar.calendarCode == event.calendarCode && (row.locationData.timeZone.secondsFromGMT(for: event.startDate) == event.timeZone?.secondsFromGMT(for: event.startDate) || event.timeZone == nil) {
                ASAAllDayTimesSubsubcell(startDate:  event.startDate, endDate:  event.endDate, startDateString: row.shortenedDateString(now: event.startDate), endDateString: row.shortenedDateString(now: event.endDate - 1), timeWidth: timeWidth, timeFontSize: timeFontSize)
            } else {
                Text(row.shortenedDateTimeString(now: event.startDate)).frame(width:  timeWidth).font(timeFontSize).foregroundColor(event.startDate < Date() ? Color.gray : Color(UIColor.label))
                    .lineLimit(2)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                if event.endDate != event.startDate {
                    Text(row.shortenedDateTimeString(now: event.endDate)).frame(width:  timeWidth).font(self.timeFontSize).foregroundColor(event.endDate < Date() ? Color.gray : Color(UIColor.label))
                        .lineLimit(2)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
            }
        } // VStack
    } // var body
} // struct ASAStartAndEndTimesSubcell

//struct ASAStartAndEndTimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAStartAndEndTimesSubcell()
//    }
//}
