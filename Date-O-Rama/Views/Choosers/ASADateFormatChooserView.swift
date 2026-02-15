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
    @ObservedObject var clock:  ASAClock
    var location: ASALocation

    @State var tempDateFormat:  ASADateFormat
    @State var calendarCode:  ASACalendarCode

    var forAppleWatch:  Bool

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    fileprivate func dateFormats() -> [ASADateFormat] {
        if forAppleWatch {
            return clock.calendar.supportedWatchDateFormats
        }
        
        return clock.calendar.supportedDateFormats
    }
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()


    var body: some View {
        List {
            Section(header:  Text("HEADER_Date_format")) {
                ForEach(dateFormats(), id: \.self) {
                    format
                    in
                    ASADateFormatCell(dateFormat: format, selectedDateFormat: self.$tempDateFormat, clock: clock, location: location)
                        .onTapGesture {
                            self.tempDateFormat = format
                            
                            self.dismiss()
                        }
                }
            } // Section
        } // List
            .onAppear() {
                self.tempDateFormat = self.clock.dateFormat
                self.calendarCode        = self.clock.calendar.calendarCode
        }
        .onDisappear() {
//            if !self.didCancel {
                self.clock.dateFormat = self.tempDateFormat
//            }
        }
    }
}


// MARK: -

struct ASADateFormatCell: View {
    let dateFormat: ASADateFormat
    
    @Binding var selectedDateFormat:  ASADateFormat

    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    var body: some View {
        HStack {
            Text(verbatim:  dateFormat.localizedItemName)
            Spacer()
                .frame(width: 20.0)
            Text(verbatim: clock.calendar.dateTimeString(now: Date(), localeIdentifier: clock.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: location))
                .foregroundStyle(Color.secondary)

            Spacer()
            if dateFormat == self.selectedDateFormat {
                ASACheckmarkSymbol()
            }
        }
//        .onTapGesture {
//            self.selectedDateFormat = self.dateFormat
//        }
    }
} // struct ASADateFormatCell


// MARK: -

struct ASADateFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASADateFormatChooserView(clock: ASAClock.generic, location: .nullIsland, tempDateFormat: .full, calendarCode: .gregorian, forAppleWatch: true)
    }
}
