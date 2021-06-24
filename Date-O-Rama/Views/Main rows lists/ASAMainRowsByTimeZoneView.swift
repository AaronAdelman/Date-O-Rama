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
                ForEach(self.processedRowsByTimeZone[key]!.sorted(secondaryGroupingOption), id:  \.row.uuid) {
                    processedRow
                    in
                    
                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowMiniCalendar: false, isForComplications: false)
                    #else
                    // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false)
                    ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: processedRow.row.eventVisibility)
                    #endif
                }
            }
        } // ForEach
    }
}
