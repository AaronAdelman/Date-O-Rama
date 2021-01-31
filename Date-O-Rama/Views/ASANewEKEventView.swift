//
//  ASANewEKEventView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import SwiftUI

struct ASANewEKEventView: View {
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay: Bool = false
//    @State private var calendar: EKCalendar = ASAEKEventManager.shared.eventStore.defaultCalendarForNewEvents!

    let iCalendarEventCalendars:  Array<EKCalendar> = ASAEKEventManager.shared.allEventCalendars().filter({$0.allowsContentModifications})
        .sorted(by: {$0.title < $1.title})
    @State private var calendarIndex = 0
    @State private var didSetCalendarIndex = false

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    let HORIZONTAL_PADDING:  CGFloat = 20.0

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer().frame(width:  HORIZONTAL_PADDING)

                        Button("Cancel") {
                            self.showingActionSheet = true
                        }

                        Spacer()

                        Text("New Event").bold()

                        Spacer()

                        Button("Add") {
                            self.showingActionSheet = false

                            if self.title != "" {
                                let newEvent = EKEvent(eventStore: ASAEKEventManager.shared.eventStore)

                                newEvent.title = self.title

                                if self.location != "" {
                                    newEvent.location = self.location
                                }

                                newEvent.isAllDay  = self.isAllDay
                                newEvent.startDate = self.startDate
                                newEvent.endDate   = self.endDate
                                newEvent.calendar  = self.iCalendarEventCalendars[self.calendarIndex]

                                let eventStore = ASAEKEventManager.shared.eventStore

                                do {
                                    try eventStore.save(newEvent, span: .futureEvents)
                                } catch {
                                    debugPrint(#file, #function, error)
                                }
                            }

                            self.dismiss()
                        }

                        Spacer().frame(width:  HORIZONTAL_PADDING)
                    } // HStack
                } // Section

                Section {
                    TextField("Title", text: self.$title)
                    TextField("Location", text: self.$location)
                    Toggle("All Day", isOn: self.$isAllDay)
                    DatePicker("Start", selection: self.$startDate)
                    DatePicker("End", selection: self.$endDate)
                } // Section

                Section {
                    Picker(selection: self.$calendarIndex, label: HStack {
                        Text("Calendar")
                        Spacer()
                    }) {
                        ForEach(0..<self.iCalendarEventCalendars.count, id: \.self) {
                            i
                            in
                            Text(verbatim: self.iCalendarEventCalendars[i].title)
                        }
                    }
                    .onAppear() {
                        if !didSetCalendarIndex {
                            self.calendarIndex = self.iCalendarEventCalendars.firstIndex(of: ASAEKEventManager.shared.eventStore.defaultCalendarForNewEvents!) ?? 0
                            self.didSetCalendarIndex = true
                        }
                    }

                } // Section
            } // Form
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: self.$showingActionSheet) {
            ActionSheet(title: Text("Are you sure you want to delete this new event?"), buttons: [
                .destructive(Text("Cancel Changes")) { self.dismiss() },
                .default(Text("Continue Editing")) {  }
            ])
        }
    } // var body
}

struct ASANewEventView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewEKEventView()
    }
}
