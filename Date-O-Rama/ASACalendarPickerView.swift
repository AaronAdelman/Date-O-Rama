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
    
    @State var calendarCode = ASACalendarCode.Gregorian
    
    var body: some View {
        List {
            ForEach(self.calendarCodes, id: \.self) {
                calendarCode
                in
                ASACalendarCell(calendarCode: calendarCode, selectedCalendarCode: self.$calendarCode)
            }
        }
    }
}

struct ASACalendarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarPickerView()
    }
}
