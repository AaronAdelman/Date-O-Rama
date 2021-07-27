//
//  ASAMainRowsByCalendarView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsByCalendarView:  View {
    @EnvironmentObject var userData:  ASAUserData
    
    @Binding var rows:  Array<ASARow>
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    //    var shouldShowTimeToNextDay:  Bool
    
//    var isForComplications:  Bool
    
    var body:  some View {
        let processedRows: [String : [ASAProcessedRow]] = self.rows.processedRowsByCalendar(now: now)
        let keys: [String] = Array(processedRows.keys).sorted()

        ForEach(keys, id: \.self) {
            key
            in
            Section(header: Text(verbatim: key).font(Font.headlineMonospacedDigit)) {
                let sortedProcessedRows: [ASAProcessedRow] = processedRows[key]!.sorted(secondaryGroupingOption)
                ForEach(0..<sortedProcessedRows.count) {
                    let processedRow = sortedProcessedRows[$0]
                    
                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: false)
                    #else
                    let indexIsOdd = $0 % 2 == 1

                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
                    ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: processedRow.row.eventVisibility, indexIsOdd: indexIsOdd)
                    #endif
                    
                }
            }
        }
    } // var body
}

struct ASAMainRowsByCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByCalendarView(rows: .constant([ASARow.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest))
    }
}
