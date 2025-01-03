//
//  ASAMainClocksViewSectionHeader.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainClocksViewSectionHeader: View {
    var locationWithClocks: ASALocationWithClocks
    var now: Date
    
#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
#endif
    
    var body: some View {
        let location = locationWithClocks.location
        
        let sectionHeaderEmoji = location.flag
#if os(watchOS)
        let sectionHeaderTitle = location.shortFormattedOneLineAddress
        let sectionHeaderFont: Font = Font.title3
        let sectionHeaderLineLimit = 1
        let sectionHeaderMinimumScaleFactor = 0.50
#else
        let sectionHeaderTitle = location.formattedOneLineAddress
        let sectionHeaderFont: Font = Font.title2
        let sectionHeaderLineLimit = 2
        let sectionHeaderMinimumScaleFactor = 1.0
#endif
        
        let sectionTimeZoneString = location.abbreviatedTimeZoneString(for: now)
        
        if compact {
            VStack(alignment: .leading) {
                HStack {
                    if locationWithClocks.usesDeviceLocation {
                        ASALocationSymbol()
                    }
                    Text(sectionHeaderEmoji)
                    Text(sectionHeaderTitle)
                        .textCase(.uppercase)
                        .lineLimit(sectionHeaderLineLimit)
                        .minimumScaleFactor(sectionHeaderMinimumScaleFactor)
                }
                
                Text(sectionTimeZoneString)
            }
            .font(sectionHeaderFont)
        } else {
            HStack {
                if locationWithClocks.usesDeviceLocation {
                    ASALocationSymbol()
                }
                Text(sectionHeaderEmoji)
                Text(sectionHeaderTitle)
                    .textCase(.uppercase)
                    .lineLimit(sectionHeaderLineLimit)
                    .minimumScaleFactor(sectionHeaderMinimumScaleFactor)
                
                Spacer()
                
                Text(sectionTimeZoneString)
            }
            .font(sectionHeaderFont)
        }
    }
}

//struct ASAMainClocksViewSectionHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMainClocksViewSectionHeader()
//    }
//}
