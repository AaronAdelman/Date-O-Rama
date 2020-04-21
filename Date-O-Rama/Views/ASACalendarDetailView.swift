//
//  ASACalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarDetailCell:  View {
    var title:  String
    var detail:  String
    var body:  some View {
        HStack {
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail)
        } // HStack
    } // var body
} // struct ASADetailCell


struct ASACalendarDetailView: View {
    @ObservedObject var selectedRow:  ASARow
     var now:  Date
    
    var body: some View {
        List {
            //            if selectedRow != nil {
            if selectedRow.dummy != true {
                Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                    NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow)) {
                        ASACalendarDetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendar.calendarCode.localizedName())
                    }
                    if selectedRow.supportsLocales() {
                        NavigationLink(destination: ASALocalePickerView(row: selectedRow)) {
                            ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                        }
                    }
                    NavigationLink(destination: ASAFormatPickerView(row: selectedRow)) {
                        ASACalendarDetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                    }
                }
                Section(header:  Text("HEADER_Date")) {
                    ForEach(selectedRow.details(), id: \.name) {
                        detail
                        in
                        HStack {
                            Text(NSLocalizedString(detail.name, comment: "")).bold()
                            Spacer()
                            Text(verbatim:  (self.selectedRow.dateString(now: self.now, LDMLString: detail.geekCode)) )
                        }
                    }
                }
            } else {
                //                Text("Detail view content goes here")
                EmptyView()
            }
        }.navigationBarTitle(Text(selectedRow.dateString(now: self.now) ))
    }
}

struct ASACalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailView(selectedRow: ASARow.generic(), now: Date())
    }
}
