//
//  ASADatePickerEnsemble.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 19/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//


struct ASADatePickerEnsemble: View {
    @Binding var now: Date
    @Binding var selectedCalendar: Calendar
    
    var body: some View {
        HStack {
            Spacer()
            
            DatePicker(
                selection: $now,
                in: Date.distantPast...Date.distantFuture,
                displayedComponents: [.date, .hourAndMinute]
            ) {
                Text("")
            }
            .environment(\.calendar, selectedCalendar)
            .datePickerStyle(.compact)
            
            Menu {
                ForEach(ASACalendarCode.datePickerSafeCalendars, id: \.self) { calendar in
                    Button {
                        selectedCalendar = Calendar(identifier: calendar.equivalentCalendarIdentifier!)
                    } label: {
                        Label(calendar.localizedName, systemImage: selectedCalendar.identifier == calendar.equivalentCalendarIdentifier ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "calendar")
                    .symbolRenderingMode(.multicolor)
            }
            
            Spacer()
        }
    }
}