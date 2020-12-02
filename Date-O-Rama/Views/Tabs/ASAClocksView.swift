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

//    let groupingOptions:  Array<ASAClocksViewGroupingOption> = [
////        .plain,
//        .byFormattedDate,
//        .byCalendar,
//        .byPlaceName,
//        .eastToWest,
//        .westToEast,
//        .northToSouth,
//        .southToNorth,
//        .byTimeZoneWestToEast,
//        .byTimeZoneEastToWest
//    ]

    @AppStorage("mainRowsGroupingOption") var mainRowsGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 0.0 as CGFloat

    @State var isNavBarHidden:  Bool = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination:  ASAArrangementChooserView(groupingOption:  self.$mainRowsGroupingOption, tempGroupingOption: self.mainRowsGroupingOption)) {
                    HStack {
                        Text("Arrangement")
                        Spacer()
                        Text(self.mainRowsGroupingOption.text())
                    }
                    .foregroundColor(.accentColor)
                }

                Button(
                    action: {
                        self.showingNewClockDetailView = true
                    }
                ) {
                    Text("Add clock")
                }
                .foregroundColor(.accentColor)

                switch self.mainRowsGroupingOption {
//                case .plain:
//                    ASAPlainMainRowsList(groupingOption: .plain, rows: $userData.mainRows, now: $now)

                case .byFormattedDate:
                    ASAMainRowsByFormattedDateList(rows: $userData.mainRows, now: $now)

                case .byCalendar:
                    ASAMainRowsByCalendarList(rows: $userData.mainRows, now: $now)

                case .byPlaceName:
                    ASAMainRowsByPlaceName(rows: $userData.mainRows, now: $now)

                case .westToEast, .eastToWest, .southToNorth, .northToSouth:
                    ASAPlainMainRowsList(groupingOption: self.mainRowsGroupingOption, rows: $userData.mainRows, now: $now)

                case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
                    ASAMainRowsByTimeZoneList(groupingOption: self.mainRowsGroupingOption, rows: $userData.mainRows, now: $now)
                } // switch self.groupingOptions[self.groupingOptionIndex]
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView()
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
            .navigationBarHidden(self.isNavBarHidden)
            .onAppear {
                self.isNavBarHidden = true
            }
            .onDisappear {
                self.isNavBarHidden = false
            }
//            .navigationBarItems(
//                leading: ASAConditionalEditButton(shouldShow: self.mainRowsGroupingOption == .plain),
//                trailing: Button(
//                    action: {
//                        self.showingNewClockDetailView = true
//                    }
//                ) {
//                    Text("Add clock")
//                }
//            )

        }.navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            self.now = Date()
        }
    }
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
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
