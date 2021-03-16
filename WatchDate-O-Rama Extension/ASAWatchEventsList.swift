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
    @State var shouldShowEvents:  ASAClockCellEventVisibility = .next
    @State var now:  Date

    var body: some View {
        List {
            Picker(selection: $shouldShowEvents, label: Text("Show Events")) {
                ForEach(ASAClockCellEventVisibility.watchCases, id: \.self) {
                    possibility
                    in
                    Text(possibility.text)
                }
            }

            ASAClockEventsForEach(processedRow: processedRow, visibility: shouldShowEvents, now: $now)
        } // List
    } // var body
} // struct ASAWatchEventsList

//struct ASAWatchEventsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAWatchEventsList()
//    }
//}
