//
//  ASAMiniClockView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMiniClockView:  View {
    var processedClock:  ASAProcessedClock
    var numberFormatter:  NumberFormatter

    var body: some View {
        if processedClock.calendarType == .JulianDay {
            let progress: Double = processedClock.fractionalHour ?? 0.0
            ASADayFractionView(progress: progress)
        } else {
            if processedClock.calendarCode.isSunsetTransitionCalendar {
                let fractionalHour: Double = processedClock.fractionalHour ?? 0.0
                let dayHalf: ASADayHalf = processedClock.dayHalf ?? .night
                let totalHours: Double = fractionalHour + (dayHalf == .night ? 0.0 : 12.0)
                let degreesPerHour = 360.0 / 24.0
                let degrees = totalHours * degreesPerHour + 180.0
                ASASolarTimeView(degrees: degrees, dimension: 56.0, font: .body)
            } else {
                let hour: Int = processedClock.hour ?? 0
                let minute: Int = processedClock.minute ?? 0
                let second: Int = processedClock.second ?? 0
                let totalHours: Int = processedClock.timeFormat == .decimal ? 10 : 12
                let minutesPerHour: Int = processedClock.timeFormat == .decimal ? 100 : 60
                
                Watch(hour:  hour, minute:  minute, second:  second, isNight:  nightTime(hour:  hour, transitionType:  processedClock.transitionType), totalHours: totalHours, minutesPerHour: minutesPerHour, numberFormatter: numberFormatter)
            }
        }
    } // var body
} // struct ASAMiniClockView

//struct ASAMiniClockView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMiniClockView()
//    }
//}
