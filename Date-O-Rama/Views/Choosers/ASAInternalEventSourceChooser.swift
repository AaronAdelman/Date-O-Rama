//
//  ASAInternalEventSourceChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAInternalEventSourceChooser: View {
    let eventSourceCodes:  Array<ASAInternalEventSourceCode> = [
        .solar,
        .dailyJewish,
        .test
    ]
    
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar
    
    var body: some View {
        List {
            ForEach(self.eventSourceCodes, id: \.self) {
                potentialEventSourceCode
                in
                ASAInternalEventSourceCell(eventSourceCode: potentialEventSourceCode, selectedEventSourceCode: self.$eventCalendar.eventSourceCode)
                    .onTapGesture {
                        debugPrint(#file, #function, potentialEventSourceCode, self.eventCalendar.eventSourceCode, "Before")
                        self.eventCalendar.eventSourceCode = potentialEventSourceCode
                        debugPrint(#file, #function, potentialEventSourceCode, self.eventCalendar.eventSourceCode, "After")
                }
            }
        }
    }
}

struct ASAInternalEventSourceCell: View {
    let eventSourceCode: ASAInternalEventSourceCode

    @Binding var selectedEventSourceCode: ASAInternalEventSourceCode
    
    var body: some View {
        HStack {
            Text(verbatim: eventSourceCode.localizedName()).font(.headline)
            Spacer()
            if self.eventSourceCode == self.selectedEventSourceCode {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    } // var body
} // struct ASACalendarCell

struct ASAInternalEventSourceChooser_Previews: PreviewProvider {
    static var previews: some View {
        ASAInternalEventSourceChooser(eventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: .dailyJewish)!)
    }
}
