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

//    @AppStorage("mainRowsGroupingOption") var primaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byPlaceName
//    @AppStorage("secondaryMainRowsGroupingOption") var secondaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byFormattedDate
//    @AppStorage("secondaryMainRowsGroupingOption") var secondaryMainRowsGroupingOption:  ASAClocksViewGroupingOption = .byCalendar
//   let shouldShowTimeToNextDay = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            Form {
//                Picker(selection: self.$primaryMainRowsGroupingOption, label: Text("Arrangement")) {
//                    ForEach(ASAClocksViewGroupingOption.primaryOptions, id:  \.self) {
//                        Text($0.text())
//                    }
//                }.onChange(of: self.primaryMainRowsGroupingOption, perform: {(foo)
//                    in
//                    if !self.primaryMainRowsGroupingOption.compatibleOptions.contains(self.secondaryMainRowsGroupingOption) {
//                        self.secondaryMainRowsGroupingOption = self.primaryMainRowsGroupingOption.defaultCompatibleOption
//                    }
//                })
//
//                Picker(selection: self.$secondaryMainRowsGroupingOption, label: Text("Secondary arrangement")) {
//                    ForEach(self.primaryMainRowsGroupingOption.compatibleOptions, id:  \.self) {
//                        Text($0.text())
//                    }
//                }

//                switch self.primaryMainRowsGroupingOption {
////                case .byFormattedDate:
////                    ASAMainClocksByFormattedDateView(rows: $userData.mainClocks, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption)
//
//                case .byCalendar:
//                    ASAMainClocksByCalendarView(rows: $userData.mainClocks, now: $now, secondaryGroupingOption: $secondaryMainRowsGroupingOption)
//
//                case .byPlaceName
////                    , .byCountry
//                    :
                    ASAMainClocksByPlaceView(
//                        primaryGroupingOption: primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption,
                        rows: $userData.mainClocks, now: $now)
//
////                case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
////                    ASAMainClocksByTimeZoneView(primaryGroupingOption: self.primaryMainRowsGroupingOption, secondaryGroupingOption: $secondaryMainRowsGroupingOption, rows: $userData.mainClocks, now: $now)
//
////                default:
////                    EmptyView()
//                } // switch self.groupingOptions[self.groupingOptionIndex]
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
