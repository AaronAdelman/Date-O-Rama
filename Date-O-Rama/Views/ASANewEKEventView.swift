//
//  ASANewEKEventView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import SwiftUI

enum ASARecurrenceType: String, Equatable, CaseIterable {
    case never    = "ASARecurrenceType_never"
    case daily    = "ASARecurrenceType_daily"
    case weekly   = "ASARecurrenceType_weekly"
    case biweekly = "ASARecurrenceType_biweekly"
    case monthly  = "ASARecurrenceType_monthly"
    case yearly   = "ASARecurrenceType_yearly"
    case custom   = "ASARecurrenceType_custom"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)
    } // var localizedName
} // enum ASARecurrenceType

enum ASARecurrenceWeekNumber: Int, Equatable, CaseIterable {
    case first  =  1
    case second =  2
    case third  =  3
    case fourth =  4
    case fifth  =  5
    case last   = -1

    var text: String {
        var rawValue = ""
        switch self {
        case .first:
            rawValue = "ASARecurrenceWeekNumber_First"
        case .second:
            rawValue = "ASARecurrenceWeekNumber_Second"
        case .third:
            rawValue = "ASARecurrenceWeekNumber_Third"
        case .fourth:
            rawValue = "ASARecurrenceWeekNumber_Fourth"
        case .fifth:
            rawValue = "ASARecurrenceWeekNumber_Fifth"
        case .last:
            rawValue = "ASARecurrenceWeekNumber_Last"
        } // switch self
        return NSLocalizedString(rawValue, comment: "")
    } // var text
} // enum ASARecurrenceWeekNumber

enum ASARecurrenceMonthly: Int, CaseIterable {
    case byDayOfMonth
    case byDayOfWeekAndWeekNumber

    var text: String {
        var rawValue = ""
        switch self {
        case .byDayOfMonth:
            rawValue = "ASARecurrenceMonthly_Every"
        case .byDayOfWeekAndWeekNumber:
            rawValue = "ASARecurrenceMonthly_On"
        } // switch self
        return NSLocalizedString(rawValue, comment: "")
    } // var text
} // enum ASARecurrenceMonthly

enum ASARecurrenceYearly: Int, CaseIterable {
    case onAnyDay
    case byDayOfWeekAndWeekNumber

    var text: String {
        var rawValue = ""
        switch self {
        case .onAnyDay:
            rawValue = "ASARecurrenceYearly_All"
        case .byDayOfWeekAndWeekNumber:
            rawValue = "ASARecurrenceYearly_On"
        } // switch self
        return NSLocalizedString(rawValue, comment: "")
    } // var text
} //


struct ASANewEKEventView: View {
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay: Bool = false
    @State private var recurrenceRule: ASARecurrenceType = .never

    // Only for custom recurrence
    @State private var type: EKRecurrenceFrequency             = .daily
    @State private var interval: Int                           = 1
    @State private var daysOfTheWeek: [EKRecurrenceDayOfWeek]? = nil
    @State private var daysOfTheMonth: [NSNumber]?             = nil
    @State private var monthsOfTheYear: [NSNumber]?            = nil
    @State private var weeksOfTheYear: [NSNumber]?             = nil
    @State private var daysOfTheYear: [NSNumber]?              = nil
    @State private var setPositions: [NSNumber]?               = nil
    @State private var recurrenceEndDate: Date?                = nil
    @State private var recurrenceOccurrenceCount: Int          = 0
    @State private var recurrenceMonthly: ASARecurrenceMonthly = .byDayOfMonth
    @State private var recurrenceDayOfTheWeek: Int             = 1
    @State private var recurrenceWeekNumber: ASARecurrenceWeekNumber               = .first
    @State private var recurrenceYearly: ASARecurrenceYearly = .onAnyDay


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

