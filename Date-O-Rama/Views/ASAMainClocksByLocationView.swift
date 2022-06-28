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
        ForEach($mainClocks, id: \.self.location.id) {
            section
            in
            ASAMainClocksByLocationSectionView(now: $now, locationWithClocks: section)
        }
    }
} // struct ASAMainClocksByLocationView:  View

struct ASAMainClocksByLocationSectionView: View {
    @Binding var now:  Date
    @Binding var locationWithClocks: ASALocationWithClocks
    
    @State private var showingNewClockDetailView = false
    
    var body: some View {
        let location = locationWithClocks.location
        let locationWithProcessedClocks = locationWithClocks.processed(now: now)
        
        let sectionHeaderEmoji = (location.regionCode ?? "").flag
#if os(watchOS)
        let sectionHeaderTitle = location.shortFormattedOneLineAddress
#else
        let sectionHeaderTitle = location.formattedOneLineAddress
#endif
        
        let sectionHeaderFont: Font = Font.title
        Section(header: HStack {
            Text(sectionHeaderEmoji)
            Text(sectionHeaderTitle)
            //.minimumScaleFactor(0.5)
            //                .lineLimit(1)
#if os(watchOS)
#else
            Spacer()
            Menu {
                Button(
                    action: {
                        self.showingNewClockDetailView = true
                        
                    }
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add clock")
                    } // HStack
                }
                
                Divider()
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName < $1.calendar.calendarCode.localizedName})
                    ASAUserData.shared.savePreferences(code: .clocks)
                }, label: {
                    Text("Sort by calendar name ascending")
                })
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName > $1.calendar.calendarCode.localizedName})
                    ASAUserData.shared.savePreferences(code: .clocks)
                }, label: {
                    Text("Sort by calendar name descending")
                })
            } label: {
                Image(systemName: "arrow.down.square.fill")
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView(now:  now, tempLocation: location)
            }
#endif
        }
            .font(sectionHeaderFont)
        ) {
            ForEach( 0..<locationWithProcessedClocks.processedClocks.count) {
                index
                in
                let processedClock = locationWithProcessedClocks.processedClocks[index]
                
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
