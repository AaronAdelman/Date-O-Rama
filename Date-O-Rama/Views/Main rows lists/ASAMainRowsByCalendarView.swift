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
    
    var forComplications:  Bool
    
    var body:  some View {
        let processedRows: [String : [ASAProcessedRow]] = self.rows.processedRowsByCalendar(now: now)
        let keys: [String] = Array(processedRows.keys).sorted()

        ForEach(keys, id: \.self) {
            key
            in
            Section(header: Text(verbatim: key).font(Font.headlineMonospacedDigit)) {
                ForEach(processedRows[key]!.sorted(secondaryGroupingOption), id:  \.row.uuid) {
                    processedRow
                    in
                    
                    #if os(watchOS)
                    //                    HStack {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                    //                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    //                    }
                    #else
                    // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                    //                    ZStack {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                    ASAClockEventsSubcell(processedRow: processedRow, forComplications: forComplications, now: $now, eventVisibility: processedRow.row.eventVisibility)

                    //                        NavigationLink(
                    //                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                    //                                .onReceive(processedRow.row.objectWillChange) { _ in
                    //                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                    //                                    self.userData.objectWillChange.send()
                    //                                    self.userData.savePreferences(code: .clocks)
                    //                                }
                    //                        ) {
                    //                        }
                    //                        .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
                    //                    } // ZStack
                    //                    .listRowInsets(.zero)
                    #endif
                    
                }
            }
        }
    } // var body
}

struct ASAMainRowsByCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByCalendarView(rows: .constant([ASARow.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest), forComplications: false)
    }
}
