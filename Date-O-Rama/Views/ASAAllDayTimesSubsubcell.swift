//
//  ASAAllDayTimesSubsubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAAllDayTimesSubsubcell:  View {
    var startDate:  Date
    var endDate:  Date
    var startDateString:  String
    var endDateString:    String
    var timeWidth:  CGFloat
    var timeFontSize:  Font

    var body:  some View {
        VStack {
            Text(startDateString).frame(width:  timeWidth).font(timeFontSize)
                .foregroundColor(startDate < Date() ? Color.gray : Color(UIColor.label))
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
            if startDateString != endDateString {
                Text(endDateString).frame(width:  timeWidth).font(timeFontSize)
                    .foregroundColor(endDate < Date() ? Color.gray : Color(UIColor.label))
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
            }
        }
    }
} // struct ASAAllDayTimesSubsubcell

//struct ASAAllDayTimesSubsubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAAllDayTimesSubsubcell()
//    }
//}
