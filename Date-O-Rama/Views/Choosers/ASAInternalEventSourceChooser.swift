//
//  ASAInternalEventSourceChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

// TODO:  This view is going to need some serious revision when introducing internal event sources which are not built in!

struct ASAInternalEventSourceChooser: View {
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar

    @State var tempInternalEventCode:  String

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false

    fileprivate func internalEventCodes() -> [String] {
        let mainBundle = Bundle.main
        let URLs = mainBundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        let fileNames = URLs!.map {
            $0.deletingPathExtension().lastPathComponent
        }.sorted(by: {NSLocalizedString($0, comment: "") < NSLocalizedString($1, comment: "")})
        debugPrint(#file, #function, fileNames)
        
        return fileNames
    }
    
    var body: some View {
        List {
            ForEach(internalEventCodes(), id: \.self) {
                potentialEventSourceCode
                in
                ASAInternalEventSourceCell(eventSourceCode: potentialEventSourceCode, selectedEventSourceCode: self.$tempInternalEventCode)
                    .onTapGesture {
//                        debugPrint(#file, #function, potentialEventSourceCode, self.eventCalendar.eventSourceCode, "Before")
                        self.tempInternalEventCode = potentialEventSourceCode
//                        debugPrint(#file, #function, potentialEventSourceCode, self.eventCalendar.eventSourceCode, "After")
                }
            }
        }
        .navigationBarItems(trailing:
            Button("Cancel", action: {
                self.didCancel = true
                self.presentationMode.wrappedValue.dismiss()
            })
        )
            .onAppear() {
                self.tempInternalEventCode = self.eventCalendar.eventSourceCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.eventCalendar.eventSourceCode = self.tempInternalEventCode
                }
            }
    }
}

struct ASAInternalEventSourceCell: View {
    let eventSourceCode: String

    @Binding var selectedEventSourceCode: String

    var body: some View {
        HStack {
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
        ASAInternalEventSourceChooser(eventCalendar: ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode: "Solar events")!, tempInternalEventCode: "Solar events")
    }
}
