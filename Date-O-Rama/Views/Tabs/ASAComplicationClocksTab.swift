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
    
    func row(with key:  ASAClockArrayKey) -> Array<ASAClock> {
        switch key {
        case .threeLineLarge:
            return self.userData.threeLineLargeClocks.clocks
        case .twoLineLarge:
            return self.userData.twoLineLargeClocks.clocks
        case .app:
            return []
        case .twoLineSmall:
            return self.userData.twoLineSmallClocks.clocks
        case .oneLineLarge:
            return self.userData.oneLineLargeClocks.clocks
        case .oneLineSmall:
            return self.userData.oneLineSmallClocks.clocks
        } // switch key
    } // func row(with key:  ASAClockArrayKey) -> Array<ASARow>
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    ForEach(ASAClockArrayKey.complicationSections, id:  \.self) {complicationKey in
                        Section(header:  Text(NSLocalizedString(complicationKey.rawValue, comment: ""))) {
                            ForEach(self.row(with: complicationKey), id:  \.uuid) { row in
                                ASAClockCell(processedClock: ASAProcessedClock(clock: row, now: now, isForComplications: true), now: $now, shouldShowTime: false, shouldShowMiniCalendar: false, isForComplications: true, indexIsOdd: false)
                            }
                        }
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
