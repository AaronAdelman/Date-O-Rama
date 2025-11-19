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
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    @State var tempTimeFormat:  ASATimeFormat
    @State var calendarCode:  ASACalendarCode
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    
    var body: some View {
        List {
            Section(header:  Text("HEADER_Time_format")) {
                ForEach(clock.calendar.supportedTimeFormats, id: \.self) {
                    format
                    in
                    ASATimeFormatCell(timeFormat: format, selectedTimeFormat: self.$tempTimeFormat, clock: clock, location: location)
                        .onTapGesture {
                            self.tempTimeFormat = format
                            
                            self.dismiss()
                        }
                }
            } // Section
        } // List
        .onAppear() {
            self.tempTimeFormat = self.clock.timeFormat
            self.calendarCode        = self.clock.calendar.calendarCode
        }
        .onDisappear() {
            self.clock.timeFormat = self.tempTimeFormat
        }
    }
}


// MARK: -

struct ASATimeFormatCell: View {
    let timeFormat: ASATimeFormat
    
    @Binding var selectedTimeFormat:  ASATimeFormat
    
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    var body: some View {
        HStack {
            Text(verbatim:  timeFormat.localizedItemName)
            Spacer()
                .frame(width: 20.0)
            Text(verbatim: clock.calendar.dateTimeString(now: Date(), localeIdentifier: clock.localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: location))
                .foregroundColor(Color.secondary)
            Spacer()
            if timeFormat == self.selectedTimeFormat {
                ASACheckmarkSymbol()
            }
        }
    }
} // struct ASATimeFormatCell


// MARK: -

struct ASATimeFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeFormatChooserView(clock: ASAClock.generic, location: .NullIsland, tempTimeFormat: .medium, calendarCode: .gregorian)
    }
}
