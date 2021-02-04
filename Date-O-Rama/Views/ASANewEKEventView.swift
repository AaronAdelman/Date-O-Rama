//
//  ASANewEKEventView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import SwiftUI

enum ASARecurrenceRule: String, Equatable, CaseIterable {
    case never    = "ASARecurrenceRule_never"
    case daily    = "ASARecurrenceRule_daily"
    case weekly   = "ASARecurrenceRule_weekly"
    case biweekly = "ASARecurrenceRule_biweekly"
    case monthly  = "ASARecurrenceRule_monthly"
    case yearly   = "ASARecurrenceRule_yearly"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)
    } // var localizedName
} // enum ASARecurrenceRule


// MARK:  -

struct ASANewEKEventView: View {
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay: Bool = false
    @State private var recurrenceRule: ASARecurrenceRule = .never

    let iCalendarEventCalendars:  Array<EKCalendar> = ASAEKEventManager.shared.allEventCalendars().filter({$0.allowsContentModifications})
        .sorted(by: {$0.title < $1.title})
    @State private var calendarIndex = 0
    @State private var didSetCalendarIndex = false

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    fileprivate var appropriateDateComponents:  DatePicker<Text>.Components {
        if self.isAllDay {
            return [.date]
        } else {
            return [.date, .hourAndMinute]
        }
    }

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

                        if self.title.count != 0 {
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
                                    switch self.recurrenceRule {
                                    case .never:
                                        newEvent.recurrenceRules = nil

                                    case .daily:
                                        let newRecurrenceRule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
                                        newEvent.addRecurrenceRule(newRecurrenceRule)

                                    case .weekly:
                                        let newRecurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
                                        newEvent.addRecurrenceRule(newRecurrenceRule)

                                    case .biweekly:
                                        let newRecurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
                                        newEvent.addRecurrenceRule(newRecurrenceRule)

                                    case .monthly:
                                        let newRecurrenceRule = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
                                        newEvent.addRecurrenceRule(newRecurrenceRule)

                                    case .yearly:
                                        let newRecurrenceRule = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
                                        newEvent.addRecurrenceRule(newRecurrenceRule)
                                    } // switch self.recurrenceRule

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
                        }

                        Spacer().frame(width:  HORIZONTAL_PADDING)
                    } // HStack
                } // Section

                Section {
                    TextField("Event Title", text: self.$title)
                    TextField("Event Location", text: self.$location)
                    Toggle("Event All Day", isOn: self.$isAllDay)
                    DatePicker("Event Start", selection: self.$startDate,
                               displayedComponents: self.appropriateDateComponents)
                        .onChange(of: startDate, perform: {
                            value
                            in
                            if self.startDate > self.endDate {
                                self.endDate = self.startDate
                            }
                        })
                    DatePicker("Event End", selection: self.$endDate,
                               displayedComponents: self.appropriateDateComponents)
                        .onChange(of: endDate, perform: {
                            value
                            in
                            if self.endDate < self.startDate {
                                self.startDate = self.endDate
                            }
                        })
                    Picker("Event Recurrence", selection: $recurrenceRule) {
                        ForEach(ASARecurrenceRule.allCases, id: \.rawValue) { value in
                            Text(value.localizedName)
                                .tag(value)
                        } // ForEach
                    } // Picker
                } // Section

                Section {
                    Picker(selection: self.$calendarIndex, label: HStack {
                        Text("Event Calendar")
                        Spacer()
                    }) {
                        ForEach(0..<self.iCalendarEventCalendars.count, id: \.self) {
                            i
                            in
                            HStack {
                                let CIRCLE_DIAMETER:  CGFloat = 8.0
                                let calendar: EKCalendar = self.iCalendarEventCalendars[i]
                                Circle()
                                    .foregroundColor(calendar.color)
                                    .frame(width: CIRCLE_DIAMETER, height: CIRCLE_DIAMETER)
                                Text(verbatim: calendar.title)
                            }
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
