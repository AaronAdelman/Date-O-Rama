//
//  ASAWatchClocksView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

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
        }
        .onReceive(timer) { input in
            DispatchQueue.main.async {
                debugPrint(#file, #function, "Timer signal recieved:", input)
                self.now = input
            }
        }
    }
}

struct ASAWatchClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAWatchClocksView()
    }
}
