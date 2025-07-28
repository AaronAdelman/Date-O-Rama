//
//  ASALocationWithClocksSectionHeader.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationWithClocksSectionHeader: View {
    var locationWithClocks: ASALocationWithClocks
    var now: Date
    var shouldCapitalize: Bool
    
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
                        ASALocationSymbol(locationManager: locationWithClocks.locationManager)
                    }
                    Text(sectionHeaderEmoji)
                    
                    ASALocationWithClocksSectionHeaderTitle(title: sectionHeaderTitle, lineLimit: sectionHeaderLineLimit, minimumScaleFactor: sectionHeaderMinimumScaleFactor, shouldCapitalize: shouldCapitalize)
                }
                
                Text(sectionTimeZoneString)
            }
            .font(sectionHeaderFont)
        } else {
            HStack {
                if locationWithClocks.usesDeviceLocation {
                    ASALocationSymbol(locationManager: locationWithClocks.locationManager)
                }
                Text(sectionHeaderEmoji)
                ASALocationWithClocksSectionHeaderTitle(title: sectionHeaderTitle, lineLimit: sectionHeaderLineLimit, minimumScaleFactor: sectionHeaderMinimumScaleFactor, shouldCapitalize: shouldCapitalize)
                
                Spacer()
                
                Text(sectionTimeZoneString)
            }
            .font(sectionHeaderFont)
        }
    }
}

struct ASALocationWithClocksSectionHeaderTitle: View {
    var title: String
    var lineLimit: Int
    var minimumScaleFactor: Double
    var shouldCapitalize: Bool

    var body: some View {
        if shouldCapitalize {
            Text(title)
                .textCase(.uppercase)
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
        } else {
            Text(title)
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
        }
    }
}

//struct ASAMainClocksViewSectionHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationWithClocksSectionHeader()
//    }
//}
