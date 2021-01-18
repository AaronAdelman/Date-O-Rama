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
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    var shouldShowTimeToNextDay:  Bool

    var forComplications:  Bool

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByCalendar.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        ASAMainRowsByCalendarSubview(processedRowsByCalendar: self.processedRowsByCalendar, now: $now, secondaryGroupingOption: $secondaryGroupingOption, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications:  forComplications)
    } // var body
} // struct ASAMainRowsByCalendarView

struct ASAMainRowsByCalendarSubview:  View {
    @EnvironmentObject var userData:  ASAUserData
    var processedRowsByCalendar: Dictionary<String, Array<ASAProcessedRow>>
    @Binding var now:  Date
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    var shouldShowTimeToNextDay:  Bool
    var forComplications:  Bool

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByCalendar.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body:  some View {
        ForEach(self.keys, id: \.self) {
            key
            in
            Section(header: Text(verbatim: key).font(Font.headlineMonospacedDigit)) {
                ForEach(self.processedRowsByCalendar[key]!.sorted(secondaryGroupingOption), id:  \.row.uuid) {
                    processedRow
                    in

                    #if os(watchOS)
                    HStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications: forComplications)
                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    }
                    #else
                    // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                    ZStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications: forComplications)
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
                    #endif

                }
            }
        }
    } // var body
}

struct ASAMainRowsByCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByCalendarView(rows: .constant([ASARow.generic]), now: .constant(Date()), secondaryGroupingOption: .constant(.eastToWest), shouldShowTimeToNextDay: true, forComplications: false)
    }
}
