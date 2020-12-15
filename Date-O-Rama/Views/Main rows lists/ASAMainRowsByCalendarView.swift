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
    var processedRowsByCalendar: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByCalendar(now: now)
        } // get
    }
    @Binding var now:  Date

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByCalendar.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        ASAMainRowsByCalendarSubview(processedRowsByCalendar: self.processedRowsByCalendar, now: $now)
    } // var body
} // struct ASAMainRowsByCalendarView

struct ASAMainRowsByCalendarSubview:  View {
    @EnvironmentObject var userData:  ASAUserData
    var processedRowsByCalendar: Dictionary<String, Array<ASAProcessedRow>>
    @Binding var now:  Date
    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByCalendar.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body:  some View {
        ForEach(self.keys, id: \.self) {
            key
            in
            Section(header:  HStack {
                        #if os(watchOS)
                        #else
                        ASACalendarSymbol()
                        #endif
                        Text(verbatim: "\(key)").font(Font.headlineMonospacedDigit)
                            .minimumScaleFactor(0.5).lineLimit(1)                }) {
                ForEach(self.processedRowsByCalendar[key]!, id:  \.row.uuid) {
                    processedRow
                    in

                    #if os(watchOS)
                    HStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    }
                    #else
                    NavigationLink(
                        destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences(code: .clocks)
                            }
                    ) {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
                    }
                    #endif

                }
            }
        }
    } // var body
}

struct ASAMainRowsByCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByCalendarView(rows: .constant([ASARow.generic()]), now: .constant(Date()))
    }
}
