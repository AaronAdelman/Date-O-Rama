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
    @Binding var clocks:  Array<ASAClock>
    var processedClocksByPlace: Dictionary<ASALocation, Array<ASAProcessedClock>> {
        get {
            return self.clocks.processedRowsByPlaceName(now: now)
        } // get
    }
    @Binding var now:  Date
    
    func keys() -> Array<ASALocation> {
        var here: ASALocation
        //#if os(watchOS)
        //        here = ASALocationManager.shared.deviceLocationData.shortFormattedOneLineAddress
        //#else
        //        here = ASALocationManager.shared.deviceLocationData.formattedOneLineAddress
        //#endif
        
        here = ASALocationManager.shared.deviceLocationData
        
        return Array(self.processedClocksByPlace.keys).sorted(by: {
            element1, element2
            in
            if element1 == here {
                return true
            }
            
            if element2 == here {
                return false
            }
            
            return element1.shortFormattedOneLineAddress < element2.shortFormattedOneLineAddress
        })
    } // func keys() -> Array<String>
    
    var body:  some View {
        let processedClocks: [ASALocation : [ASAProcessedClock]] = self.processedClocksByPlace
        let keys: [ASALocation] = self.keys()
        ForEach(keys, id: \.self) {
            key
            in
            let processedClocksForKey: [ASAProcessedClock] = processedClocks[key]!
            let sectionHeaderEmoji = processedClocksForKey[0].flagEmojiString
            let sortedProcessedClocks = processedClocksForKey.sortedByCalendar
#if os(watchOS)
            let sectionHeaderTitle = key.shortFormattedOneLineAddress
#else
            let sectionHeaderTitle = key.formattedOneLineAddress
#endif
            
            ASAMainClocksByPlaceSectionView(now: $now, sectionHeaderTitle: sectionHeaderTitle, sectionHeaderEmoji: sectionHeaderEmoji, processedClocks: sortedProcessedClocks)
        }
    }
}

struct ASAMainClocksByPlaceSectionView: View {
    @Binding var now:  Date
    var sectionHeaderTitle: String
    var sectionHeaderEmoji: String
    var processedClocks: Array<ASAProcessedClock>
    
    var body: some View {
        Section(header: HStack {
            Text(sectionHeaderEmoji)
            Text(sectionHeaderTitle)
                .font(Font.headlineMonospacedDigit)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }) {
            ForEach(processedClocks.indices, id: \.self) {
                index
                in
                let processedRow = processedClocks[index]
                
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


struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainClocksByPlaceView(clocks: .constant([ASAClock.generic]), now: .constant(Date()))
    }
}
