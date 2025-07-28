//
//  ASALocationWithClocksTitleView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationWithClocksTitleView: View {
    @ObservedObject private var locationWithClocks: ASALocationWithClocks
    @Binding var now: Date
    
    var body: some View {
        HStack {
            ASALocationWithClocksSectionHeader(locationWithClocks: locationWithClocks, now: now)
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
                
//#if os(watchOS)
//#else
//                // Based on https://developer.apple.com/forums/thread/662860
//                Button(action: {
//                    editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
//                }) {
//                    let editingNow: Bool = editMode?.wrappedValue == .active
//                    Image(systemName: editingNow ? "xmark" : "arrow.triangle.swap")
//                    Text(editingNow ? "Done Reordering" : "Reorder")
//                }
//#endif
                
//                if userData.mainClocks.count > 1 {
//                    Divider()
//
//                    Button(action: {
//                        let index = userData.mainClocks.firstIndex(of: locationWithClocks)
//                        guard index != nil else { return }
//                        let item = userData.mainClocks.remove(at: index!)
//                        userData.mainClocks.insert(item, at: 0)
//                        userData.savePreferences(code: .clocks)
//                    }, label: {
//                        Label {
//                            Text("Move to top")
//                        } icon: {
//                            Image(systemName: "arrow.up.to.line")
//                        }
//                    })
//
//                    Button(action: {
//                        let index = userData.mainClocks.firstIndex(of: locationWithClocks)
//                        guard index != nil else { return }
//                        guard index! != 0 else { return }
//                        let item = userData.mainClocks.remove(at: index!)
//                        userData.mainClocks.insert(item, at: index! - 1)
//                        userData.savePreferences(code: .clocks)
//                    }, label: {
//                        Label {
//                            Text("Move up")
//                        } icon: {
//                            Image(systemName: "arrow.up")
//                        }
//                    })
//
//                    Button(action: {
//                        let index = userData.mainClocks.firstIndex(of: locationWithClocks)
//                        guard index != nil else { return }
//                        guard index! != userData.mainClocks.count - 1 else { return }
//                        let item = userData.mainClocks.remove(at: index!)
//                        userData.mainClocks.insert(item, at: index! + 1)
//                        userData.savePreferences(code: .clocks)
//                    }, label: {
//                        Label {
//                            Text("Move down")
//                        } icon: {
//                            Image(systemName: "arrow.down")
//                        }
//                    })
//
//                    Button(action: {
//                        let index = userData.mainClocks.firstIndex(of: locationWithClocks)
//                        guard index != nil else { return }
//                        let item = userData.mainClocks.remove(at: index!)
//                        userData.mainClocks.append(item)
//                        userData.savePreferences(code: .clocks)
//                    }, label: {
//                        Label {
//                            Text("Move to bottom")
//                        } icon: {
//                            Image(systemName: "arrow.down.to.line")
//                        }
//                    })
//
//                }
                
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
        }    }
}

#Preview {
    ASALocationWithClocksTitleView()
}
