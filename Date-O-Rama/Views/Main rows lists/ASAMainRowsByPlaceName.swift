//
//  ASAMainRowsByPlaceName.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsByPlaceName:  View {
    @EnvironmentObject var userData:  ASAUserData

    @Binding var rows:  Array<ASARow>
    var processedRowsByPlaceName: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByPlaceName(now: now)
        } // get
    }
    @Binding var now:  Date
    var INSET:  CGFloat

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByPlaceName.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        List {
            ForEach(self.keys, id: \.self) {
                key
                in
                Section(header: HStack {
                    #if os(watchOS)
                    #else
                    Text(self.processedRowsByPlaceName[key]![0].emojiString)
                    #endif
                    Text("\(key)").font(Font.headline.monospacedDigit())
                        .multilineTextAlignment(.leading).lineLimit(2)

                }) {
                    ForEach(self.processedRowsByPlaceName[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        #if os(watchOS)
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: false, INSET: INSET, shouldShowTime: true)
                        #else
                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                            ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: false, INSET: INSET, shouldShowTime: true)
                        }
                        #endif
                    }
                }
            }
        } // List
    } // var body
} // struct ASAMainRowsByPlaceName
struct ASAMainRowsByPlaceName_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByPlaceName(rows: .constant([ASARow.generic()]), now: .constant(Date()), INSET: 25.0)
    }
}
