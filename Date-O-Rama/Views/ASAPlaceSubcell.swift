//
//  ASAPlaceSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAPlaceSubcell:  View {
    var processedRow:  ASAProcessedRow
    var shouldShowPlaceName:  Bool
    var INSET:  CGFloat
    var shouldShowCalendarPizzazztron:  Bool

    #if os(watchOS)
    let compact = false
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif

    var body: some View {
        if shouldShowPlaceName {
            HStack {
                VStack(alignment: .leading) {
                    if processedRow.supportsTimeZones || processedRow.supportsLocations {
                        HStack {
                            Spacer().frame(width: self.INSET)

                            if compact && shouldShowCalendarPizzazztron {
                                VStack {
                                    if processedRow.usesDeviceLocation {
                                        ASASmallLocationSymbol(locationAuthorizationStatus: ASALocationManager.shared.locationAuthorizationStatus)
                                    }
                                    Text(verbatim: processedRow.verticalEmojiString)
                                }
                            } else {
                                if processedRow.usesDeviceLocation {
                                    ASASmallLocationSymbol(locationAuthorizationStatus: ASALocationManager.shared.locationAuthorizationStatus)
                                }
                                Text(verbatim:  processedRow.emojiString)
                            }

                            Text(processedRow.locationString).font(.subheadline)
                        } // HStack
                    }
                }
            }
        } else if processedRow.usesDeviceLocation {
            #if os(watchOS)
            #else
            HStack {
                Spacer().frame(width: self.INSET)
                ASASmallLocationSymbol(locationAuthorizationStatus: ASALocationManager.shared.locationAuthorizationStatus)
            } // HStack
            #endif
        }
    } // var body
} // struct ASAPlaceSubcell

//struct ASAPlaceSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAPlaceSubcell()
//    }
//}
