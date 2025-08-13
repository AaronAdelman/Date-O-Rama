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
    @State private var animatingTabSwitch = false
    
    var body: some View {
        let ANIMATION_DURATION = 0.5
        
        GeometryReader { proxy in
            NavigationStack {
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
                                now: $now,
                                animatingSelection: animatingTabSwitch && selectedTabIndex == index
                            )
                            .environmentObject(userData)
                            .onTapGesture {
                                // Animate the cell first
                                withAnimation(.easeInOut(duration: ANIMATION_DURATION)) {
                                    animatingTabSwitch = true
                                    selectedTabIndex = index
                                }
                                
                                // Then switch tabs after a brief delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + ANIMATION_DURATION - 0.05) {
                                    showLocationsSheet = false
                                    animatingTabSwitch = false
                                }
                            }
                        }
                        .onMove(perform: moveClock)
                    }
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .listStyle(.plain)
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 0)
                    }
                } // ZStack
                .navigationTitle("Locations")
                .navigationBarTitleDisplayMode(.inline)
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
        } // GeometryReader
    } // body
    
    private func moveClock(from source: IndexSet, to destination: Int) {
        userData.mainClocks.move(fromOffsets: source, toOffset: destination)
        userData.savePreferences(code: .clocks)
        userData.mainClocksVersion += 1 // 🔄 Force update
    }
}


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClocksTab().environmentObject(ASAModel.shared)
//    }
//}
