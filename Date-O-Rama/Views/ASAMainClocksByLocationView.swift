//
//  ASAMainClocksByLocationView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksByLocationView:  View {
    @EnvironmentObject var userData:  ASAUserData
    @Binding var mainClocks:  Array<ASALocationWithClocks>
    @Binding var now:  Date
    
    var body:  some View {
        ForEach($mainClocks, id: \.self.id) {
            section
            in
            ASAMainClocksByLocationSectionView(now: $now, locationWithClocks: section)
        }
    }
} // struct ASAMainClocksByLocationView:  View


enum ASAMainClocksByLocationSectionDetail {
    case none
    case newClock
    case editLocation
} // enum ASAMainClocksByLocationSectionDetail


struct ASAMainClocksByLocationSectionView: View {
    @Binding var now:  Date
    @Binding var locationWithClocks: ASALocationWithClocks
    
    @State private var showingDetailView = false
    @State private var detail: ASAMainClocksByLocationSectionDetail = .none
    
    @State private var showingActionSheet = false
    
    var body: some View {
        let location = locationWithClocks.location
        
        let sectionHeaderEmoji = location.flag
#if os(watchOS)
        let sectionHeaderTitle = location.shortFormattedOneLineAddress
        let sectionHeaderFont: Font = Font.title3
#else
        let sectionHeaderTitle = location.formattedOneLineAddress
        let sectionHeaderFont: Font = Font.title2
#endif
        
        Section(header: HStack {
            if locationWithClocks.usesDeviceLocation {
                ASALocationSymbol()
            }
            Text(sectionHeaderEmoji)
            Text(sectionHeaderTitle)
                .lineLimit(2)
#if os(watchOS)
#else
            Spacer()
            Menu {
                Button(
                    action: {
                        self.detail = .editLocation
                        self.showingDetailView = true
                        
                    }
                ) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit location")
                    } // HStack
                }
                
                Button(
                    action: {
                        self.showingActionSheet = true
                    }
                ) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Delete location")
                    } // HStack
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
                        Text("Add clock")
                    } // HStack
                }
                
                Divider()
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName < $1.calendar.calendarCode.localizedName})
                    ASAUserData.shared.savePreferences(code: .clocks)
                }, label: {
                    Text("Sort by calendar name ascending")
                })
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName > $1.calendar.calendarCode.localizedName})
                    ASAUserData.shared.savePreferences(code: .clocks)
                }, label: {
                    Text("Sort by calendar name descending")
                })
            } label: {
                Image(systemName: "arrow.down.square.fill")
            }
            .sheet(isPresented: self.$showingDetailView, onDismiss: {
                detail = .none
            }) {
                switch detail {
                case .none:
                    Text("Programmer error!  Replace programmer and try again!")
                case .newClock:
                    ASANewClockDetailView(location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation, now:  now, tempLocation: location)
                    
                case .editLocation:
                    ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: false)
                } // switch detail
            }
            .actionSheet(isPresented: self.$showingActionSheet) {
                ActionSheet(title: Text("Are you sure you want to delete this location?"), buttons: [
                    .destructive(Text("Delete this location")) {
                        ASAUserData.shared.removeLocationWithClocks(locationWithClocks)
                    },
                    .default(Text("Cancel")) {  }
                ])
            }
#endif
        }
            .font(sectionHeaderFont)
        ) {
            let location = locationWithClocks.location
            let usesDeviceLocation = locationWithClocks.usesDeviceLocation
            ForEach( 0..<locationWithClocks.clocks.count) {
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
                    ASAClockCell(processedClock: processedClock, now: $now, shouldShowTime: true, shouldShowMiniCalendar: shouldShowMiniCalendar, isForComplications: false, indexIsOdd: indexIsOdd)
                }
            }
            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
    }
    
    private func onDelete(offsets: IndexSet) {
        let relevantUUID = self.locationWithClocks.location.id
        let relevantLocationWithClocksIndex = ASAUserData.shared.mainClocks.firstIndex(where: {$0.location.id == relevantUUID})
        if relevantLocationWithClocksIndex != nil {
            ASAUserData.shared.mainClocks[relevantLocationWithClocksIndex!].clocks.remove(atOffsets: offsets)
            ASAUserData.shared.savePreferences(code: .clocks)
        }
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        let relevantUUID = self.locationWithClocks.location.id
        let relevantLocationWithClocksIndex = ASAUserData.shared.mainClocks.firstIndex(where: {$0.location.id == relevantUUID})
        if relevantLocationWithClocksIndex != nil {
            ASAUserData.shared.mainClocks[relevantLocationWithClocksIndex!].clocks.move(fromOffsets: source, toOffset: destination)
            ASAUserData.shared.savePreferences(code: .clocks)
        }
    }
}


//struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMainClocksByLocationView(mainClocks: .constant(ASALocationWithClocks(location: ASALocation.NullIsland, clocks: [ASAClock.generic])), now: .constant(Date()))
//    }
//}
