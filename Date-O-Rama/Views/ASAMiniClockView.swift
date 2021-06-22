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
            #if targetEnvironment(macCatalyst)
            let verticalInset: CGFloat = -5.0
            #else
            let verticalInset: CGFloat =  1.0
            #endif
            ProgressView(value: progress())
                .accentColor(Color("julianDayForeground"))
                .frame(maxWidth:  julianDayWidth)
                .modifier(ASACapsuleBorder(topInset: verticalInset, leadingInset: 1.0, bottomInset: verticalInset, trailingInset: 1.0, color: Color("julianDayBorder"), width: 1.0))
        } else {
            if processedRow.calendarCode.isSunsetTransitionCalendar {
                let fractionalHours: Double = Double(processedRow.hour) + Double(processedRow.minute) / 60.0
                let degreesPerHour = 360.0 / 24.0
                let degrees = fractionalHours * degreesPerHour + 180.0
                ASASolarTimeView(degrees: degrees, dimension: 64.0, font: .body)
            } else {
            Watch(hour:  processedRow.hour, minute:  processedRow.minute, second:  processedRow.second, isNight:  nightTime(hour:  processedRow.hour, transitionType:  processedRow.transitionType), numberFormatter: numberFormatter)
            }
        }
    } // var body
} // struct ASAMiniClockView

//struct ASAMiniClockView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMiniClockView()
//    }
//}
