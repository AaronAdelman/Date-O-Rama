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
    
    let isAnimatingToList: Bool
    
    @State var isNavigationBarHidden: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                ASALocationWithClocksSectionView(now: $now, locationWithClocks: $locationWithClocks)
                    .environmentObject(userData)
            }
            .listStyle(GroupedListStyle())
            .navigationBarHidden(self.isNavigationBarHidden)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
            .onAppear {
                self.isNavigationBarHidden = true
            }
            // Add shrinking animation for reverse transition
            .scaleEffect(isAnimatingToList ? 0.85 : 1.0)
            .opacity(isAnimatingToList ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isAnimatingToList)
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
