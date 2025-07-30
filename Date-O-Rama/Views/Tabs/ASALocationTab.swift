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
    @EnvironmentObject var userData:  ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @Binding var locationWithClocks: ASALocationWithClocks

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
                
    @State var isNavigationBarHidden: Bool = true
    
    @State var isShowingNewLocationView = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                HStack {
                    Spacer()
                    
                    if horizontalSizeClass != .compact {
                        Button (action: {
                            self.usingRealTime = false
                            now = now.oneDayBefore
                        }, label: {
                            Image(systemName: "arrowtriangle.backward.fill")
                                .imageScale(.large)
                        })
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button (action: {
                            self.usingRealTime = false
                            now = now.oneDayAfter
                        }, label: {
                            Image(systemName: "arrowtriangle.forward.fill")
                                .imageScale(.large)
                        })
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }

                    Button(action: {
                        self.usingRealTime = true
                    }, label: {
                        ASARadioButtonLabel(on: self.usingRealTime, onColor: .green, text: "Now")
                    })
                    
                    Spacer()
                        .frame(minWidth: 0.0)
                    
                    HStack {
                        Button(action: {
                            self.usingRealTime = false
                        }, label: {
                            let VERTICAL_PADDING: CGFloat = 7.0
                            ASARadioButtonLabel(on: !self.usingRealTime, onColor: .yellow, text: self.usingRealTime ? "Date:" : "")
                                .padding(EdgeInsets(top: VERTICAL_PADDING, leading: 0.0, bottom: VERTICAL_PADDING, trailing: 0.0))
                        })
                        if !self.usingRealTime {
                            DatePicker(selection:  self.$now, in:  Date.distantPast...Date.distantFuture, displayedComponents: [.date, .hourAndMinute]) {
                                Text("")
                            }
                            .environment(\.calendar, selectedCalendar)
                            .datePickerStyle(.compact)
                            
                            Menu {
                                ForEach(availableCalendars, id: \.calendar) { calendarInfo in
                                    HStack {
                                        Button {
                                            selectedCalendar = Calendar(identifier: calendarInfo.calendar)
                                        } label: {
                                            Text(NSLocalizedString(calendarInfo.name, comment: ""))
                                            if selectedCalendar.identifier == calendarInfo.calendar {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    } // HStack
                                } // ForEach
                            } label: {
                                ASAMenuTitle(imageSystemName: "calendar")
                            }
                        }
                    } // HStack
                    
                    Spacer()
                } // HStack
                .border(Color.gray)
                .zIndex(1.0) // This line from https://stackoverflow.com/questions/63934037/swiftui-navigationlink-cell-in-a-form-stays-highlighted-after-detail-pop to get rid of unwanted highlighting.
                
                List {
                    ASAMainClocksSectionView(now: $now, locationWithClocks: $locationWithClocks).environmentObject(userData)
                }
                .listStyle(GroupedListStyle())
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing: EditButton())
                .onAppear {
                    self.isNavigationBarHidden = true
                }
            } // VStack
        }.navigationViewStyle(StackNavigationViewStyle())
    } // var body
} // struct ASALocationsTab


// MARK:  -




//struct ASAClocksView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationsTab().environmentObject(ASAModel.shared)
//    }
//}
