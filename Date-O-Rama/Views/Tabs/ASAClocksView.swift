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

    let groupingOptions:  Array<ASAClocksViewGroupingOption> = [
        .plain,
        .byFormattedDate,
        .byCalendar,
        .byPlaceName,
        .eastToWest,
        .westToEast,
        .northToSouth,
        .southToNorth
    ]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 0.0 as CGFloat

    @State var isNavBarHidden:  Bool = false

    var body: some View {
        NavigationView {
            Form {
                Picker(selection: self.$userData.mainRowsGroupingOption, label: Text("Arrangement")) {
                    ForEach(self.groupingOptions, id:  \.self) {
                        Text($0.text())
                    }
                }

                switch self.userData.mainRowsGroupingOption {
                case .plain:
                    ASAPlainMainRowsList(groupingOption: .plain, rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byFormattedDate:
                    ASAMainRowsByFormattedDateList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byCalendar:
                    ASAMainRowsByCalendarList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byPlaceName:
                    ASAMainRowsByPlaceName(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .westToEast, .eastToWest, .southToNorth, .northToSouth:
                    ASAPlainMainRowsList(groupingOption: self.userData.mainRowsGroupingOption, rows: $userData.mainRows, now: $now, INSET: INSET)
                } // switch self.groupingOptions[self.groupingOptionIndex]
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView()
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
//            .navigationBarHidden(self.isNavBarHidden)
            .onAppear {
                self.isNavBarHidden = true
            }
            .onDisappear {
                self.isNavBarHidden = false
            }
            .navigationBarItems(
                leading: ASAConditionalEditButton(shouldShow: self.userData.mainRowsGroupingOption == .plain),
                trailing: Button(
                    action: {
                        self.showingNewClockDetailView = true
                    }
                ) {
                    Text("Add clock")
                }
            )

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
