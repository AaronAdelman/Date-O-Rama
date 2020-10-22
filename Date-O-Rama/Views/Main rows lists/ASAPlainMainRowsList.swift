//
//  ASAPlainMainRowsList.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAPlainMainRowsList:  View {
    @EnvironmentObject var userData:  ASAUserData

    var groupingOption:  ASAClocksViewGroupingOption

    @Binding var rows:  Array<ASARow>
    var processedRows:  Array<ASAProcessedRow> {
        get {
            switch groupingOption {
            case .plain:
                return rows.processed(now: now)

            case .westToEast:
                return rows.processedWestToEast(now: now)

            case .eastToWest:
                return rows.processedEastToWest(now: now)

            case .northToSouth:
                return rows.processedNorthToSouth(now: now)

            case .southToNorth:
                return rows.processedSouthToNorth(now: now)

            default:
                return rows.processed(now: now)
            }

        } // get
    } // var processedRows
    @Binding var now:  Date
    var INSET:  CGFloat

    var body: some View {
        List {
            ForEach(self.processedRows, id:  \.row.uuid) {
                processedRow
                in

                #if os(watchOS)
                ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                #else
                NavigationLink(destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                ) {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                }
                #endif
                
            } // ForEach
            .onMove { (source: IndexSet, destination: Int) -> Void in
                self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                self.userData.savePreferences(code: .clocks)
            }
            .onDelete { indices in
                indices.forEach {
                    // debugPrint("\(#file) \(#function)")
                    self.userData.mainRows.remove(at: $0)
                }
                self.userData.savePreferences(code: .clocks)
            }
        } // List
    }
} // struct ASAPlainMainRowsList:  View

struct ASAPlainMainRowsList_Previews: PreviewProvider {
    static var previews: some View {
        ASAPlainMainRowsList(groupingOption: .plain, rows: .constant([ASARow.generic()]), now: .constant(Date()), INSET: 25.0)
    }
}
