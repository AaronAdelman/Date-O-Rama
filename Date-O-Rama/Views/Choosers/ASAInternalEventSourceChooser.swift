//
//  ASAInternalEventSourceChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAInternalEventSourceChooser: View {
//    let eventSourceCodes:  Array<ASAInternalEventSourceCode> = [
//        .solar,
//        .dailyJewish,
//        .allDayJewish,
//        .israeli,
//        .lubavitch,
//        .test
//    ]
    
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar
    
    fileprivate func internalEventCodes() -> [String] {
        let mainBundle = Bundle.main
        let URLs = mainBundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        let fileNames = URLs!.map {
            $0.deletingPathExtension().lastPathComponent
        }
        debugPrint(#file, #function, fileNames)
        
//        return self.eventSourceCodes
        return fileNames
    }
    
    var body: some View {
        List {
            ForEach(internalEventCodes(), id: \.self) {
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
//    let eventSourceCode: ASAInternalEventSourceCode
    let eventSourceCode: String

//    @Binding var selectedEventSourceCode: ASAInternalEventSourceCode
    @Binding var selectedEventSourceCode: String

    var body: some View {
        HStack {
//            Text(verbatim: eventSourceCode.localizedName()).font(.headline)
            Text(verbatim: NSLocalizedString(eventSourceCode, comment: "")).font(.headline)
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
//        ASAInternalEventSourceChooser(eventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: .dailyJewish)!)
        ASAInternalEventSourceChooser(eventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: "Solar events")!)
    }
}
