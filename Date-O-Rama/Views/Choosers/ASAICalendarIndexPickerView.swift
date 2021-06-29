//
//  ASAICalendarIndexPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 15/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI
import EventKit

struct ASAICalendarIndexPickerView: View {
    var iCalendarEventCalendars:  Array<EKCalendar>
    @Binding var selectedIndex: Int
    
    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    var body: some View {
        List {
            ForEach(0..<self.iCalendarEventCalendars.count, id: \.self) {
                i
                in
                ASAICalendarIndexCell(calendar: self.iCalendarEventCalendars[i], index: i, selectedIndex: $selectedIndex)
                    .onTapGesture {
                        selectedIndex = i
                        self.dismiss()
                    }
            }
        } // List
        .navigationBarTitle("Event Recurrence", displayMode: .inline)
    } // var body
} // struct ASAICalendarIndexPickerView


struct ASAICalendarIndexCell: View {
    var calendar: EKCalendar
    var index: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack {
            ASAColorCircle(color: calendar.color)
            Text(verbatim: calendar.title)
            Spacer()
            if index == selectedIndex {
                ASACheckmarkSymbol()
            }
        } // HStack
    } // var body
} // struct ASAICalendarIndexCell


//struct ASAICalendarIndexPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAICalendarIndexPickerView(selectedIndex: <#Binding<Int>#>, iCalendarEventCalendars: <#[EKCalendar]#>)
//    }
//}
