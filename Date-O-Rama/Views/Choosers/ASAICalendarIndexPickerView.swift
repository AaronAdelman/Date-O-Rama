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

    var body: some View {
        List {
            ForEach(0..<self.iCalendarEventCalendars.count, id: \.self) {
                i
                in
                ASAICalendarIndexCell(calendar: self.iCalendarEventCalendars[i], index: i, selectedIndex: $selectedIndex)
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
//            let CIRCLE_DIAMETER:  CGFloat = 8.0
//
//            Circle()
//                .foregroundColor(calendar.color)
//                .frame(width: CIRCLE_DIAMETER, height: CIRCLE_DIAMETER)
            ASAColorCircle(color: calendar.color)
            Text(verbatim: calendar.title)
            Spacer()
            if index == selectedIndex {
                ASACheckmarkSymbol()
            }
        } // HStack
        .onTapGesture {
            selectedIndex = index
        }
    } // var body
} // struct ASAICalendarIndexCell


//struct ASAICalendarIndexPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAICalendarIndexPickerView(selectedIndex: <#Binding<Int>#>, iCalendarEventCalendars: <#[EKCalendar]#>)
//    }
//}
