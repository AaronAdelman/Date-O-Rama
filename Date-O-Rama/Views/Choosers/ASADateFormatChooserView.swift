//
//  ASADateFormatChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASADateFormatChooserView: View {
    @ObservedObject var row:  ASARow

    @State var tempDateFormat:  ASADateFormat
    @State var calendarCode:  ASACalendarCode

    var forAppleWatch:  Bool

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false

    fileprivate func dateFormats() -> [ASADateFormat] {
        if forAppleWatch {
            return row.calendar.supportedWatchDateFormats
        }
        
        return row.calendar.supportedDateFormats
    }

    var body: some View {
        List {
            Section(header:  Text("HEADER_Date_format")) {
                ForEach(dateFormats(), id: \.self) {
                    format
                    in
                    ASADateFormatCell(dateFormat: format, selectedDateFormat: self.$tempDateFormat, row: row)
                }
            } // Section
        } // List
            .navigationBarItems(trailing:
                Button("Cancel", action: {
                    self.didCancel = true
                    self.presentationMode.wrappedValue.dismiss()
                })
        )
            .onAppear() {
                self.tempDateFormat = self.row.dateFormat
                self.calendarCode        = self.row.calendar.calendarCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.row.dateFormat = self.tempDateFormat
            }
        }
    }
}


// MARK: -

struct ASADateFormatCell: View {
    let dateFormat: ASADateFormat
    
    @Binding var selectedDateFormat:  ASADateFormat

    @ObservedObject var row:  ASARow
    
    var body: some View {
        HStack {
            Text(verbatim:  dateFormat.localizedItemName)
            Spacer()
                .frame(width: 20.0)
            Text(verbatim: row.calendar.dateTimeString(now: Date(), localeIdentifier: row.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: row.locationData))
                .foregroundColor(Color.secondary)

            Spacer()
            if dateFormat == self.selectedDateFormat {
                ASACheckmarkSymbol()
            }
        }   .onTapGesture {
            self.selectedDateFormat = self.dateFormat
        }
    }
} // struct ASADateFormatCell


// MARK: -

struct ASADateFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASADateFormatChooserView(row: ASARow.generic, tempDateFormat: .full, calendarCode: .Gregorian, forAppleWatch: true)
    }
}