    fileprivate func addNewEvent() {
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

            case .custom:
                var end:  EKRecurrenceEnd? = nil
                if recurrenceEndDate != nil {
                    end = EKRecurrenceEnd(end: recurrenceEndDate!)
                } else if recurrenceOccurrenceCount != 0 {
                    end = EKRecurrenceEnd(occurrenceCount: recurrenceOccurrenceCount)
                }
                if type == .monthly {
                    if recurrenceMonthly == .byDayOfMonth {
                        self.daysOfTheWeek = nil
                    } else {
                        self.daysOfTheMonth = nil
                        let values:  Array<EKWeekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                        let dayOfTheWeek = EKRecurrenceDayOfWeek(dayOfTheWeek: values[self.recurrenceDayOfTheWeek - 1], weekNumber: self.recurrenceWeekNumber.rawValue)
                        self.daysOfTheWeek = [dayOfTheWeek]
                    }
                }
                if type == .yearly {
                    if recurrenceYearly == .onAnyDay {
                        self.daysOfTheWeek = nil
                    } else {
                        let values:  Array<EKWeekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                        let dayOfTheWeek = EKRecurrenceDayOfWeek(dayOfTheWeek: values[self.recurrenceDayOfTheWeek - 1], weekNumber: self.recurrenceWeekNumber.rawValue)
                        self.daysOfTheWeek = [dayOfTheWeek]
                    }
                }

                let (newRecurrenceRule) = EKRecurrenceRule(recurrenceWith: type, interval: interval, daysOfTheWeek: daysOfTheWeek, daysOfTheMonth: daysOfTheMonth, monthsOfTheYear: monthsOfTheYear, weeksOfTheYear: weeksOfTheYear, daysOfTheYear: daysOfTheYear, setPositions: setPositions, end: end)
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
    } // func addNewEvent()

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

                                addNewEvent()

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
                        ForEach(ASARecurrenceType.allCases, id: \.rawValue) { value in
                            Text(value.localizedName)
                                .tag(value)
                        } // ForEach
                    } // Picker
                    if self.recurrenceRule == .custom {
                        Picker("Event Frequency", selection:  self.$type) {
                            ForEach([EKRecurrenceFrequency.daily, EKRecurrenceFrequency.weekly, EKRecurrenceFrequency.monthly, EKRecurrenceFrequency.yearly], id: \.self) {
                                value
                                in
                                Text(value.text)
                            } // ForEach
                        } // Picker
                        .pickerStyle(SegmentedPickerStyle())

                        let GregorianCalendar: Calendar = {
                            var calendar = Calendar(identifier: .gregorian)
                            calendar.locale = Locale.current
                            return calendar
                        }()

                        switch self.type {
                        case .daily:
                            ASANewEKEventLabeledIntView(labelString: "Event Every how many days", value: self.$interval)

                        case .weekly:
                            ASANewEKEventLabeledIntView(labelString: "Event Every how many weeks", value: self.$interval)
                            let symbols: [String] = GregorianCalendar.standaloneWeekdaySymbols
                            let values:  Array<EKWeekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                            ForEach(0..<values.count) {
                                i
                                in
                                let weekday: EKWeekday = values[i]
                                let recurringWeekday: EKRecurrenceDayOfWeek = EKRecurrenceDayOfWeek(weekday)
                                HStack {
                                    Button(action: {
                                        if daysOfTheWeek == nil {
                                            daysOfTheWeek = [recurringWeekday]
                                        } else if daysOfTheWeek!.contains(recurringWeekday) {
                                            daysOfTheWeek!.remove(recurringWeekday)
                                        } else {
                                            daysOfTheWeek!.append(recurringWeekday)
                                        }
                                    }) {
                                        ASANewEventBulletedLabel(text: symbols[i])
                                    }
                                    Spacer()
                                    if daysOfTheWeek?.contains(recurringWeekday) ?? false {
                                        ASACheckmarkSymbol()
                                    }
                                } // HStack
                            } // ForEach

                        case .monthly:
                            ASANewEKEventLabeledIntView(labelString: "Event Every how many months", value: self.$interval)

                            Picker("Monthly recurrence", selection: self.$recurrenceMonthly) {
                                ForEach(ASARecurrenceMonthly.allCases, id: \.rawValue) { value in
                                    Text(value.text)
                                        .tag(value)
                                } // ForEach
                            }
                            .pickerStyle(SegmentedPickerStyle())

                            if self.recurrenceMonthly == .byDayOfMonth {
                                let DAYS_PER_MONTH = 31
                                let values:  Array<Int> = Array(1...DAYS_PER_MONTH)
                                ForEach(0..<values.count) {
                                    i
                                    in
                                    let day: Int = values[i]
                                    let recurringDay: NSNumber = NSNumber(value: day)
                                    HStack {
                                        Button(action: {
                                            if daysOfTheMonth == nil {
                                                daysOfTheMonth = [recurringDay]
                                            } else if daysOfTheMonth!.contains(recurringDay) {
                                                daysOfTheMonth!.remove(recurringDay)
                                            } else {
                                                daysOfTheMonth!.append(recurringDay)
                                            }
                                        }) {
                                            ASANewEventBulletedLabel(text: "\(values[i])")
                                        }
                                        Spacer()
                                        if daysOfTheMonth?.contains(recurringDay) ?? false {
                                            ASACheckmarkSymbol()
                                        }
                                    } // HStack
                                } // ForEach
                            }

                            if self.recurrenceMonthly == .byDayOfWeekAndWeekNumber {
                                ASADayOfWeekAndWeekNumberPicker(GregorianCalendar: GregorianCalendar, recurrenceDayOfTheWeek: self.$recurrenceDayOfTheWeek, recurrenceWeekNumber: self.$recurrenceWeekNumber)
                            }

                        case .yearly:
                            ASANewEKEventLabeledIntView(labelString: "Event Every how many years", value: self.$interval)
                            let symbols: [String] = GregorianCalendar.standaloneMonthSymbols
                            let MONTHS_PER_YEAR = 12
                            let values:  Array<Int> = Array(1...MONTHS_PER_YEAR)
                            ForEach(0..<values.count) {
                                i
                                in
                                let month: Int = values[i]
                                let recurringMonth: NSNumber = NSNumber(value: month)
                                HStack {
                                    Button(action: {
                                        if monthsOfTheYear == nil {
                                            monthsOfTheYear = [recurringMonth]
                                        } else if monthsOfTheYear!.contains(recurringMonth) {
                                            monthsOfTheYear!.remove(recurringMonth)
                                        } else {
                                            monthsOfTheYear!.append(recurringMonth)
                                        }
                                    }) {
                                        ASANewEventBulletedLabel(text: symbols[i])
                                    }
                                    Spacer()
                                    if monthsOfTheYear?.contains(recurringMonth) ?? false {
                                        ASACheckmarkSymbol()
                                    }
                                } // HStack
                            } // ForEach
                            Picker("Yearly recurrence", selection: self.$recurrenceYearly) {
                                ForEach(ASARecurrenceYearly.allCases, id: \.rawValue) { value in
                                    Text(value.text)
                                        .tag(value)
                                } // ForEach
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if self.recurrenceYearly == .byDayOfWeekAndWeekNumber {
                                ASADayOfWeekAndWeekNumberPicker(GregorianCalendar: GregorianCalendar, recurrenceDayOfTheWeek: self.$recurrenceDayOfTheWeek, recurrenceWeekNumber: self.$recurrenceWeekNumber)
                            }

                        @unknown default:
                            Text("Unknown default")
                        } // switch self.type
                    } // if self.recurrenceRule == .custom
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
} // struct ASANewEKEventView


