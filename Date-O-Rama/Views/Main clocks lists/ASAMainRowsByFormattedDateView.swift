//
//  ASAMainRowsByFormattedDateView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsByFormattedDateView:  View {
    @EnvironmentObject var userData:  ASAUserData
    
    @Binding var rows:  Array<ASARow>
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    //    var shouldShowTimeToNextDay:  Bool
    
//    var isForComplications:  Bool
    
    var body: some View {
        let processedRows: [String : [ASAProcessedRow]] = self.rows.processedByFormattedDate(now: now)
        let keys = Array(processedRows.keys).sorted()
        
        ForEach(keys, id: \.self) {
            key
            in
            Section(header:  Text("\(key)").font(Font.headlineMonospacedDigit)
                        .minimumScaleFactor(0.5).lineLimit(1)
            ) {
                let sortedProcessedRows: [ASAProcessedRow] = processedRows[key]!.sorted(secondaryGroupingOption)
                ForEach(sortedProcessedRows.indices, id: \.self) {
                    index
                    in
                    let processedRow = sortedProcessedRows[index]

                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: false)
                    #else
                    let indexIsOdd = index % 2 == 1
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
//                    ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: processedRow.row.eventVisibility, indexIsOdd: indexIsOdd)
                    #endif
                }
            }
        } // ForEach
    }
}

struct ASAMainRowsByFormattedDateView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByFormattedDateView(rows: .constant([ASARow.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest))
    }
}
