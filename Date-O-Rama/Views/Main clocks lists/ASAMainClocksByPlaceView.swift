//
//  ASAMainRowsByPlaceNameView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksByPlaceView:  View {
    @EnvironmentObject var userData:  ASAUserData
    @Binding var rows:  Array<ASAClock>
    var processedRowsByPlace: Dictionary<String, Array<ASAProcessedClock>> {
        get {
            return self.rows.processedRowsByPlaceName(now: now)
        } // get
    }
    @Binding var now:  Date
    
    func keys() -> Array<String> {
        var here: String?
#if os(watchOS)
        here = ASALocationManager.shared.deviceLocationData.shortFormattedOneLineAddress
#else
        here = ASALocationManager.shared.deviceLocationData.formattedOneLineAddress
#endif
        
        return Array(self.processedRowsByPlace.keys).sorted(by: {
            element1, element2
            in
            if element1 == here {
                return true
            }
            
            if element2 == here {
                return false
            }
            
            return element1 < element2
        })
    } // func keys() -> Array<String>
    
    var body:  some View {
        let processedRows: [String : [ASAProcessedClock]] = self.processedRowsByPlace
        let keys: [String] = self.keys()
        ForEach(keys, id: \.self) {
            key
            in
            let processedRowsForKey: [ASAProcessedClock] = processedRows[key]!
            let sectionHeaderEmoji = processedRowsForKey[0].flagEmojiString
            let sortedProcessedRows = processedRowsForKey.sortedByCalendar

            Section(header: HStack {
                Text(sectionHeaderEmoji)
                Text("\(key)").font(Font.headlineMonospacedDigit)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }) {
                ForEach(sortedProcessedRows.indices, id: \.self) {
                    index
                    in
                    let processedRow = sortedProcessedRows[index]
                    
#if os(watchOS)
                    let shouldShowTime         = false
                    let shouldShowMiniCalendar = false
                    let indexIsOdd             = false
#else
                    let shouldShowTime         = true
                    let shouldShowMiniCalendar = true
                    let indexIsOdd             = index % 2 == 1
#endif
                    ASAClockCell(processedClock: processedRow, now: $now, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, isForComplications: false, indexIsOdd: indexIsOdd)
                }
            }
        }
    }
}


struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainClocksByPlaceView(rows: .constant([ASAClock.generic]), now: .constant(Date()))
    }
}
