//
//  ASAMainClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @Binding var mainClocks:  Array<ASALocationWithClocks>
    @Binding var now:  Date
    
    var body: some View {
        ForEach($mainClocks, id: \.self.id) {
            section
            in
            ASAMainClocksSectionView(now: $now, locationWithClocks: section)
        }
    }
} // struct ASAMainClocksView


enum ASAMainClocksSectionDetail {
    case none
    case newClock
    case locationInfo
} // enum ASAMainClocksSectionDetail


struct ASAMainClocksSectionView: View {
    @Binding var now:  Date
    @Binding var locationWithClocks: ASALocationWithClocks
    
    @State private var showingDetailView = false
    @State private var detail: ASAMainClocksSectionDetail = .none
    
    @State private var showingActionSheet = false
    
#if os(watchOS)
#else
    @Environment(\.editMode) var editMode
#endif
    
    var body: some View {
        let location = locationWithClocks.location
        
        Section(header: HStack {
            ASAMainClocksViewSectionHeader(locationWithClocks: locationWithClocks, now: now)
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
                
#if os(watchOS)
#else
                // Based on https://developer.apple.com/forums/thread/662860
                Button(action: {
                    editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                }) {
                    let editingNow: Bool = editMode?.wrappedValue == .active
                    Image(systemName: editingNow ? "xmark" : "arrow.triangle.swap")
                    Text(editingNow ? "Done Reordering" : "Reorder")
                }
#endif
                
                if ASAUserData.shared.mainClocks.count > 1 {
                    Divider()
                    
                    Button(action: {
                        let index = ASAUserData.shared.mainClocks.firstIndex(of: locationWithClocks)
                        guard index != nil else { return }
                        let item = ASAUserData.shared.mainClocks.remove(at: index!)
                        ASAUserData.shared.mainClocks.insert(item, at: 0)
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }, label: {
                        Label {
                            Text("Move to top")
                        } icon: {
                            Image(systemName: "arrow.up.to.line")
                        }
                    })
                    
                    Button(action: {
                        let index = ASAUserData.shared.mainClocks.firstIndex(of: locationWithClocks)
                        guard index != nil else { return }
                        guard index! != 0 else { return }
                        let item = ASAUserData.shared.mainClocks.remove(at: index!)
                        ASAUserData.shared.mainClocks.insert(item, at: index! - 1)
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }, label: {
                        Label {
                            Text("Move up")
                        } icon: {
                            Image(systemName: "arrow.up")
                        }
                    })
                    
                    Button(action: {
                        let index = ASAUserData.shared.mainClocks.firstIndex(of: locationWithClocks)
                        guard index != nil else { return }
                        guard index! != ASAUserData.shared.mainClocks.count - 1 else { return }
                        let item = ASAUserData.shared.mainClocks.remove(at: index!)
                        ASAUserData.shared.mainClocks.insert(item, at: index! + 1)
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }, label: {
                        Label {
                            Text("Move down")
                        } icon: {
                            Image(systemName: "arrow.down")
                        }
                    })
                    
                    Button(action: {
                        let index = ASAUserData.shared.mainClocks.firstIndex(of: locationWithClocks)
                        guard index != nil else { return }
                        let item = ASAUserData.shared.mainClocks.remove(at: index!)
                        ASAUserData.shared.mainClocks.append(item)
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }, label: {
                        Label {
                            Text("Move to bottom")
                        } icon: {
                            Image(systemName: "arrow.down.to.line")
                        }
                    })
                    
                }
                
                if locationWithClocks.clocks.count > 1 {
                    Divider()
                    
                    Button(action: {
                        locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName < $1.calendar.calendarCode.localizedName})
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }, label: {
                        Image(systemName: "arrow.down")
                        Text("Sort by calendar name ascending")
                    })
                    
                    Button(action: {
                        locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName > $1.calendar.calendarCode.localizedName})
                        ASAUserData.shared.savePreferences(code: .clocks)
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
                        ASALocationDetailView(locationWithClocks: $locationWithClocks, now: $now)
                    }
                    .font(.body)
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
                    ASAClockCell(processedClock: processedClock, now: $now, shouldShowTime: true, shouldShowMiniCalendar: shouldShowMiniCalendar, isForComplications: false, indexIsOdd: indexIsOdd, clock: clock, location: locationWithClocks.location)
                }
            }
            //            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
        }
        .textCase(nil)
    }
    
    @MainActor private func onMove(source: IndexSet, destination: Int) {
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
//        ASAMainClocksView(mainClocks: .constant(ASALocationWithClocks(location: ASALocation.NullIsland, clocks: [ASAClock.generic])), now: .constant(Date()))
//    }
//}
