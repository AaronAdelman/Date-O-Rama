//
//  ASAPlainMainRowsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAPlainMainRowsView:  View {
    @EnvironmentObject var userData:  ASAUserData
    
    var groupingOption:  ASAClocksViewGroupingOption
    
    @Binding var rows:  Array<ASARow>
    var processedRows:  Array<ASAProcessedRow> {
        get {
            switch groupingOption {
//            case .plain:
//                return rows.processed(now: now)

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
            } // switch groupingOption
        } // get
    } // var processedRows
    @Binding var now:  Date

    var forComplications:  Bool
    
    var body: some View {
        //        List {
        #if os(watchOS)
        
        ForEach(self.processedRows, id:  \.row.uuid) {
            processedRow
            in
            HStack {
                ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
            }
        } // ForEach
        
        #else
        
        ForEach(self.processedRows, id:  \.row.uuid) {
            processedRow
            in
            
            NavigationLink(destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences(code: .clocks)
                            }
            ) {
                ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
            }
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
        #endif
        //        } // List
    }
} // struct ASAPlainMainRowsView:  View

struct ASAPlainMainRowsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAPlainMainRowsView(groupingOption: .byPlaceName, rows: .constant([ASARow.generic]), now: .constant(Date()), forComplications: false)
    }
}
