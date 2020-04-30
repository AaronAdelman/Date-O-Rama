//
//  ASACalendarPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASACalendarPickerView: View {
    let calendarCodes:  Array<ASACalendarCode> = [
        .Gregorian,
        .Buddhist,
        .CCSDSJulianDay,
        .Chinese,
        .CNESJulianDay,
        .Coptic,
        .DublinJulianDay,
        .EthiopicAmeteAlem,
        .EthiopicAmeteMihret,
        .Hebrew,
        .HebrewSolar,
        .Indian,
        .Islamic,
        .IslamicSolar,
        .IslamicCivil,
        .IslamicCivilSolar,
        .IslamicTabular,
        .IslamicTabularSolar,
        .IslamicUmmAlQura,
        .IslamicUmmAlQuraSolar,
        .ISO8601,
        .Japanese,
        .JulianDay,
        .LilianDate,
        .ModifiedJulianDay,
        .Persian,
        .RataDie,
        .ReducedJulianDay,
        .RepublicOfChina,
        .TruncatedJulianDay
    ]
    
    @ObservedObject var row:  ASARow
    var deviceLocation:  CLLocation?
    
    var body: some View {
        List {
            ForEach(self.calendarCodes, id: \.self) {
                calendarCode
                in
                ASACalendarCell(calendarCode: calendarCode, selectedCalendarCode: self.$row.calendar.calendarCode).onTapGesture {
                    self.row.calendar = ASACalendarFactory.calendar(code: calendarCode)!
                }
            }
        }
        .navigationBarTitle(Text(row.dateString(now: Date(), defaultLocation: self.deviceLocation ) ))
    }
}

struct ASACalendarCell: View {
    let calendarCode: ASACalendarCode

    @Binding var selectedCalendarCode: ASACalendarCode
    
    var body: some View {
        HStack {
            Text(verbatim: calendarCode.localizedName())
            Spacer()
            if self.calendarCode == self.selectedCalendarCode {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
//        .onTapGesture {
//            self.selectedCalendarCode = self.calendarCode
//        }
    } // var body
} // struct ASACalendarCell

struct ASACalendarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarPickerView(row: ASARow.test(), deviceLocation: CLLocation.NullIsland)
    }
}
