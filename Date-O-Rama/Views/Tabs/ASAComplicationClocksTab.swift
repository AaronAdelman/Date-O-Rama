//
//  ASAComplicationClocksTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-06-09.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAComplicationClocksTab: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isNavigationBarHidden:  Bool = true
    
    func clockArray(with key: ASAClockArrayKey) -> ASALocationWithClocks {
        switch key {
        case .threeLineLarge:
            return self.userData.threeLineLargeClocks
        case .twoLineLarge:
            return self.userData.twoLineLargeClocks
        case .app:
            return self.userData.mainClocks[0]
        case .twoLineSmall:
            return self.userData.twoLineSmallClocks
        case .oneLineLarge:
            return self.userData.oneLineLargeClocks
        case .oneLineSmall:
            return self.userData.oneLineSmallClocks
        } // switch key
    } // func clockArray(with key: ASAClockArrayKey) -> ASALocationWithClocks
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    ForEach(ASAClockArrayKey.complicationSections, id:  \.self) {complicationKey in
                        let locationWithClocks = self.clockArray(with: complicationKey)
                        let location = locationWithClocks.location
                        
                        let sectionHeaderEmoji = (location.regionCode ?? "").flag
                        let sectionHeaderTitle = location.formattedOneLineAddress
                        let sectionHeaderFont: Font = Font.title2
                        
                        Section(header:  HStack {
                            Text(NSLocalizedString(complicationKey.rawValue, comment: ""))
                                .lineLimit(3)
                            Text(" • ")
                            Text(sectionHeaderEmoji)
                            Text(sectionHeaderTitle)
                                .lineLimit(3)
                        }
                            .font(sectionHeaderFont)
                                , content: {
                            ForEach(locationWithClocks.clocks, id:  \.uuid) {
                                clock
                                in
                                ASAClockCell(processedClock: ASAProcessedClock(clock: clock, now: now, isForComplications: true), now: $now, shouldShowTime: false, shouldShowMiniCalendar: false, isForComplications: true, indexIsOdd: false)
                            }
                        })
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                .colorScheme(.dark)
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            self.isNavigationBarHidden = true
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            self.now = Date()
        }
    }
} // struct ASAComplicationClocksTab

struct ASAComplicationClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAComplicationClocksTab()
    }
}
