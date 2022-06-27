//
//  ASAMainRowsByPlaceNameView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksByLocationView:  View {
    @EnvironmentObject var userData:  ASAUserData
    @Binding var mainClocks:  Array<ASALocationWithClocks>
    @Binding var now:  Date
    
    var body:  some View {
        let sections: Array<ASALocationWithProcessedClocks> = mainClocks.processed(now: now)
        ForEach(sections, id: \.self.location.id) {
            section
            in
            let processedClocks: [ASAProcessedClock] = section.processedClocks
            let sortedProcessedClocks = processedClocks.sortedByCalendar
            let location = section.location
            
            ASAMainClocksByLocationSectionView(now: $now, location: location, processedClocks: sortedProcessedClocks)
        }
    }
} // struct ASAMainClocksByLocationView:  View

struct ASAMainClocksByLocationSectionView: View {
    @Binding var now:  Date
    var location: ASALocation
    var processedClocks: Array<ASAProcessedClock>
    
    @State private var showingNewClockDetailView = false
    
    var body: some View {
        let sectionHeaderEmoji = (location.regionCode ?? "").flag
#if os(watchOS)
        let sectionHeaderTitle = location.shortFormattedOneLineAddress
#else
        let sectionHeaderTitle = location.formattedOneLineAddress
#endif
        
        Section(header: HStack {
            Text(sectionHeaderEmoji)
            Text(sectionHeaderTitle)
                .font(Font.headlineMonospacedDigit)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
#if os(watchOS)
#else
            Spacer()
            Button(
                action: {
                    self.showingNewClockDetailView = true
                    
                }
            ) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(Font.headlineMonospacedDigit)
                    //                    Text("Add clock")
                } // HStack
            }
            .foregroundColor(.accentColor)
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView(now:  now, tempLocation: location)
            }
#endif
        }) {
            ForEach(processedClocks.indices, id: \.self) {
                index
                in
                let processedClock = processedClocks[index]
                
#if os(watchOS)
                let shouldShowTime         = false
                let shouldShowMiniCalendar = false
                let indexIsOdd             = false
#else
                let shouldShowTime         = true
                let shouldShowMiniCalendar = true
                let indexIsOdd             = index % 2 == 1
#endif
                ASAClockCell(processedClock: processedClock, now: $now, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, isForComplications: false, indexIsOdd: indexIsOdd)
            }
        }
    }
}


//struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMainClocksByLocationView(mainClocks: .constant(ASALocationWithClocks(location: ASALocation.NullIsland, clocks: [ASAClock.generic])), now: .constant(Date()))
//    }
//}
