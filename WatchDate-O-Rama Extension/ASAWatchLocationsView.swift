//
//  ASAWatchLocationsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchLocationsView: View {
    @EnvironmentObject var userData:  ASAModel
    @Binding var now:  Date
    
    var body: some View {
        ForEach($userData.mainClocks, id: \.self.id) {
            section
            in
            Form {
                let location = section.location
                let usesDeviceLocation = section.usesDeviceLocation
                let processed: Array<ASAProcessedClock> = section.clocks.map {
                    ASAProcessedClock(clock: $0.wrappedValue, now: now, isForComplications: false, location: location.wrappedValue, usesDeviceLocation: usesDeviceLocation.wrappedValue)
                }
                
                let headerColor = processed.dayPart.locationColor

                ASALocationWithClocksSectionView(now: $now, locationWithClocks: section, headerColor: headerColor, processed: processed)
                    .environmentObject(userData)
            }
        }
    }
} // struct ASAWatchLocationsView
