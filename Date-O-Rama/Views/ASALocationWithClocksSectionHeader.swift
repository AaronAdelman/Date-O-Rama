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
            HStack(alignment: .firstTextBaseline, spacing: 8) {
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
                .fixedSize(horizontal: false, vertical: true)

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
                    .fixedSize(horizontal: false, vertical: true)
                }

                Text(sectionTimeZoneString)
                    .foregroundStyle(.secondary)
            }
            .font(sectionHeaderFont)
            
            // Very compact/narrow layout fallback
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if locationWithClocks.usesDeviceLocation {
                        ASALocationSymbol(locationManager: locationWithClocks.locationManager)
                    }
                    Text(sectionHeaderEmoji)
                }
                HStack {
                    ASALocationWithClocksSectionHeaderTitle(
                        title: sectionHeaderTitle,
                        lineLimit: sectionHeaderLineLimit,
                        minimumScaleFactor: sectionHeaderMinimumScaleFactor,
                        shouldCapitalize: shouldCapitalize
                    )
                    .layoutPriority(1)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Text(sectionTimeZoneString)
                    .foregroundStyle(.secondary)
            }
            .font(sectionHeaderFont)
        } // ViewThatFits(in: .horizontal)
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
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(title)
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

//struct ASAMainClocksViewSectionHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationWithClocksSectionHeader()
//    }
//}

