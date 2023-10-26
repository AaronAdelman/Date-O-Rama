//
//  ASAWatchEventsList.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 07/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchEventsList: View {
    var processedClock:  ASAProcessedClock
    @State var eventVisibility:  ASAClockCellTimeEventVisibility = .defaultValue
    @State var allDayEventVisibility: ASAClockCellDateEventVisibility = .defaultValue
    @State var now:  Date

    var body: some View {
        List {
            Picker(selection: $eventVisibility, label: Text("Show Events")) {
                ForEach(ASAClockCellTimeEventVisibility.allCases, id: \.self) {
                    possibility
                    in
                    HStack {
                        Image(systemName: possibility.symbolName)
                        Text(possibility.text)
                    } // HStack
                } // ForEach
            }
            
            Picker(selection: $allDayEventVisibility, label: Text("Show All-Day Events")) {
                ForEach(ASAClockCellDateEventVisibility.allCases, id: \.self) {
                    possibility
                    in
                    HStack {
                        //                        Image(systemName: possibility.symbolName)
                        Text(possibility.text)
                    } // HStack
                } // ForEach
            }
            let numberOfDateEvents: Int = processedClock.dateEvents.count
            if numberOfDateEvents > 0 {
                let dateEvents = processedClock.dateEvents.trimmed(dateEventVisibility: allDayEventVisibility, now: now)
                ASAClockEventsForEach(processedClock: processedClock, events: dateEvents, now: $now)
            }
            let numberOfTimeEvents: Int = processedClock.timeEvents.count
            if numberOfTimeEvents > 0 {
                let timeEvents = processedClock.timeEvents.trimmed(timeEventVisibility: eventVisibility, now: now)
                ASAClockEventsForEach(processedClock: processedClock, events: timeEvents, now: $now)
            }
        } // List
    } // var body
} // struct ASAWatchEventsList

//struct ASAWatchEventsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAWatchEventsList()
//    }
//}
