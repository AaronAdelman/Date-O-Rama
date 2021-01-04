//
//  ASAAllDayTimesSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI


struct ASAAllDayTimesSubcell:  View {
    var startDate:  Date
    var endDate:  Date
    var startDateString:  String
    var endDateString:    String
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var labelColor:  Color

    var body:  some View {
        VStack {
            ASATimeText(verbatim:  startDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  startDate, labelColor: labelColor)

            if startDateString != endDateString {
                ASATimeText(verbatim:  endDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  endDate, labelColor:  labelColor)
            }
        }
    }
} // struct ASAAllDayTimesSubcell

//struct ASAAllDayTimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAAllDayTimesSubcell()
//    }
//}
