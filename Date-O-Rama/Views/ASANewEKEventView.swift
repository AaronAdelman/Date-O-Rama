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
    @State private var calendar: EKCalendar = ASAEKEventManager.shared.eventStore.defaultCalendarForNewEvents!

    var iCalendarEventCalendars:  Array<EKCalendar> = ASAEKEventManager.shared.allEventCalendars().sorted(by: {$0.title < $1.title})

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
                            
                            let newEvent = EKEvent(eventStore: ASAEKEventManager.shared.eventStore)

                            if self.title != "" {
                                newEvent.title = self.title
                            }

                            if self.location != "" {
                                newEvent.location = self.location
                            }

                            newEvent.isAllDay  = self.isAllDay
                            newEvent.startDate = self.startDate
                            newEvent.endDate   = self.endDate
                            newEvent.calendar  = self.calendar

                            do {
                                try ASAEKEventManager.shared.eventStore.save(newEvent, span: .futureEvents)
                            } catch {
                                debugPrint(#file, #function, error)
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
                    Picker(selection: self.$calendar, label: HStack {
                        Text("Calendar")
                        Text(self.calendar.title)
                    }) {
                        ForEach(self.iCalendarEventCalendars, id: \.calendarIdentifier) {
                            Text(verbatim: $0.title)
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
