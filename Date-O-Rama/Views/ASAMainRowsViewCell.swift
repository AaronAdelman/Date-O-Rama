//
//  ASAMainRowsViewCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMainRowsViewCell:  View {
    @ObservedObject  var row:  ASARow
    var now:  Date
    var INSET:  CGFloat
    var shouldShowTime:  Bool
    
    let ROW_HEIGHT = 30.0 as CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(verbatim: "🗓")
                Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
            }.frame(height: ROW_HEIGHT)
            
            HStack {
                Spacer().frame(width: self.INSET)
                VStack(alignment: .leading) {
                    if row.calendar.canSplitTimeFromDate {
                        Text(verbatim:  row.dateString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                        if shouldShowTime {
                            Text(verbatim:  row.timeString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                        }
                    } else {
                        Text(verbatim:  row.dateTimeString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                    }
                }
            }
//            HStack {
//                Spacer().frame(width: self.INSET)
//                Text(verbatim: "🗓")
//                Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
//            }.frame(height: ROW_HEIGHT)
            
            HStack {
                //                if row.usesDeviceLocation {
                //                    Image(systemName: "location.fill")
                //                }
                VStack(alignment: .leading) {
                    if row.calendar.supportsTimeZones || row.calendar.supportsLocations {
                        //                        HStack {
                        //                            Spacer().frame(width: self.INSET)
                        //                            Text(row.effectiveTimeZone.emoji(date:  self.now))
                        //                            Text(verbatim: "\(row.effectiveTimeZone.localizedName(for: row.effectiveTimeZone.isDaylightSavingTime(for: self.now) ? .daylightSaving : .standard, locale: Locale.current) ?? "") • \(row.effectiveTimeZone.abbreviation() ?? "")").font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                        ASAMainRowsLocationSubcell(INSET: self.INSET, row: row, now: self.now).frame(height: ROW_HEIGHT)
                        //                        }.frame(height: ROW_HEIGHT)
                        //                        ASAMainRowsLocationSubcell(INSET: self.INSET, row: row, now: self.now).frame(height: ROW_HEIGHT)
                    }
                }
            }
            
        } // VStack
    } // var body
} // struct ASAMainRowsViewCell

struct ASAMainRowsLocationSubcell:  View {
    var INSET:  CGFloat
    @ObservedObject var row:  ASARow
    var now:  Date

    var body: some View {
        HStack {
            Spacer().frame(width: self.INSET)
            Text(verbatim:  row.emoji(date:  self.now))

            if row.placeName == nil && row.locality == nil && row.country == nil {
                if row.location != nil {
                    Text(verbatim:  row.location!.humanInterfaceRepresentation()).font(.subheadline)
                }
            } else {
                Text(row.locationData.formattedOneLineAddress()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(2).frame(height: 60.0)
            }
        } // HStack
    }
}

struct ASAMainRowsViewCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsViewCell(row: ASARow.generic(), now: Date(), INSET: 8.0, shouldShowTime: true)
    }
}
