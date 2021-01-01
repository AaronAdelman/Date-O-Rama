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

    var body: some View {
        if shouldShowPlaceName {
            HStack {
                VStack(alignment: .leading) {
                    if processedRow.supportsTimeZones || processedRow.supportsLocations {
                        HStack(alignment: .top) {
                            if processedRow.usesDeviceLocation {
                                ASASmallLocationSymbol()
                            }
                            Text(verbatim:  processedRow.flagEmojiString)
                            ASAClockCellText(string:  processedRow.locationString, font:  Font.subheadlineMonospacedDigit, lineLimit:  2)
                        } // HStack
                    }
                }
            }
        } else if processedRow.usesDeviceLocation {
            #if os(watchOS)
            #else
            ASASmallLocationSymbol()
            #endif
        }
    } // var body
} // struct ASAPlaceSubcell

//struct ASAPlaceSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAPlaceSubcell()
//    }
//}
