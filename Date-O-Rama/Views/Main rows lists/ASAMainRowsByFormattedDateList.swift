//
//  ASAMainRowsByFormattedDateList.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsByFormattedDateList:  View {
    @EnvironmentObject var userData:  ASAUserData
    
    @Binding var rows:  Array<ASARow>
    var processedRowsByFormattedDate: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedByFormattedDate(now: now)
        }
    }
    @Binding var now:  Date
    var INSET:  CGFloat
    
    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByFormattedDate.keys).sorted()
        } // get
    } // var keys:  Array<String>
    
    var body: some View {
        //        List {
        ForEach(self.keys, id: \.self) {
            key
            in
            Section(header:  Text("\(key)").font(Font.headline.monospacedDigit())
                        .minimumScaleFactor(0.5).lineLimit(1)
            ) {
                ForEach(self.processedRowsByFormattedDate[key]!, id:  \.row.uuid) {
                    processedRow
                    in
                    
                    #if os(watchOS)
                    HStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    }
                    #else
                    NavigationLink(
                        destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences(code: .clocks)
                            }
                    ) {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                    }
                    #endif
                    
                }
            }
        } // ForEach
        //        } // List
    } // var body
    
    func deleteItem(at offsets: IndexSet, in: ASAProcessedRow) {
        debugPrint(#file, #function )
    }
} // struct ASAMainRowsByFormattedDateList

struct ASAMainRowsByFormattedDateList_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByFormattedDateList(rows: .constant([ASARow.generic()]), now: .constant(Date()), INSET: 25.0)
    }
}
