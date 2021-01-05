//
//  ASAClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation


struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    @State private var showingNewClockDetailView = false

    @AppStorage("mainRowsGroupingOption") var primaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName
    @AppStorage("secondaryMainRowsGroupingOption") var secondaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byFormattedDate

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 0.0 as CGFloat

    @State var isNavBarHidden:  Bool = false

    var forAppleWatch:  Bool

    @State private var showingPreferences:  Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    DisclosureGroup("Show preferences", isExpanded: $showingPreferences) {
                        NavigationLink(destination:  ASAArrangementChooserView(selectedGroupingOption:  self.$primaryMainRowsGroupingOption, groupingOptions: ASAClocksViewGroupingOption.primaryOptions, otherGroupingOption: self.$secondaryMainRowsGroupingOption, otherGroupingOptionIsSecondary: true)) {
                            HStack {
                                Text("Arrangement")
                                Spacer()
                                Text(self.primaryMainRowsGroupingOption.text())
                            }
                            .foregroundColor(.accentColor)
                        } // NavigationLink

                        NavigationLink(destination:  ASAArrangementChooserView(selectedGroupingOption:  self.$secondaryMainRowsGroupingOption, groupingOptions: self.primaryMainRowsGroupingOption.compatibleOptions, otherGroupingOption: self.$primaryMainRowsGroupingOption, otherGroupingOptionIsSecondary: false)) {
                            HStack {
                                Text("Secondary arrangement")
                                Spacer()
                                Text(self.secondaryMainRowsGroupingOption.text())
                            }
                            .foregroundColor(.accentColor)
                        } // NavigationLink

                        Button(
                            action: {
                                self.showingNewClockDetailView = true
                            }
                        ) {
                            Text("Add clock")
                        }
                        .foregroundColor(.accentColor)
                    } // DisclosureGroup

                    switch self.primaryMainRowsGroupingOption {
                    case .byFormattedDate:
                        ASAMainRowsByFormattedDateView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, forComplications:  false)

                    case .byCalendar:
                        ASAMainRowsByCalendarView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, forComplications:  false)

                    case .byPlaceName, .byCountry:
                        ASAMainRowsByPlaceView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, forComplications:  false)

//                    case .westToEast, .eastToWest, .southToNorth, .northToSouth:
//                        ASAPlainMainRowsView(groupingOption: self.primaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, forComplications:  false)

                    case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
                        ASAMainRowsByTimeZoneView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, forComplications:  false)

                    default:
                        EmptyView()
                    } // switch self.groupingOptions[self.groupingOptionIndex]
                }
                .sheet(isPresented: self.$showingNewClockDetailView) {
                    ASANewClockDetailView(forAppleWatch: forAppleWatch)
                }
//                .navigationBarTitle(Text("CLOCKS_TAB"))
                .navigationBarHidden(self.isNavBarHidden)
                .onAppear {
                    self.isNavBarHidden = true
                }
                .onDisappear {
//                    self.isNavBarHidden = false
                }
            } // VStack
        }.navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            self.now = Date()
        }
    } // var body
} // struct ASAClocksView


// MARK:  -

struct ASAConditionalEditButton:  View {
    var shouldShow:  Bool
    
    var body: some View {
        Group {
            
            if #available(macOS 11, iOS 14.0, tvOS 14.0, *) {
                if shouldShow {
                    EditButton()
                } else {
                    EmptyView()
                }
            } else {
                EditButton()
            }
        } // Group
    } //var body
} // struct ASAConditionalEditButton


struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView(forAppleWatch: false).environmentObject(ASAUserData.shared)
    }
}
