//
//  ASAMainRowsByTimeZoneView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI


struct ASAMainRowsByTimeZoneView:  View {
    @EnvironmentObject var userData:  ASAUserData
    var primaryGroupingOption:  ASAClocksViewGroupingOption
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    @Binding var rows:  Array<ASARow>
    
    var processedRowsByTimeZone: Dictionary<Int, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByTimeZone(now: now)
        } // get
    } // var processedRowsByFormattedDate: Dictionary<Int, Array<ASAProcessedRow>>
    
    @Binding var now:  Date
    //    var shouldShowTimeToNextDay:  Bool
    
//    var isForComplications:  Bool
    
    func keys(groupingOption:  ASAClocksViewGroupingOption) -> Array<Int> {
        switch groupingOption {
        case .byTimeZoneWestToEast:
            return Array(self.processedRowsByTimeZone.keys).sorted(by:  <)
            
        case .byTimeZoneEastToWest:
            return Array(self.processedRowsByTimeZone.keys).sorted(by:  >)
            
        default:
            return []
        } // switch groupingOption
    } // func keys(groupingOption:  ASAClocksViewGroupingOption) -> Array<Int>
    
    var body:  some View {
        let keys: [Int] = self.keys(groupingOption: primaryGroupingOption)
        ForEach(keys, id: \.self) {
            key
            in
            Section(header:  Text(self.processedRowsByTimeZone[key]![0].timeZoneString).font(Font.headlineMonospacedDigit)
                        .minimumScaleFactor(0.5).lineLimit(1)
            ) {
                let sortedProcessedRows: [ASAProcessedRow] = self.processedRowsByTimeZone[key]!.sorted(secondaryGroupingOption)
                ForEach(0..<sortedProcessedRows.count) {
                    let processedRow = sortedProcessedRows[$0]
                    
                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowMiniCalendar: false, isForComplications: false, indexIsOdd: false)
                    #else
                    let indexIsOdd = $0 % 2 == 1
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
                    ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: processedRow.row.eventVisibility, indexIsOdd: indexIsOdd)
                    #endif
                }
            }
        } // ForEach
    }
}
