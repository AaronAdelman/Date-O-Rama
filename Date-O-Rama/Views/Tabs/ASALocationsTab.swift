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
    @State private var locationToDelete: ASALocationWithClocks? = nil
    
    @State private var showingGetInfoView = false
    @State private var showingActionSheet = false
    
    @Binding var showLocationsSheet: Bool
    
    @State private var selectedCalendar = Calendar(identifier: .gregorian)
    
    let availableCalendars: [(name: String, calendar: Calendar.Identifier)] = [
        ("gre", .gregorian),
        ("tha", .buddhist),
        ("chi", .chinese),
        ("cop", .coptic),
        ("EthiopicAmeteAlem", .ethiopicAmeteAlem),
        ("EthiopicAmeteMihret", .ethiopicAmeteMihret),
        ("Hebrew", .hebrew),
        ("ind", .indian),
        ("Islamic", .islamic),
        ("IslamicCivil", .islamicCivil),
        ("IslamicTabular", .islamicTabular),
        ("IslamicUmmAlQura", .islamicUmmAlQura),
        ("kok", .japanese),
        ("his", .persian),
        ("min", .republicOfChina)
    ]
        
    @State var isShowingNewLocationView = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                
                Menu {
                    Button(action: {
                        self.isShowingNewLocationView = true
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("New location")
                    })
                    
                    Divider()
                    
                    Group {
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress < $1.location.shortFormattedOneLineAddress})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.down")
                            Text("Sort locations by name ascending")
                        })
                        
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.shortFormattedOneLineAddress > $1.location.shortFormattedOneLineAddress})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.up")
                            Text("Sort locations by name descending")
                        })
                        
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude < $1.location.location.coordinate.longitude})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.right")
                            Text("Sort locations west to east")
                        })
                        
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.location.coordinate.longitude > $1.location.location.coordinate.longitude})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.left")
                            Text("Sort locations east to west")
                        })
                        
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude < $1.location.location.coordinate.latitude})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.up")
                            Text("Sort locations south to north")
                        })
                        
                        Button(action: {
                            userData.mainClocks.sort(by: {$0.location.location.coordinate.latitude > $1.location.location.coordinate.latitude})
                            userData.savePreferences(code: .clocks)
                        }, label: {
                            Image(systemName: "arrow.down")
                            Text("Sort locations north to south")
                        })
                    }
                } label: {
                    ASAMenuTitle(imageSystemName: "mappin", title: "Locations")
                }
                
                Spacer()
            } // HStack
            .border(Color.gray)
            .sheet(isPresented: $isShowingNewLocationView, content: {
                let locationManager: ASALocationManager = ASALocationManager.shared
                let locationWithClocks = ASALocationWithClocks(location: locationManager.deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true, locationManager: locationManager)
                ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: true).environmentObject(userData).environmentObject(userData).environmentObject(locationManager)
            })
            
            List {
                ForEach(Array(userData.mainClocks.enumerated()), id: \.element.id) { index, locationWithClocks in
                    
                    ASALocationWithClocksCell(locationWithClocks: locationWithClocks, now: $now)
                        .environmentObject(userData)
                        .onTapGesture {
                            selectedTabIndex = index
                            showLocationsSheet = false
                        }
                } // ForEach(Array(userData.mainClocks.enumerated()), id: \.element.id)
                .onMove(perform: moveClock)
            } // List
        } // VStack
    } // var body
    
    private func moveClock(from source: IndexSet, to destination: Int) {
        userData.mainClocks.move(fromOffsets: source, toOffset: destination)
        userData.savePreferences(code: .clocks)
        userData.mainClocksVersion += 1 // 🔄 Force update
    }
} // struct ASALocationsTab


struct ASALocationWithClocksCell: View {
    @EnvironmentObject var userData: ASAModel
    @ObservedObject var locationWithClocks: ASALocationWithClocks
    @Binding var now: Date
    @State private var showingGetInfoView = false
    @State private var showingActionSheet = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(Color(white: 0.85))
            
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
            .padding()
        } // ZStack
    }
}


// MARK:  -


//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClocksTab().environmentObject(ASAModel.shared)
//    }
//}
