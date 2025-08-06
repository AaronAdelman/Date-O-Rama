//
//  ASAComplicationClocksTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-06-09.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAComplicationClocksTab: View {
    @EnvironmentObject var userData:  ASAModel
    @Binding var now: Date
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    ForEach(ASAClockArrayKey.complicationSections, id:  \.self) {
                        complicationKey
                        in
                        ASAComplicationSectionView(complicationKey: complicationKey, now: $now).environmentObject(userData)
                    }
                } // List
                .listStyle(InsetGroupedListStyle())
                
                .colorScheme(.dark)
                .navigationTitle("Watch")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
} // struct ASAComplicationClocksTab


struct ASAComplicationSectionView: View {
    @EnvironmentObject var userData:  ASAModel

    var complicationKey: ASAClockArrayKey
    @Binding var now: Date
        
    func locationWithClocksArray(with key: ASAClockArrayKey) -> ASALocationWithClocks {
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
    
    @State private var showingDetailView = false
    
    var body: some View {
        let locationWithClocks = self.locationWithClocksArray(with: complicationKey)
        let location = locationWithClocks.location
            
        Section(header: VStack {
            Text(NSLocalizedString(complicationKey.rawValue, comment: ""))
                .lineLimit(2)
            HStack {
                ASALocationWithClocksSectionHeader(locationWithClocks: locationWithClocks, now: now, shouldCapitalize: true)

                if location.type == .EarthLocation {
                    Spacer()
                    Menu {
                        Button(
                            action: {
                                self.showingDetailView = true
                                
                            }
                        ) {
                            ASAGetInfoLabel()
                        }
                    } label: {
                        ASALocationMenuSymbol()
                    }
                    .sheet(isPresented: self.$showingDetailView, onDismiss: {
                    }) {
                        ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: false).environmentObject(userData).environmentObject(userData).environmentObject(ASALocationManager.shared)
                    }
                }
            } // HStack
        }, content: {
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            ForEach(locationWithClocks.clocks, id:  \.uuid) {
                clock
                in
                let processedClock: ASAProcessedClock = ASAProcessedClock(clock: clock, now: now, isForComplications: true, location: location, usesDeviceLocation: usesDeviceLocation)
                ASAClockCell(processedClock: processedClock, now: $now, shouldShowTime: false, shouldShowMiniCalendar: false, isForComplications: true, indexIsOdd: false, clock: clock, location: location).environmentObject(userData)
            }
        })
    }
}

//struct ASAComplicationClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAComplicationClocksTab()
//    }
//}
