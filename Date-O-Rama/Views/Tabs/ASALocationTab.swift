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
    let processedClocks: Array<ASAProcessedClock>
    
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    var body: some View {
        let dayPart: ASADayPart = processedClocks.dayPart
        let cellColor = dayPart.locationColor
                
        GeometryReader { geo in
            ASAList {
                ASALocationWithClocksSectionView(now: $now, locationWithClocks: $locationWithClocks, cellColor: cellColor, processed: processedClocks)
                .environmentObject(userData)
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .padding(.top, geo.safeAreaInsets.top)
        }
        .navigationBarTitle("", displayMode: .inline)
    }
} // struct ASAAllLocationsTab


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAAllLocationsTab().environmentObject(ASAModel.shared)
//    }
//}

