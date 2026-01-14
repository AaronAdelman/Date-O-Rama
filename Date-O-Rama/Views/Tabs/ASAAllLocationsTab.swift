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
import MapKit

struct ASAAllLocationsTab: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var selectedTabIndex: Int
    @Binding var isShowingLocationSheet: Bool
    
    @State private var searchText: String = ""
    @State private var searchResults: [CLPlacemark] = []
//    @State private var isSearching: Bool = false
    private let geocoder = CLGeocoder()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color("locationsBackground")
                    .ignoresSafeArea()
                
                let frameHeight: CGFloat? = proxy.safeAreaInsets.top
                
                Spacer()
                    .frame(height: frameHeight)
                
                List {
//                    if isSearching {
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count > 2 {
                        // Search results section
                        Section(header: Text("Search Results")) {
                            if searchResults.isEmpty {
                                HStack {
                                    ProgressView()
                                    Text("Searching…")
                                }
                            } else {
                                ForEach(searchResults, id: \.self) { placemark in
                                    Button(action: {
                                        handleSelection(of: placemark)
                                    }) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(placemark.name ?? placemark.locality ?? "Unknown")
                                                .font(.headline)
                                            Text(formatSubtitle(for: placemark))
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        } // Section
                    } else {
                        // Existing locations list
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
                    }
                } // List
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
                .listStyle(.plain)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for a place")
                .task(id: searchText) {
                    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    // Debounce: wait 350 ms after the latest change
                    try? await Task.sleep(nanoseconds: 350_000_000)
                    await MainActor.run {
                        performGeocode(for: query)
                    }
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
            } // ZStack
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        let existsDeviceLocation = userData.mainClocks.containsDeviceLocation
                        
                        if !existsDeviceLocation {
                            Button(action: {
                                let locationManager = ASALocationManager.shared
                                let deviceLocation = locationManager.deviceLocation
                                let newLocationWithClocks = ASALocationWithClocks.generic(location: deviceLocation, usesDeviceLocation: true, locationManager: locationManager)
                                userData.addLocationWithClocks(newLocationWithClocks)
                            }) {
                                Label("Add device location", systemImage: "plus.circle.fill")
                            }
                        }
                        
                        let existsEarthUniversalLocation = userData.mainClocks.containsLocationOf(type: .earthUniversal)
                        
                        if !existsEarthUniversalLocation {
                            Button(action: {
                                let locationManager = ASALocationManager.shared
                                let newLocationWithClocks = ASALocationWithClocks.generic(location: .earthUniversal, usesDeviceLocation: false, locationManager: locationManager)
                                userData.addLocationWithClocks(newLocationWithClocks)
                            }) {
                                Label("Add universal Earth location", systemImage: "plus.circle.fill")
                            }
                        }
                        
                        let existsMarsUniversalLocation = userData.mainClocks.containsLocationOf(type: .marsUniversal)

                        if !existsMarsUniversalLocation {
                            Button(action: {
                                let locationManager = ASALocationManager.shared
                                let newLocationWithClocks = ASALocationWithClocks.generic(location: .marsUniversal, usesDeviceLocation: false, locationManager: locationManager)
                                userData.addLocationWithClocks(newLocationWithClocks)
                            }) {
                                Label("Add universal Mars location", systemImage: "plus.circle.fill")
                            }
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
                        Label("Locations", systemImage: "ellipsis")
                    }
                }
            }
        } // GeometryReader
        .preferredColorScheme(.dark)
    } // body
    
    private func performGeocode(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 2 else {
            searchResults = []
            geocoder.cancelGeocode()
            return
        }

        // Cancel any in-flight CoreLocation geocoding
        geocoder.cancelGeocode()

        // Build a local search request for multiple results
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed

        // Prefer to bias results near the first saved location, if available
//        if let firstCoord = userData.mainClocks.first?.location.location.coordinate {
//            request.region = MKCoordinateRegion(
//                center: firstCoord,
//                span: MKCoordinateSpan(latitudeDelta: 60.0, longitudeDelta: 60.0)
//            )
//        }

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                guard error == nil, let response = response else {
                    self.searchResults = []
                    return
                }
                self.searchResults = response.mapItems.map { $0.placemark }
            }
        }
    }

    private func handleSelection(of placemark: CLPlacemark) {
        // Build a location candidate from the placemark
        guard let location = placemark.location else { return }
 
        let locationManager = ASALocationManager.shared
        let asaLocation = ASALocation.create(placemark: placemark, location: location)
         let newLocationWithClocks = ASALocationWithClocks.generic(location: asaLocation, usesDeviceLocation: false, locationManager: locationManager)
         userData.addLocationWithClocks(newLocationWithClocks)

        self.searchText = ""
        self.searchResults = []
//        self.isSearching = false
    }

    private func formatSubtitle(for placemark: CLPlacemark) -> String {
        let parts: [String] = [
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ].compactMap { $0 }
        return parts.joined(separator: ", ")
    }
    
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

