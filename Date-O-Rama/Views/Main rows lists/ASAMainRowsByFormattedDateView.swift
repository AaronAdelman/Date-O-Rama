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
    var processedRowsByFormattedDate: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedByFormattedDate(now: now)
        }
    }
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
//    var shouldShowTimeToNextDay:  Bool
    
    var forComplications:  Bool

    var body: some View {
        ASAMainRowsByFormattedDateSubview(processedRowsByFormattedDate: self.processedRowsByFormattedDate, now: $now, secondaryGroupingOption: $secondaryGroupingOption, forComplications:  forComplications)
    } // var body
} // struct ASAMainRowsByFormattedDateView

struct ASAMainRowsByFormattedDateSubview:  View {
    @EnvironmentObject var userData:  ASAUserData
    var processedRowsByFormattedDate: Dictionary<String, Array<ASAProcessedRow>>
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
//    var shouldShowTimeToNextDay:  Bool

    var forComplications:  Bool

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByFormattedDate.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        ForEach(self.keys, id: \.self) {
            key
            in
            Section(header:  Text("\(key)").font(Font.headlineMonospacedDigit)
                        .minimumScaleFactor(0.5).lineLimit(1)
            ) {
                ForEach(self.processedRowsByFormattedDate[key]!.sorted(secondaryGroupingOption), id:  \.row.uuid) {
                    processedRow
                    in

                    #if os(watchOS)
                    HStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    }
                    #else
                    // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                    ZStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                        }
                        .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
                    } // ZStack
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    #endif

                }
            }
        } // ForEach
    }
}

struct ASAMainRowsByFormattedDateView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByFormattedDateView(rows: .constant([ASARow.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest), forComplications:  false)
    }
}
