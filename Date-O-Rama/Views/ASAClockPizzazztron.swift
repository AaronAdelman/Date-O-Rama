//
//  ASAClockPizzazztron.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockPizzazztron:  View {
    var processedRow:  ASAProcessedRow
    var numberFormatter:  NumberFormatter

    @Environment(\.horizontalSizeClass) var sizeClass
    var julianDayWidth:  CGFloat {
        get {
            if self.sizeClass! == .compact {
                return 128.0
            } else {
                return 256.0
            }
        } // get
    } // var timeWidth

    func progress() -> Double {
        let secondsIntoDay:  Double = Double((processedRow.hour * 60 + processedRow.minute) * 60 + processedRow.second)
        return secondsIntoDay / Date.SECONDS_PER_DAY
    } // func progress() -> Double

    var body: some View {
        if processedRow.calendarType == .JulianDay {
            ProgressView(value: progress())
                .accentColor(Color("julianDayForeground"))
                .frame(maxWidth:  julianDayWidth)
        } else {
            Watch(hour:  processedRow.hour, minute:  processedRow.minute, second:  processedRow.second, isNight:  nightTime(hour:  processedRow.hour, transitionType:  processedRow.transitionType), numberFormatter: numberFormatter)
        }
    } // var body
} // struct ASAClockPizzazztron

//struct ASAClockPizzazztron_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClockPizzazztron()
//    }
//}
