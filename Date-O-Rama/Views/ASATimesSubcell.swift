//
//  ASATimesSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATimesSubcell:  View {
    var event:  ASAEventCompatible
    var row:  ASARow
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var labelColor:  Color

    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay && row.calendar.calendarCode == event.calendarCode && (row.locationData.timeZone.secondsFromGMT(for: event.startDate) == event.timeZone?.secondsFromGMT(for: event.startDate) || event.timeZone == nil) {
                ASAAllDayTimesSubcell(startDate:  event.startDate, endDate:  event.endDate, startDateString: row.shortenedDateString(now: event.startDate), endDateString: row.shortenedDateString(now: event.endDate - 1), timeWidth: timeWidth, timeFontSize: timeFontSize, labelColor: labelColor)
            } else {
                ASATimeText(verbatim:  row.shortenedDateTimeString(now: event.startDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, labelColor: labelColor)

                if event.endDate != event.startDate {
                    ASATimeText(verbatim:  row.shortenedDateTimeString(now: event.endDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate, labelColor: labelColor)
                }
            }
        } // VStack
    } // var body
} // struct ASATimesSubcell

//struct ASATimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimesSubcell()
//    }
//}
