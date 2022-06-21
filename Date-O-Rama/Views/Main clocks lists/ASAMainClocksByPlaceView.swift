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
    @Binding var now:  Date
    
    var body:  some View {
        let sections: Array<ASALocationWithProcessedClocks> = self.clocks.processedRowsByPlaceName(now: now)
        ForEach(sections, id: \.self.location.id) {
            section
            in
            let processedClocks: [ASAProcessedClock] = section.processedClocks
            let location = section.location
            let sectionHeaderEmoji = (location.regionCode ?? "").flag
            let sortedProcessedClocks = processedClocks.sortedByCalendar
#if os(watchOS)
            let sectionHeaderTitle = location.shortFormattedOneLineAddress
#else
            let sectionHeaderTitle = location.formattedOneLineAddress
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