// MARK:  -

struct ASADayOfWeekAndWeekNumberPicker: View {
    var GregorianCalendar: Calendar
    @Binding var recurrenceDayOfTheWeek: Int
    @Binding var recurrenceWeekNumber: ASARecurrenceWeekNumber

    var body: some View {
        let symbols: [String] = GregorianCalendar.shortStandaloneWeekdaySymbols
        Picker(selection: self.$recurrenceDayOfTheWeek, label: Text("Day of week")) {
            ForEach(1 ... 7, id: \.self) {
                Text(verbatim: symbols[$0 - 1]).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())

        Picker("Week number", selection: $recurrenceWeekNumber) {
            ForEach(ASARecurrenceWeekNumber.allCases, id: \.rawValue) { value in
                Text(value.text)
                    .tag(value)
            } // ForEach
        } // Picker
        .pickerStyle(SegmentedPickerStyle())
    }
}


// MARK:  -

struct ASANewEventBulletedLabel:  View {
    var text: String

    var body: some View {
        HStack {
            Text("•")
            Text(text)
        }
    }
}


// MARK:  -

struct ASANewEKEventLabeledIntView: View {
    var labelString: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(NSLocalizedString(labelString, comment: ""))
            TextField("", value: $value, formatter: NumberFormatter())
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        } // HStack

    }
}


// MARK:  -

struct ASANewEventView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewEKEventView()
    }
}
