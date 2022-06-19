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
            Section(header: HStack {
                Text(processedRows[key]![0].flagEmojiString)
                Text("\(key)").font(Font.headlineMonospacedDigit)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }) {
                let sortedProcessedRows = processedRows[key]!.sortedByCalendar
                ForEach(sortedProcessedRows.indices, id: \.self) {
                    index
                    in
                    let processedRow = sortedProcessedRows[index]
                    
#if os(watchOS)
                    ASAClockCell(processedClock: processedRow, now: $now, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: false)
#else
                    let indexIsOdd = index % 2 == 1
                    ASAClockCell(processedClock: processedRow, now: $now, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
#endif
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
