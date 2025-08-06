//
//  ASALocationsTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASALocationsTab: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var selectedTabIndex: Int
    @Binding var showLocationsSheet: Bool
    
    @State private var isShowingNewLocationView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("locationsBackground")
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0.0) {
                    Spacer()
                        .frame(height: 44.0)
                    
                    List {
                        ForEach(Array(userData.mainClocks.enumerated()), id: \.element.id) { index, locationWithClocks in
                            ASALocationWithClocksCell(locationWithClocks: locationWithClocks, now: $now)
                                .environmentObject(userData)
                                .onTapGesture {
                                    selectedTabIndex = index
                                    showLocationsSheet = false
                                }
                        }
                        .onMove(perform: moveClock)
                    } // List
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .navigationTitle("Locations")
                    .navigationBarTitleDisplayMode(.inline)
                } // Vstack
                
            } // ZStack
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            isShowingNewLocationView = true
                        }) {
                            Label("New location", systemImage: "plus.circle.fill")
                        }
                        
                        Divider()
                        
                        Group {
                            Button {
                                userData.mainClocks.sort(by: { $0.location.shortFormattedOneLineAddress < $1.location.shortFormattedOneLineAddress })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort by name ↑", systemImage: "arrow.down")
                            }
                            
                            Button {
                                userData.mainClocks.sort(by: { $0.location.shortFormattedOneLineAddress > $1.location.shortFormattedOneLineAddress })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort by name ↓", systemImage: "arrow.up")
                            }
                            
                            Button {
                                userData.mainClocks.sort(by: {
                                    if $0.location.type == .MarsUniversal {
                                        return false
                                    }
                                    
                                    if $1.location.type == .MarsUniversal {
                                        return true
                                    }
                                    
                                    return $0.location.location.coordinate.longitude < $1.location.location.coordinate.longitude })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort west to east", systemImage: "arrow.right")
                            }
                            
                            Button {
                                userData.mainClocks.sort(by: { if $0.location.type == .MarsUniversal {
                                    return false
                                }
                                    
                                    if $1.location.type == .MarsUniversal {
                                        return true
                                    }
                                    
                                    return $0.location.location.coordinate.longitude > $1.location.location.coordinate.longitude })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort east to west", systemImage: "arrow.left")
                            }
                            
                            Button {
                                userData.mainClocks.sort(by: { if $0.location.type == .MarsUniversal {
                                    return false
                                }
                                    
                                    if $1.location.type == .MarsUniversal {
                                        return true
                                    }
                                    
                                    return $0.location.location.coordinate.latitude < $1.location.location.coordinate.latitude })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort south to north", systemImage: "arrow.up")
                            }
                            
                            Button {
                                userData.mainClocks.sort(by: { if $0.location.type == .MarsUniversal {
                                    return false
                                }
                                    
                                    if $1.location.type == .MarsUniversal {
                                        return true
                                    }
                                    
                                    return $0.location.location.coordinate.latitude > $1.location.location.coordinate.latitude })
                                userData.savePreferences(code: .clocks)
                            } label: {
                                Label("Sort north to south", systemImage: "arrow.down")
                            }
                        }
                    } label: {
                        Label("Locations", systemImage: "mappin")
                    }
                }
            }
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
    }
    
    private func moveClock(from source: IndexSet, to destination: Int) {
        userData.mainClocks.move(fromOffsets: source, toOffset: destination)
        userData.savePreferences(code: .clocks)
        userData.mainClocksVersion += 1 // 🔄 Force update
    }
}


struct ASALocationWithClocksCell: View {
    @EnvironmentObject var userData: ASAModel
    @ObservedObject var locationWithClocks: ASALocationWithClocks
    @Binding var now: Date
    @State private var showingGetInfoView = false
    @State private var showingActionSheet = false
    
    var body: some View {
        let processed = locationWithClocks.clocks.map {ASAMiniProcessedClock(clock: $0, now: now, location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation)}
        let times: Array<String> = processed.compactMap { $0.timeString }.uniqueElements.map { $0! }
        let timeString = times.joined(separator: " • ")
        
        let cellBackground = processed.dayPart.locationColor
        
        VStack {
            HStack {
                ASALocationWithClocksSectionHeader(locationWithClocks: locationWithClocks, now: now, shouldCapitalize: false)
                
                Spacer()
                ASALocationMenu(locationWithClocks: locationWithClocks, now: $now, includeClockOptions: false) {
                    self.showingActionSheet = true
                } infoAction: {
                    self.showingGetInfoView = true
                } newClockAction: {debugPrint("Foo!")}
                    .environmentObject(userData)
                    .sheet(isPresented: self.$showingGetInfoView) {
                        VStack {
                            HStack {
                                Button(action: {
                                    showingGetInfoView = false
                                }) {
                                    ASACloseBoxImage()
                                }
                                Spacer()
                            } // HStack
                            ASALocationDetailView(locationWithClocks: locationWithClocks, now: now)
                        }
                        .font(.body)
                    }
                    .actionSheet(isPresented: self.$showingActionSheet) {
                        ActionSheet(title: Text("Are you sure you want to delete this location?"), buttons: [
                            .destructive(Text("Delete this location")) {
                                userData.removeLocationWithClocks(locationWithClocks)
                            },
                            .default(Text("Cancel")) {  }
                        ])
                    }
            } // HStack
            
            Text(timeString)
                .font(.largeTitle)
        } // VStack
        .foregroundStyle(Color.white)
        .padding()
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClocksTab().environmentObject(ASAModel.shared)
//    }
//}
