//
//  ASACalendarCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarCell: View {
    let calendarCode: ASACalendarCode

    @Binding var selectedCalendarCode: ASACalendarCode
    
    var body: some View {
        HStack {
            Text(verbatim: NSLocalizedString(calendarCode.rawValue, comment: ""))
            Spacer()
            if self.calendarCode == selectedCalendarCode {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.selectedCalendarCode = self.calendarCode
        }
    } // var body
}

struct ASACalendarCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarCell(calendarCode: .Hebrew, selectedCalendarCode: .constant(.Gregorian))
    }
}
