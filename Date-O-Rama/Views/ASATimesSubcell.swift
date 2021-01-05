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

    #if os(watchOS)
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    var timeWidth:  CGFloat {
        get {
            if forClock {
                #if os(watchOS)
                return 50.0
                #else
                return 90.0
                #endif
            }
            
            #if os(watchOS)
            return 90.0
            #else
            if self.sizeClass! == .compact {
                return  90.00
            } else {
                return 120.00
            }
            #endif
        } // get
    } // var timeWidth
    let timeFontSize = Font.subheadlineMonospacedDigit

    var labelColor:  Color
    var forClock:  Bool
    var primary:  Bool
    var eventIsTodayOnly:  Bool

    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay && row.calendar.calendarCode == event.calendarCode && (row.locationData.timeZone.secondsFromGMT(for: event.startDate) == event.timeZone?.secondsFromGMT(for: event.startDate) || event.timeZone == nil) {
                ASAAllDayTimesSubcell(startDate:  event.startDate, endDate:  event.endDate, startDateString: row.shortenedDateString(now: event.startDate), endDateString: row.shortenedDateString(now: event.endDate - 1), timeWidth: timeWidth, timeFontSize: timeFontSize, labelColor: labelColor, forClock: forClock)
            } else {
                ASATimeText(verbatim: (primary && eventIsTodayOnly) ? row.shortenedTimeString(now: event.startDate) : row.shortenedDateTimeString(now: event.startDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, labelColor: labelColor, forClock: forClock)

                if event.endDate != event.startDate {
                    ASATimeText(verbatim:  (primary && eventIsTodayOnly) ? row.shortenedTimeString(now: event.endDate) : row.shortenedDateTimeString(now: event.endDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate, labelColor: labelColor, forClock: forClock)
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
