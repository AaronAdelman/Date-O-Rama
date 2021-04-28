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
            #if os(watchOS)
            return 90.0
            #else
            if self.forClock {
                return 90.0
            }

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

    func properlyShortenedString(date:  Date) -> String {
       return (primary && eventIsTodayOnly) ? row.timeString(now: date) : row.shortenedDateTimeString(now: date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if event.isAllDay(for: row) {
                ASAAllDayTimesSubcell(startDate:  event.startDate, endDate:  event.endDate, startDateString: row.shortenedDateString(now: event.startDate), endDateString: row.shortenedDateString(now: event.endDate - 1), timeWidth: timeWidth, timeFontSize: timeFontSize, labelColor: labelColor, forClock: forClock)
            } else {
                ASATimeText(verbatim: properlyShortenedString(date: event.startDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, labelColor: labelColor, forClock: forClock)

                if event.endDate != event.startDate {
                    ASATimeText(verbatim:  properlyShortenedString(date: event.endDate), timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate, labelColor: labelColor, forClock: forClock)
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
