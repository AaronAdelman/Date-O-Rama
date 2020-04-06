//
//  ASACalendarPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarPickerView: View {
    let calendarCodes:  Array<ASACalendarCode> = [
        .Gregorian,
        .Buddhist,
        .Chinese,
        .Coptic,
        .EthiopicAmeteAlem,
        .EthiopicAmeteMihret,
        .Hebrew,
        .Indian,
        .Islamic,
        .IslamicCivil,
        .IslamicTabular,
        .IslamicUmmAlQura,
        .ISO8601,
        .Japanese,
        .Persian,
        .RepublicOfChina
    ]
    
    @ObservedObject var row:  ASARow
    
    var body: some View {
        List {
            ForEach(self.calendarCodes, id: \.self) {
                calendarCode
                in
                ASACalendarCell(calendarCode: calendarCode, selectedCalendarCode: self.$row.calendarCode)
            }
        }
        .navigationBarTitle(Text(row.dateString(now: Date()) ))
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
        }   .onTapGesture {
            self.selectedCalendarCode = self.calendarCode
        }
    } // var body
}

struct ASACalendarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarPickerView(row: ASARow.test())
    }
}
