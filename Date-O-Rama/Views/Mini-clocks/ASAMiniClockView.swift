//
//  ASAMiniClockView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMiniClockView:  View {
    var processedRow:  ASAProcessedRow
    var numberFormatter:  NumberFormatter

//    func progress() -> Double {
//        let secondsIntoDay:  Double = Double((processedRow.hour! * 60 + processedRow.minute!) * 60 + processedRow.second!)
//        let progress: Double = secondsIntoDay / Date.SECONDS_PER_DAY
//
//        assert(progress >= 0.0)
//        assert(progress <= 1.0)
//
//        return progress
//    } // func progress() -> Double

    var body: some View {
        if processedRow.calendarType == .JulianDay {
//             ASADayFractionView(progress: progress())
            let progress: Double = processedRow.fractionalHour ?? 0.0
            ASADayFractionView(progress: progress)
        } else {
            if processedRow.calendarCode.isSunsetTransitionCalendar {
//                let fractionalHours: Double = Double(processedRow.hour!) + Double(processedRow.minute!) / 60.0
                let fractionalHour: Double = processedRow.fractionalHour ?? 0.0
                let dayHalf: ASATimeSpecificationDayHalf = processedRow.dayHalf ?? .night
                let totalHours: Double = fractionalHour + (dayHalf == .night ? 0.0 : 12.0)
                let degreesPerHour = 360.0 / 24.0
                let degrees = totalHours * degreesPerHour + 180.0
                ASASolarTimeView(degrees: degrees, dimension: 56.0, font: .body)
            } else {
                let hour: Int = processedRow.hour!
                let minute: Int = processedRow.minute!
                let second: Int = processedRow.second!
                Watch(hour:  hour, minute:  minute, second:  second, isNight:  nightTime(hour:  hour, transitionType:  processedRow.transitionType), numberFormatter: numberFormatter)
            }
        }
    } // var body
} // struct ASAMiniClockView

//struct ASAMiniClockView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMiniClockView()
//    }
//}
