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

    @AppStorage("mainRowsGroupingOption") var primaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName
    @AppStorage("secondaryMainRowsGroupingOption") var secondaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byFormattedDate
    let shouldShowTimeToNextDay = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            Form {
                Picker(selection: self.$primaryMainRowsGroupingOption, label: Text("Arrangement")) {
                    ForEach(ASAClocksViewGroupingOption.primaryOptions, id:  \.self) {
                        Text($0.text())
                    }
                }.onChange(of: self.primaryMainRowsGroupingOption, perform: {(foo)
                    in
                    if !self.primaryMainRowsGroupingOption.compatibleOptions.contains(self.secondaryMainRowsGroupingOption) {
                        self.secondaryMainRowsGroupingOption = self.primaryMainRowsGroupingOption.defaultCompatibleOption
                    }
                })

                Picker(selection: self.$secondaryMainRowsGroupingOption, label: Text("Secondary arrangement")) {
                    ForEach(self.primaryMainRowsGroupingOption.compatibleOptions, id:  \.self) {
                        Text($0.text())
                    }
                }

                switch self.primaryMainRowsGroupingOption {
                case .byFormattedDate:
                    ASAMainRowsByFormattedDateView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications:  false)

                case .byCalendar:
                    ASAMainRowsByCalendarView(rows: $userData.mainRows, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications: false)

                case .byPlaceName, .byCountry:
                    ASAMainRowsByPlaceView(primaryGroupingOption: primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications: false)

                case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
                    ASAMainRowsByTimeZoneView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainRows, now: $now, shouldShowTimeToNextDay: shouldShowTimeToNextDay, forComplications:  false)

                default:
                    EmptyView()
                } // switch self.groupingOptions[self.groupingOptionIndex]
            }
        }
        .onReceive(timer) { input in
            DispatchQueue.main.async {
//                debugPrint(#file, #function, "Timer signal recieved:", input)
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
