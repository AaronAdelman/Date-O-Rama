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
    
    private func backgroundGradient(for location: ASALocation, dayPart: ASADayPart) -> LinearGradient {
        let dayTop      = Color("dayTop")
        let dayBottom   = Color("dayBottom")
        let nightTop    = Color("nightTop")
        let nightBottom = Color("nightBottom")
        let colors: [Color] = {
            switch location.type {
            case .earthUniversal, .marsUniversal:
                return [.black, .brown]
            case .earthLocation:
                switch dayPart {
                case .day:
                    return [dayTop, dayTop, dayBottom]
                case .night:
                    return [nightTop, nightTop, nightBottom]
                case .unknown:
                    return [.black, .brown]
                }
            }
        }()
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
    
    var body: some View {
        NavigationView {
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            let processed: Array<ASAProcessedClock> = locationWithClocks.clocks.map {
                ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
            }
            
            let dayPart: ASADayPart = processed.dayPart
            let cellColor = dayPart.locationColor
            
            let gradient = backgroundGradient(for: location, dayPart: dayPart)
            
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
                .padding(.top, geo.safeAreaInsets.top)
                .padding(.bottom, geo.safeAreaInsets.bottom)
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(gradient.ignoresSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
} // struct ASALocationsTab


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationsTab().environmentObject(ASAModel.shared)
//    }
//}

