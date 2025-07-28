//
//  ASAMainClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksSectionView: View {
    enum Detail {
        case none
        case newClock
        case locationInfo
    } // enum ASAMainClocksSectionDetail
    
    @EnvironmentObject var userData:  ASAModel

    @Binding var now:  Date
    @Binding var locationWithClocks: ASALocationWithClocks
    
    @State private var showingDetailView = false
    @State private var detail: Detail = .none
    
    @State private var showingActionSheet = false
    
#if os(watchOS)
#else
    @Environment(\.editMode) var editMode
#endif
    
    var body: some View {
        let location = locationWithClocks.location
        
        Section(header: HStack {
            ASALocationWithClocksSectionHeader(locationWithClocks: locationWithClocks, now: now, shouldCapitalize: true)
#if os(watchOS)
#else
            Spacer()
            Menu {
                Button(
                    action: {
                        self.detail = .locationInfo
                        self.showingDetailView = true
                    }
                ) {
                    ASAGetInfoLabel()
                }
                
                Button(
                    action: {
                        self.showingActionSheet = true
                    }
                ) {
                    Label {
                        Text("Delete location")
                    } icon: {
                        Image(systemName: "minus.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                }
                
                Divider()
                
                Button(
                    action: {
                        self.detail = .newClock
                        self.showingDetailView = true
                        
                    }
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.multicolor)
                        Text("Add clock")
                    } // HStack
                }
                
                if locationWithClocks.clocks.count > 1 {
                    Divider()
                    
                    Button(action: {
                        locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName < $1.calendar.calendarCode.localizedName})
                        userData.savePreferences(code: .clocks)
                    }, label: {
                        Image(systemName: "arrow.down")
                        Text("Sort by calendar name ascending")
                    })
                    
                    Button(action: {
                        locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName > $1.calendar.calendarCode.localizedName})
                        userData.savePreferences(code: .clocks)
                    }, label: {
                        Image(systemName: "arrow.up")
                        Text("Sort by calendar name descending")
                    })
                }
            } label: {
                ASALocationMenuSymbol()
            }
            .sheet(isPresented: self.$showingDetailView, onDismiss: {
                detail = .none
            }) {
                switch detail {
                case .none:
                    Text("Programmer error!  Replace programmer and try again!")
                case .newClock:
                    ASANewClockDetailView(location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation, now:  now, tempLocation: location)
                        .environmentObject(userData)
                    
                case .locationInfo:
                    VStack {
                        HStack {
                            Button(action: {
                                showingDetailView = false
                                detail = .none
                            }) {
                                ASACloseBoxImage()
                            }
                            Spacer()
                        } // HStack
                        ASALocationDetailView(locationWithClocks: $locationWithClocks, now: now)
                    }
                    .font(.body)
                } // switch detail
            }
            .actionSheet(isPresented: self.$showingActionSheet) {
                ActionSheet(title: Text("Are you sure you want to delete this location?"), buttons: [
                    .destructive(Text("Delete this location")) {
                        userData.removeLocationWithClocks(locationWithClocks)
                    },
                    .default(Text("Cancel")) {  }
                ])
            }
#endif
        }) {
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            ForEach(locationWithClocks.clocks.indices, id: \.self) {
                index
                in
                
                if index < locationWithClocks.clocks.count {
                    let clock = locationWithClocks.clocks[index]
                    let processedClock = ASAProcessedClock(clock: clock, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
                    
#if os(watchOS)
                    let shouldShowMiniCalendar = false
                    let indexIsOdd             = false
#else
                    let shouldShowMiniCalendar = true
                    let indexIsOdd             = index % 2 == 1
#endif
                    ASAClockCell(processedClock: processedClock, now: $now, shouldShowTime: true, shouldShowMiniCalendar: shouldShowMiniCalendar, isForComplications: false, indexIsOdd: indexIsOdd, clock: clock, location: locationWithClocks.location).environmentObject(userData)
                }
            }
            //            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
        .textCase(nil)
    }
    
    @MainActor private func onMove(source: IndexSet, destination: Int) {
        let relevantUUID = self.locationWithClocks.location.id
        let relevantLocationWithClocksIndex = userData.mainClocks.firstIndex(where: {$0.location.id == relevantUUID})
        if relevantLocationWithClocksIndex != nil {
            userData.mainClocks[relevantLocationWithClocksIndex!].clocks.move(fromOffsets: source, toOffset: destination)
            userData.savePreferences(code: .clocks)
        }
    }
}


//struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMainClocksView(mainClocks: .constant(ASALocationWithClocks(location: ASALocation.NullIsland, clocks: [ASAClock.generic])), now: .constant(Date()))
//    }
//}
