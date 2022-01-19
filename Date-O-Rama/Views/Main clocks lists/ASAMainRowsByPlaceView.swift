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
    @Binding var rows:  Array<ASAClock>
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
    
//    var isForComplications:  Bool
    
    func keys() -> Array<String> {
        var here: String?
        if primaryGroupingOption == .byPlaceName {
            #if os(watchOS)
            here = ASALocationManager.shared.deviceLocationData.shortFormattedOneLineAddress
            #else
            here = ASALocationManager.shared.deviceLocationData.formattedOneLineAddress
            #endif
        } else {
            here = ASALocationManager.shared.deviceLocationData.country
        }
        
        return Array(self.processedRowsByPlace.keys).sorted(by: {
            element1, element2
            in
            if element1 == here {
                return true
            }
            
            if element2 == here {
                return false
            }
            
            return element1 < element2
        })
    } // func keys() -> Array<String>
    
    fileprivate func shouldShowPlaceName() -> Bool {
        return self.primaryGroupingOption != .byPlaceName
    }
    
    var body:  some View {
        let processedRows: [String : [ASAProcessedRow]] = self.processedRowsByPlace
        let keys: [String] = self.keys()
        ForEach(keys, id: \.self) {
            key
            in
            Section(header: HStack {
                Text(processedRows[key]![0].flagEmojiString)
                Text("\(key)").font(Font.headlineMonospacedDigit)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }) {
                let sortedProcessedRows = processedRows[key]!.sorted(secondaryGroupingOption)
                ForEach(sortedProcessedRows.indices, id: \.self) {
                    index
                    in
                    let processedRow = sortedProcessedRows[index]
                    
                    #if os(watchOS)
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: shouldShowPlaceName(), shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: false)
                    #else
                    let indexIsOdd = index % 2 == 1
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: shouldShowPlaceName(), shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: indexIsOdd)
                    #endif
                }
            }
        }
    }
}


struct ASAMainRowsByPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsByPlaceView(primaryGroupingOption: .byPlaceName, secondaryGroupingOption: .constant(.eastToWest), rows: .constant([ASAClock.generic]), now: .constant(Date()))
    }
}
