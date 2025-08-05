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
                ASALocationWithClocksSectionView(now: $now, locationWithClocks: section)
                    .environmentObject(userData)
            }
        }
    }
} // struct ASAWatchLocationsView
