//
//  ASAWatchEventsList.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 07/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchEventsList: View {
    var processedRow:  ASAProcessedRow
    @State var eventVisibility:  ASAClockCellEventVisibility = .defaultValue
    @State var allDayEventVisibility: ASAClockCellAllDayEventVisibility = .defaultValue
    @State var now:  Date

    var body: some View {
        List {
            Picker(selection: $eventVisibility, label: Text("Show Events")) {
                ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                    possibility
                    in
                    HStack {
                        Image(systemName: possibility.symbolName)
                        Text(possibility.text)
                    } // HStack
                } // ForEach
            }
            
            Picker(selection: $allDayEventVisibility, label: Text("Show All-Day Events")) {
                ForEach(ASAClockCellAllDayEventVisibility.allCases, id: \.self) {
                    possibility
                    in
                    HStack {
//                        Image(systemName: possibility.symbolName)
                        Text(possibility.text)
                    } // HStack
                } // ForEach
            }


            ASAClockEventsForEach(processedRow: processedRow, visibility: eventVisibility, allDayEventVisibility: allDayEventVisibility, now: $now)
        } // List
    } // var body
} // struct ASAWatchEventsList

//struct ASAWatchEventsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAWatchEventsList()
//    }
//}
