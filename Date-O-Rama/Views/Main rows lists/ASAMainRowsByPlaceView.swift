//
//  ASAMainRowsByPlaceNameView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsByPlaceView:  View {
    @EnvironmentObject var userData:  ASAUserData
    var primaryGroupingOption:  ASAClocksViewGroupingOption
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    @Binding var rows:  Array<ASARow>
    var processedRowsByPlace: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            switch primaryGroupingOption {
            case .byPlaceName:
                return self.rows.processedRowsByPlaceName(now: now)
                
            case .byCountry:
                return self.rows.processedRowsByCountry(now: now)
                
            default:
                return [:]
            }
        } // get
    }
    @Binding var now:  Date
    
    //    var shouldShowTimeToNextDay:  Bool
    
    var forComplications:  Bool
    
    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByPlace.keys).sorted()
        } // get
    } // var keys:  Array<String>
    
    var body: some View {
        ASAMainRowsByPlaceSubview(primaryGroupingOption: self.primaryGroupingOption, secondaryGroupingOption: $secondaryGroupingOption, processedRowsByPlace: processedRowsByPlace, now: $now, forComplications: forComplications)
    } // var body
} // struct ASAMainRowsByPlaceNameView


struct ASAMainRowsByPlaceSubview:  View {
    var primaryGroupingOption:  ASAClocksViewGroupingOption
    @Binding var secondaryGroupingOption:  ASAClocksViewGroupingOption
    var processedRowsByPlace: Dictionary<String, Array<ASAProcessedRow>>
    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByPlace.keys).sorted()
        } // get
    } // var keys:  Array<String>
    @Binding var now:  Date
    //   var shouldShowTimeToNextDay:  Bool
    
    @EnvironmentObject var userData:  ASAUserData
    var forComplications:  Bool
    
    fileprivate func shouldShowPlaceName() -> Bool {
        return self.primaryGroupingOption != .byPlaceName
    }
    
    var body:  some View {
        ForEach(self.keys, id: \.self) {
            key
            in
            Section(header: HStack {
                Text(self.processedRowsByPlace[key]![0].flagEmojiString)
                Text("\(key)").font(Font.headlineMonospacedDigit)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }) {
                ForEach(self.processedRowsByPlace[key]!.sorted(secondaryGroupingOption), id:  \.row.uuid) {
                    processedRow
                    in
                    
                    #if os(watchOS)
                    //                    HStack {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: shouldShowPlaceName(), shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                    //                        Rectangle().frame(width:  CGFloat(CGFloat(now.timeIntervalSince1970 - now.timeIntervalSince1970)))
                    //                    }
                    #else
                    // Hack courtesy of https://nukedbit.dev/hide-disclosure-arrow-indicator-on-swiftui-list/
                    ZStack {
                        ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: shouldShowPlaceName(), shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, forComplications: forComplications)
                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                        }
                        .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
                    } // ZStack
                    .listRowInsets(.zero)
                    #endif
                }
            }
        }
    }
}


struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByPlaceView(primaryGroupingOption: .byPlaceName, secondaryGroupingOption: .constant(.eastToWest), rows: .constant([ASARow.generic]), now: .constant(Date()), forComplications: false)
    }
}
