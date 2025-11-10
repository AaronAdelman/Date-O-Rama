//
//  ASAAllLocationsTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASAAllLocationsTab: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var selectedTabIndex: Int
    @Binding var isShowingLocationSheet: Bool
    
    @State private var isShowingNewLocationView = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color("locationsBackground")
                    .ignoresSafeArea()
                
                let frameHeight: CGFloat? = proxy.safeAreaInsets.top
                
                Spacer()
                    .frame(height: frameHeight)
                
                List {
                    ForEach(Array(userData.mainClocks.enumerated()), id: \.element.id) { index, locationWithClocks in
                        ASALocationWithClocksCell(
                            locationWithClocks: locationWithClocks,
                            now: $now)
                        .environmentObject(userData)
                        .onTapGesture {
                            selectedTabIndex = index
                            isShowingLocationSheet = true
                        }
                    }
                    .onMove(perform: moveClock)
                } // List
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
                .listStyle(.plain)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
            } // ZStack
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {
                            isShowingNewLocationView = true
                        }) {
                            Label("New location", systemImage: "plus.circle.fill")
                        }
                        
                        Divider()
                        
                        Group {
                            Button {
                                userData.mainClocks.sortByNameAscending()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Text("Sort by name ascending")
                            }
                            
                            Button {
                                userData.mainClocks.sortByNameDescending()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Text("Sort by name descending")
                            }
                            
                            Button {
                                userData.mainClocks.sortWestToEast()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort west to east", systemImage: "arrow.right.circle")
                            }
                            
                            Button {
                                userData.mainClocks.sortEastToWest()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort east to west", systemImage: "arrow.left.circle")
                            }
                            
                            Button {
                                userData.mainClocks.sortSouthToNorth()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort south to north", systemImage: "arrow.up.circle")
                            }
                            
                            Button {
                                userData.mainClocks.sortNorthToSouth()
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort north to south", systemImage: "arrow.down.circle")
                            }
                        }
                    } label: {
                        Label("Locations", systemImage: "mappin")
                    }
                }
            }
            .sheet(isPresented: $isShowingNewLocationView) {
                let locationManager = ASALocationManager.shared
                let locationWithClocks = ASALocationWithClocks(
                    location: locationManager.deviceLocation,
                    clocks: [ASAClock.generic],
                    usesDeviceLocation: true,
                    locationManager: locationManager
                )
                ASALocationChooserView(
                    locationWithClocks: locationWithClocks,
                    shouldCreateNewLocationWithClocks: true
                )
                .environmentObject(userData)
                .environmentObject(locationManager)
            }
        } // GeometryReader
        .preferredColorScheme(.dark)
    } // body
    
    private func moveClock(from source: IndexSet, to destination: Int) {
        userData.mainClocks.move(fromOffsets: source, toOffset: destination)
        userData.savePreferences(code: .clocks)
        userData.mainClocksVersion += 1 // 🔄 Force update
    }
} // struct ASAAllLocationsTab

let EARTH_UNIVERSAL_LATITUDE = 0.0
let EARTH_UNIVERSAL_LONGITUDE = 0.0

extension Array where Element == ASALocationWithClocks {
    mutating func sortByNameAscending() {
        self.sort(by: { $0.location.shortFormattedOneLineAddress < $1.location.shortFormattedOneLineAddress })
    }
    
    mutating func sortByNameDescending() {
        self.sort(by: { $0.location.shortFormattedOneLineAddress > $1.location.shortFormattedOneLineAddress })
    }
    
    mutating func sortWestToEast() {
        self.sort(by: {
            let leftType  = $0.location.type
            let rightType = $1.location.type
            
            if leftType == .marsUniversal {
                return false
            }
            
            if rightType == .marsUniversal {
                return true
            }
            
            let leftLongitude: CLLocationDegrees  = (leftType == .earthUniversal) ? EARTH_UNIVERSAL_LONGITUDE :  $0.location.location.coordinate.longitude
            let rightLongitude: CLLocationDegrees = (rightType == .earthUniversal) ? EARTH_UNIVERSAL_LONGITUDE : $1.location.location.coordinate.longitude
            return leftLongitude < rightLongitude })
    }
    
    mutating func sortEastToWest() {
        self.sort(by: {
            let leftType  = $0.location.type
            let rightType = $1.location.type
            
            if leftType == .marsUniversal {
                return false
            }
            
            if rightType == .marsUniversal {
                return true
            }
            
            let leftLongitude: CLLocationDegrees  = (leftType == .earthUniversal) ? EARTH_UNIVERSAL_LONGITUDE :  $0.location.location.coordinate.longitude
            let rightLongitude: CLLocationDegrees = (rightType == .earthUniversal) ? EARTH_UNIVERSAL_LONGITUDE : $1.location.location.coordinate.longitude
            return leftLongitude > rightLongitude })
    }
    
    mutating func sortSouthToNorth() {
        self.sort(by: {
            let leftType  = $0.location.type
            let rightType = $1.location.type
            
            if leftType == .marsUniversal {
                return false
            }
            
            if rightType == .marsUniversal {
                return true
            }
            
            let leftLatitude: CLLocationDegrees  = (leftType == .earthUniversal) ? EARTH_UNIVERSAL_LATITUDE :  $0.location.location.coordinate.latitude
            let rightLatitude: CLLocationDegrees = (rightType == .earthUniversal) ? EARTH_UNIVERSAL_LATITUDE : $1.location.location.coordinate.latitude
            return leftLatitude < rightLatitude })
    }
    
    mutating func sortNorthToSouth() {
        self.sort(by: {
            let leftType  = $0.location.type
            let rightType = $1.location.type
            
            if leftType == .marsUniversal {
                return false
            }
            
            if rightType == .marsUniversal {
                return true
            }
            
            let leftLatitude: CLLocationDegrees  = (leftType == .earthUniversal) ? EARTH_UNIVERSAL_LATITUDE :  $0.location.location.coordinate.latitude
            let rightLatitude: CLLocationDegrees = (rightType == .earthUniversal) ? EARTH_UNIVERSAL_LATITUDE : $1.location.location.coordinate.latitude
            return leftLatitude > rightLatitude })
    }
} // extension Array where Element == ASALocationWithClocks


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClocksTab().environmentObject(ASAModel.shared)
//    }
//}

