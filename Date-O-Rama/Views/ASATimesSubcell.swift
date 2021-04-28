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
            if self.isForClock {
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
    var isForClock:  Bool
    var isPrimaryRow:  Bool
    var eventIsTodayOnly:  Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            let (startDateString, endDateString) = row.startAndEndDateStrings(event: event, isPrimaryRow: isPrimaryRow, eventIsTodayOnly: eventIsTodayOnly)
                        
            if startDateString != endDateString {
                ASATimeText(verbatim: startDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, labelColor: labelColor, isForClock: isForClock)
            }
            
            ASATimeText(verbatim: endDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate, labelColor: labelColor, isForClock: isForClock)
        } // VStack
    } // var body
} // struct ASATimesSubcell

//struct ASATimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimesSubcell()
//    }
//}
