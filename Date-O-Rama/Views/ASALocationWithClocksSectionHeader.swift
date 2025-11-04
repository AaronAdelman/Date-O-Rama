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
        let sectionHeaderFont: Font = Font.title2.bold()
        let sectionHeaderLineLimit = 2
        let sectionHeaderMinimumScaleFactor = 1.0
#endif
        
        let sectionTimeZoneString = location.abbreviatedTimeZoneString(for: now)
        
        ViewThatFits(in: .horizontal) {
            // Regular/wide layout candidate
            HStack {
                if locationWithClocks.usesDeviceLocation {
                    ASALocationSymbol(locationManager: locationWithClocks.locationManager)
                }
                Text(sectionHeaderEmoji)

                ASALocationWithClocksSectionHeaderTitle(
                    title: sectionHeaderTitle,
                    lineLimit: sectionHeaderLineLimit,
                    minimumScaleFactor: sectionHeaderMinimumScaleFactor,
                    shouldCapitalize: shouldCapitalize
                )
                .layoutPriority(1)

                Spacer(minLength: 8)

                Text(sectionTimeZoneString)
                    .foregroundStyle(.secondary)
            }
            .font(sectionHeaderFont)

            // Compact/narrow layout fallback
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if locationWithClocks.usesDeviceLocation {
                        ASALocationSymbol(locationManager: locationWithClocks.locationManager)
                    }
                    Text(sectionHeaderEmoji)

                    ASALocationWithClocksSectionHeaderTitle(
                        title: sectionHeaderTitle,
                        lineLimit: sectionHeaderLineLimit,
                        minimumScaleFactor: sectionHeaderMinimumScaleFactor,
                        shouldCapitalize: shouldCapitalize
                    )
                    .layoutPriority(1)
                }

                Text(sectionTimeZoneString)
                    .foregroundStyle(.secondary)
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
