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
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            let processed: Array<ASAProcessedClock> = locationWithClocks.clocks.map {
                ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
            }
            
            let dayPart: ASADayPart = processed.dayPart
            let headerColor = dayPart.locationColor
            let imageName: String = {
                switch location.type {
                case .earthUniversal:
                    return "Earth"
                    
                case .marsUniversal:
                    return "Mars"
                    
                case .earthLocation:
                    switch dayPart {
                    case .day:
                        return "dayImage"
                    case .night:
                        return "nightImage"
                    case .unknown:
                        return "unknownBackground"
                    }
                }
            }()
            
            GeometryReader { geo in
                ZStack
//                (alignment: .top)
                {
                    Image(imageName)
                        .resizable()
//                        .scaledToFill()
                        .scaledToFit()
                        .ignoresSafeArea()
                    
                    List {
                        ASALocationWithClocksSectionView(
                            now: $now,
                            locationWithClocks: $locationWithClocks,
                            headerColor: headerColor,
                            processed: processed
                        )
                        .environmentObject(userData)
                    }
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
                    .padding(.top, geo.safeAreaInsets.top) // Dynamically match toolbar/nav bar height
                    .padding(.bottom, geo.safeAreaInsets.bottom) // Dynamically match toolbar/nav bar height
                }
//                .edgesIgnoringSafeArea(.bottom) // keep background full bleed
            }
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
