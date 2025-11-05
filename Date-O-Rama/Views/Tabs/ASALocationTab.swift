//
//  ASALocationTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASALocationTab: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var locationWithClocks: ASALocationWithClocks
    
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    var body: some View {
        NavigationView {
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            let processed: Array<ASAProcessedClock> = locationWithClocks.clocks.map {
                ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
            }
            
            let dayPart: ASADayPart = processed.dayPart
            let cellColor = dayPart.locationColor
            
            let gradient = location.backgroundGradient(dayPart: dayPart)
            
            GeometryReader { geo in
                ASAList {
                    ASALocationWithClocksSectionView(
                        now: $now,
                        locationWithClocks: $locationWithClocks,
                       cellColor:cellColor,
                        processed: processed
                    )
                    .environmentObject(userData)
                }
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(gradient.ignoresSafeArea(.all))
                .padding(.top, geo.safeAreaInsets.top)
//                .padding(.bottom, geo.safeAreaInsets.bottom)
            }
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
} // struct ASAAllLocationsTab


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAAllLocationsTab().environmentObject(ASAModel.shared)
//    }
//}

