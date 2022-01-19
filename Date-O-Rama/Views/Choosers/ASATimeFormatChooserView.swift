//
//  ASATimeFormatChooserView.swift
//  Time-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-07.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASATimeFormatChooserView: View {
    @ObservedObject var row:  ASAClock

    @State var tempTimeFormat:  ASATimeFormat
    @State var calendarCode:  ASACalendarCode

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @State var didCancel = false
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    
    var body: some View {
        List {
            Section(header:  Text("HEADER_Time_format")) {
                ForEach(row.calendar.supportedTimeFormats, id: \.self) {
                    format
                    in
                    ASATimeFormatCell(timeFormat: format, selectedTimeFormat: self.$tempTimeFormat, row: row)
                        .onTapGesture {
                            self.tempTimeFormat = format
                            
                            self.dismiss()
                        }
                }
            } // Section
        } // List
//            .navigationBarItems(trailing:
//                Button("Cancel", action: {
//                    self.didCancel = true
//                    self.presentationMode.wrappedValue.dismiss()
//                })
//        )
            .onAppear() {
                self.tempTimeFormat = self.row.timeFormat
                self.calendarCode        = self.row.calendar.calendarCode
        }
        .onDisappear() {
//            if !self.didCancel {
                self.row.timeFormat = self.tempTimeFormat
//            }
        }
    }
}


// MARK: -

struct ASATimeFormatCell: View {
    let timeFormat: ASATimeFormat
    
    @Binding var selectedTimeFormat:  ASATimeFormat

    @ObservedObject var row:  ASAClock

    var body: some View {
        HStack {
            Text(verbatim:  timeFormat.localizedItemName)
            Spacer()
                .frame(width: 20.0)
            Text(verbatim: row.calendar.dateTimeString(now: Date(), localeIdentifier: row.localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: row.locationData))
                .foregroundColor(Color.secondary)
            Spacer()
            if timeFormat == self.selectedTimeFormat {
                ASACheckmarkSymbol()
            }
        }
//        .onTapGesture {
//            self.selectedTimeFormat = self.timeFormat
//        }
    }
} // struct ASATimeFormatCell


// MARK: -

struct ASATimeFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeFormatChooserView(row: ASAClock.generic, tempTimeFormat: .medium, calendarCode: .Gregorian)
    }
}
