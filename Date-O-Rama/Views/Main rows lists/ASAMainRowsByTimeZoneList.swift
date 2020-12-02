//
//  ASAMainRowsByTimeZoneList.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI


struct ASAMainRowsByTimeZoneList:  View {
    @EnvironmentObject var userData:  ASAUserData
    var groupingOption:  ASAClocksViewGroupingOption
    @Binding var rows:  Array<ASARow>

    var processedRowsByTimeZone: Dictionary<Int, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByTimeZone(now: now)
        } // get
    } // var processedRowsByFormattedDate: Dictionary<Int, Array<ASAProcessedRow>>

    @Binding var now:  Date

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
        ASAMainRowsByTimeZoneSublist(groupingOption: self.groupingOption, processedRowsByTimeZone: self.processedRowsByTimeZone, now: $now)
    }
}

struct ASAMainRowsByTimeZoneSublist:  View {
    @EnvironmentObject var userData:  ASAUserData
    var groupingOption:  ASAClocksViewGroupingOption
    var processedRowsByTimeZone: Dictionary<Int, Array<ASAProcessedRow>>
    @Binding var now:  Date

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
        ForEach(self.keys(groupingOption: groupingOption), id: \.self) {
            key
            in
            Section(header:  Text(self.processedRowsByTimeZone[key]![0].timeZoneString).font(Font.headlineMonospacedDigit)
                        .minimumScaleFactor(0.5).lineLimit(1)
            ) {
                ForEach(self.processedRowsByTimeZone[key]!, id:  \.row.uuid) {
                    processedRow
                    in

                    #if os(watchOS)
                    HStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
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
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: false, shouldShowTime: true, shouldShowCalendarPizzazztron: true)
                    }
                    #endif
                }
            }
        } // ForEach
    }
}
