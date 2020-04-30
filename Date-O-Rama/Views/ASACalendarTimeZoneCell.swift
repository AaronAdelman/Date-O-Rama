//
//  ASACalendarTimeZoneCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarTimeZoneCell:  View {
    var timeZone:  TimeZone
    var now:  Date

    var body:  some View {
        HStack {
            Text(timeZone.emoji(date:  now))
            Text(verbatim:  NSLocalizedString("HEADER_TIME_ZONE", comment: "")).bold()
            Spacer()
            VStack {
                if timeZone == TimeZone.autoupdatingCurrent {
                    HStack {
                        Spacer()
                        Text("AUTOUPDATING_CURRENT_TIME_ZONE").multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Spacer()
                    Text(verbatim:  timeZone.abbreviation(for:  now) ?? "").multilineTextAlignment(.trailing)
                }
                HStack {
                    Spacer()
                    Text(verbatim:  timeZone.localizedName(for: timeZone.isDaylightSavingTime(for: now) ? .daylightSaving : .standard, locale: Locale.current) ?? "").multilineTextAlignment(.trailing)
                }
            }
        } // HStack
    } // var body
} // struct ASACalendarTimeZoneCell

struct ASACalendarTimeZoneCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarTimeZoneCell(timeZone: TimeZone.autoupdatingCurrent, now: Date())
    }
}
