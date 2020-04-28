//
//  ASATimeZonePickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-27.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATimeZoneRecord {
    var identifier:  String
    var timeZone:  TimeZone
    var abbreviation:  String
    var localizedName:  String
} // struct ASATimeZoneRecord


struct ASATimeZoneCell: View {
    let record:  ASATimeZoneRecord
    let CHECKMARK_WIDTH = 20.0 as CGFloat
    
    @Binding var selectedTimeZone:  TimeZone
    
    var body: some View {
        HStack {
            Text(verbatim: record.identifier).frame(width:  125.0).multilineTextAlignment(.leading)
            Spacer()
            Text(verbatim: record.abbreviation).frame(width: 100.0).multilineTextAlignment(.center)
            Spacer()
            Text(verbatim: record.localizedName).frame(width:  150.0).multilineTextAlignment(.leading)
            if self.record.timeZone == self.selectedTimeZone {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor).frame(width:  CHECKMARK_WIDTH)
            } else {
                Spacer().frame(width:  CHECKMARK_WIDTH)
            }
        }
    } // var body
} // struct ASATimeZoneCell


struct ASATimeZonePickerView: View {
    var timeZoneRecords:  Array<ASATimeZoneRecord> = {
        let now = Date()
        var result:  Array<ASATimeZoneRecord> = [
            ASATimeZoneRecord(identifier: TimeZone.autoupdatingCurrent.identifier, timeZone: TimeZone.autoupdatingCurrent, abbreviation: TimeZone.autoupdatingCurrent.abbreviation() ?? "", localizedName: NSLocalizedString("AUTOUPDATING_CURRENT_TIME_ZONE", comment: ""))
        ]
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            let timeZone = TimeZone(identifier: identifier)!
            let abbreviation: String = timeZone.abbreviation(for:  now) ?? ""
            let localizedName: String = timeZone.localizedName(for: timeZone.isDaylightSavingTime(for: now) ? .daylightSaving : .standard, locale: Locale.current)!
            let record = ASATimeZoneRecord(identifier: identifier, timeZone: timeZone, abbreviation: abbreviation, localizedName: localizedName)
            result.append(record)
        } // for identifier in TimeZone.knownTimeZoneIdentifiers
        
        return result
    }()
    
    @ObservedObject var row:  ASARow
    
    var body: some View {
        List {
            ForEach(self.timeZoneRecords, id: \.identifier) {
                record
                in
                ASATimeZoneCell(record: record, selectedTimeZone: self.$row.timeZone).onTapGesture {
                    self.row.timeZone = record.timeZone
                }
            }
        }
    }
}


struct ASATimeZonePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeZonePickerView(row: ASARow.test())
    }
}
