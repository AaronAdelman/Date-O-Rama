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
    
    func row(with key:  ASARowArrayKey) -> Array<ASARow> {
        switch key {
        case .threeLineLarge:
            return self.userData.threeLineLargeRows
        case .twoLineLarge:
            return self.userData.twoLineLargeRows
        case .app:
            return self.userData.mainRows
        case .twoLineSmall:
            return self.userData.twoLineSmallRows
        case .oneLineLarge:
            return self.userData.oneLineLargeRows
        case .oneLineSmall:
            return self.userData.oneLineSmallRows
        } // switch key
    } // func row(with key:  ASARowArrayKey) -> Array<ASARow>
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    ForEach(ASARowArrayKey.complicationSections, id:  \.self) {complicationKey in
                        Section(header:  Text(NSLocalizedString(complicationKey.rawValue, comment: ""))) {
                            ForEach(self.row(with: complicationKey), id:  \.uuid) { row in
                                // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                                ASAClockCell(processedRow: ASAProcessedRow(row: row, now: now), now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: false, shouldShowMiniCalendar: false, forComplications: true)
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
