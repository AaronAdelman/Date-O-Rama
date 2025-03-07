//
//  ASATimeZoneCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATimeZoneCell:  View {
    @Binding var timeZone:  TimeZone
    var now:  Date

    var body:  some View {
        HStack {
            Text(verbatim:  NSLocalizedString("HEADER_TIME_ZONE", comment: ""))
                .bold()
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
                    Text(verbatim:  timeZone.localizedName(for: now)).multilineTextAlignment(.trailing)
                }
            }
        } // HStack
    } // var body
} // struct ASATimeZoneCell

struct ASATimeZoneCell_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeZoneCell(timeZone: .constant(TimeZone.autoupdatingCurrent) , now: Date())
    }
}
