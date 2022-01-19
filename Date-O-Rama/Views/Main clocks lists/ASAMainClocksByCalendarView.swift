//
//  ASAMainClocksByCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksByCalendarView:  View {
    @EnvironmentObject var userData:  ASAUserData
    
    @Binding var rows:  Array<ASAClock>
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    //    var shouldShowTimeToNextDay:  Bool
    
//    var isForComplications:  Bool
    
    var body:  some View {
        let processedRows: [String : [ASAProcessedClock]] = self.rows.processedRowsByCalendar(now: now)
        let keys: [String] = Array(processedRows.keys).sorted()

        ForEach(keys, id: \.self) {
            key
            in
            Section(header: Text(verbatim: key).font(Font.headlineMonospacedDigit)) {
                let sortedProcessedRows: [ASAProcessedClock] = processedRows[key]!.sorted(secondaryGroupingOption)
                ForEach(sortedProcessedRows.indices, id: \.self) {
                    index
                    in
                    let processedRow = sortedProcessedRows[index]

                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: false)
                    #else
                    let indexIsOdd = index % 2 == 1

                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
                    #endif
                    
                }
            }
        }
    } // var body
}

struct ASAMainRowsByCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainClocksByCalendarView(rows: .constant([ASAClock.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest))
    }
}
