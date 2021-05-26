//
//  ASAEventDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI
import MapKit
import EventKit
import Contacts

let CONTACTS_PREFIX = "addressbook://"
let OPEN_IN_CONTACTS_STRING = "Open in Contacts"

struct ASAEventDetailView: View {
    var event: ASAEventCompatible
    var row:  ASARow
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    
    #if os(watchOS)
    let labelColor          = Color.white
    let secondaryLabelColor = Color(UIColor.lightGray)
    #else
    var labelColor          = Color.primary
    var secondaryLabelColor = Color.secondary
    #endif
    
    @State var showingEventEditView = false
        
    var body: some View {
        List {
            #if os(watchOS)
            #else
            if event.isEKEvent && !event.isReadOnly {
                let eventAsEKEvent = event as! EKEvent

                HStack {
                    Spacer()
                    
                    ASAEditExternalEventButton(event: eventAsEKEvent)
                } // HStack
            }
            #endif

            Section {
                #if os(watchOS)
                let titleFont: Font = .headline
                #else
                let titleFont: Font = .title
                #endif
                Text(event.title)
                    .font(titleFont)
                if event.location != nil {
                    Text(event.location!)
                }
                HStack {
                    ASAEventColorRectangle(color: event.color)
                    Text(event.calendarTitleWithLocation)
                } // HStack
            } // Section

            ASAEventDetailDateTimeSection(row: row, event: event)

            Section {
                if event.hasAlarms {
                    let numberOfAlarms = event.alarms?.count ?? 0
                    ForEach(0..<numberOfAlarms, id: \.self) {
                        i
                        in
                        let alarm = event.alarms![i]

                        ASAEventAlarmView(alarm: alarm, row: row)
                    } // ForEach(0..<numberOfAlarms, id: \.self)
                }

                if event.availability != .notSupported {
                    ASAEventPropertyView(key: "Event availability", value: event.availability.text)
                }
            } // Section

            ASAEKEventParticipantsAndStatusSection(event: event)

            ASAEventDetailsNotesAndURLSection(event: event)

            #if os(watchOS)
            #else
            Section {
                let geoLocation = event.geoLocation
                if geoLocation != nil {
                    Map(coordinateRegion: .constant(region), interactionModes: [.zoom])
                        .aspectRatio(1.0, contentMode: .fit)
                }
            } // Section
            #endif

            Section {
                let currentUser: EKParticipant? = event.currentUser
                if currentUser != nil {
                    let status = currentUser!.participantStatus
                    HStack {
                        Text("My status")
                            .foregroundColor(Color.secondary)
                        Spacer()
                        Image(systemName: status.systemName)
                            .foregroundColor(status.color)
                        Text(status.text)
                    } // HStack
                }
            } // Section
        } // List
        .foregroundColor(labelColor)
        .onAppear() {
            #if os(watchOS)
            #else
            let geoLocation: CLLocation? = event.geoLocation
            if geoLocation != nil {
                let meters = 1000.0
                self.region = MKCoordinateRegion(center: geoLocation!.coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
            }
            #endif
        }
    } // body
} // struct ASAEventDetailView


// MARK:  -

struct ASAEventDetailsNotesAndURLSection: View {
    var event: ASAEventCompatible
    
    var body: some View {
        Section {
            if event.hasNotes {
                Text(event.notes!)
            }
            
            let eventURL = event.url
            if eventURL != nil {
                let absoluteURLString = eventURL!.absoluteString
                #if os(watchOS)
                Text(absoluteURLString)
                #else
                if absoluteURLString.hasPrefix(CONTACTS_PREFIX) {
                    Button(action: {
                        UIApplication.shared.open(eventURL!, options: [:], completionHandler: nil)
                    }, label: {
                        Text(NSLocalizedString(OPEN_IN_CONTACTS_STRING, comment: ""))
                            .underline()
                            .foregroundColor(.accentColor)
                    })
                } else {
                    Link(destination: event.url!, label: {
                        Text(event.url!.absoluteString)
                            .underline()
                            .foregroundColor(.accentColor)
                    })
                }
                #endif
            }
        } // Section
    } // var body
} // struct ASAEventDetailsNotesAndURLSection


// MARK:  -

struct ASAEKEventParticipantsAndStatusSection: View {
    var event: ASAEventCompatible
    
    var body: some View {
        Section {
            if event.hasParticipants {
                VStack(alignment: .leading) {
                    ForEach(event.participants!, id: \.url) {
                        attendee
                        in
                        ASAEKParticipantView(participant: attendee)
                    }
                }
            }
            
            if event.status != .none && event.status != .confirmed {
                Text(event.status.text)
                    .foregroundColor(event.status.color)
            }
        } // Section
    } // var body
} // struct ASAEKEventParticipantsAndStatusSection


// MARK:  -

struct ASAEKEventRecurrenceFrequencyView: View {
    var recurrenceRule: EKRecurrenceRule
    
    let GregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()
    
    var body: some View {
        let frequency = recurrenceRule.frequency
        let interval = recurrenceRule.interval
        ASAEventPropertyView(key: "Event Frequency", value: frequency.text)
        switch frequency {
        case .daily:
            ASAEventPropertyView(key: "Event Every how many days", value: "\(interval)")

        case .weekly:
            ASAEventPropertyView(key: "Event Every how many weeks", value: "\(interval)")
            let firstDayOfTheWeek = recurrenceRule.firstDayOfTheWeek
            let firstDayOfTheWeekString = GregorianCalendar.standaloneWeekdaySymbols[firstDayOfTheWeek - 1]
            ASAEventPropertyView(key: "First day of the week for recurrence", value: firstDayOfTheWeekString)

        case .monthly:
            ASAEventPropertyView(key: "Event Every how many months", value: "\(interval)")

        case .yearly:
            ASAEventPropertyView(key: "Event Every how many years", value: "\(interval)")

        @unknown default:
            ASAEventPropertyView(key: "Event Every how many units", value: "\(interval)")
        } // switch frequency
    }
}


// MARK:  -

struct ASAEKEventRecurrenceRulesForEach: View {
    var eventAsEKEvent: EKEvent
    var row: ASARow

    let GregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()

    var body: some View {
        let numberOfRecurrenceRules = eventAsEKEvent.recurrenceRules?.count ?? 0
        ForEach(0..<numberOfRecurrenceRules, id: \.self) {
            i
            in
            let recurrenceRule = eventAsEKEvent.recurrenceRules![i]

            ASAEKEventRecurrenceFrequencyView(recurrenceRule: recurrenceRule)

            if recurrenceRule.daysOfTheWeek != nil {
                let daysOfTheWeekStrings = recurrenceRule.daysOfTheWeek!.map {
                    $0.localizedString(calendar: GregorianCalendar)
                }
                let joined = ListFormatter.localizedString(byJoining: daysOfTheWeekStrings)
                ASAEventPropertyView(key: "Event days of the week", value: joined)
            }

            if recurrenceRule.daysOfTheMonth != nil {
                let daysOfTheMonthStrings = recurrenceRule.daysOfTheMonth!.map {
                    "\($0)"
                }
                let joined = ListFormatter.localizedString(byJoining: daysOfTheMonthStrings)
                ASAEventPropertyView(key: "Event days of the month", value: joined)
            }

            if recurrenceRule.daysOfTheYear != nil {
                let daysOfTheYearStrings = recurrenceRule.daysOfTheYear!.map {
                    "\($0.intValue)"
                }
                let joined = ListFormatter.localizedString(byJoining: daysOfTheYearStrings)
                ASAEventPropertyView(key: "Event days of the year", value: joined)
            }

            if recurrenceRule.weeksOfTheYear != nil {
                let weeksOfTheYearStrings = recurrenceRule.weeksOfTheYear!.map {
                    ($0.intValue > 0) ? "\($0.intValue)" : String(format: NSLocalizedString("%i (from the end)", comment: ""), $0.intValue)
                }
                let joined = ListFormatter.localizedString(byJoining: weeksOfTheYearStrings)
                ASAEventPropertyView(key: "Event weeks of the year", value: joined)
            }

            if recurrenceRule.monthsOfTheYear != nil {
                let monthsOfTheYearStrings = recurrenceRule.monthsOfTheYear!.map {
                    $0.monthSymbol(calendar: GregorianCalendar)
                }
                let joined = ListFormatter.localizedString(byJoining: monthsOfTheYearStrings)
                ASAEventPropertyView(key: "Event months of the year", value: joined)
            }

            if recurrenceRule.setPositions != nil {
                let setPositionsStrings = recurrenceRule.setPositions!.map {
                    ($0.intValue > 0) ? "\($0.intValue)" : String(format: NSLocalizedString("%i (from the end)", comment: ""), $0.intValue)
                }
                let joined = ListFormatter.localizedString(byJoining: setPositionsStrings)
                ASAEventPropertyView(key: "Event set positions", value: joined)
            }

            let recurrenceEnd = recurrenceRule.recurrenceEnd
            if recurrenceEnd != nil {
                let occurrenceCount = recurrenceEnd!.occurrenceCount
                if occurrenceCount == 0 {
                    // Date-based
                    ASAEventPropertyView(key: "Event Recurrence end date", value: row.dateTimeString(now:  recurrenceEnd!.endDate!))
                } else {
                    ASAEventPropertyView(key: "Event Recurrence count", value: "\(occurrenceCount)")
                }
            }
        } // ForEach(0..<numberOfRecurrenceRules, id: \.self)
    } // var body
} // struct ASAEKEventRecurrenceRulesForEach


// MARK:  -

struct ASAEventDetailDateTimeSection: View {
    var row: ASARow
    var event: ASAEventCompatible

    func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .long
        if self.event.timeZone != nil {
            dateFormatter.timeZone  = self.event.timeZone!
        }
        return dateFormatter
    } // func dateFormatter() -> DateFormatter

    var body: some View {
        Section {
            let (startDateString, endDateString) = row.longStartAndEndDateStrings(event: event, isPrimaryRow: true, eventIsTodayOnly: false)

            if event.startDate == event.endDate || startDateString == endDateString {
                Text(startDateString)
                if !(row.isGregorian && row.locationData.timeZone.isCurrent) {
                    Text(dateFormatter().string(from: event.startDate))
                }
            } else {
                let DASH = " — "
                Text(startDateString + DASH + endDateString)
                if !(row.isGregorian && row.locationData.timeZone.isCurrent) {
                    let dateFormatter = dateFormatter()
                    let startDateString = dateFormatter.string(from: event.startDate)
                    let endDateString = dateFormatter.string(from: event.endDate)

                    Text(startDateString + DASH + endDateString)
                }
            }

            if event.timeZone != nil {
                let timeZone = event.timeZone!
                let now = Date()
                HStack {
                    Text(verbatim:  timeZone.abbreviation(for:  now) ?? "")
                    Text("•")
                    Text(verbatim:  timeZone.localizedName(for: now))
                } // HStack
            }

            if event.isEKEvent {
                let eventAsEKEvent = event as! EKEvent
                ASAEKEventRecurrenceRulesForEach(eventAsEKEvent: eventAsEKEvent, row: row)
            }
        } // Section
    } // var body
} // struct ASAEventDetailDateTimeSection


// MARK:  -

struct ASAEventAlarmView: View {
    var alarm: EKAlarm
    var row: ASARow
    
    func value() -> String {
//        var strings: Array<String> = []
        
        if alarm.absoluteDate != nil {
            let absoluteDateString: String = row.dateTimeString(now:  alarm.absoluteDate!)
//            strings.append(absoluteDateString)
            return absoluteDateString
        } else {
            let offset = abs(alarm.relativeOffset)
            let before = (alarm.relativeOffset <= 0)
            let formattedOffset = offset.formatted ?? ""
            let format = before ? "%@ before" : "%@ after"
            let localizedFormat = NSLocalizedString(format, comment: "")
            let filledInFormat: String = String(format: localizedFormat, formattedOffset)
//            strings.append(filledInFormat)
            return filledInFormat
        }
                
//        let joined = ListFormatter.localizedString(byJoining: strings)
//        return joined
    }
    
    var body: some View {
        ASAEventPropertyView(key: "Event alarm", value: self.value())
    }
}


// MARK:  -

struct ASAEventPropertyView: View {
    var key: String
    var value: String
    
    var body: some View {
        HStack {
            Text(NSLocalizedString(key, comment: ""))
                .foregroundColor(Color.secondary)
            Spacer()
            Text(value)
        } // HStack
    }
}


// MARK:  -

struct ASAEKParticipantView: View {
    var participant: EKParticipant
    
    // Based on https://stackoverflow.com/questions/42393384/swift-using-contacts-framework-search-using-identifier-to-match and https://stackoverflow.com/questions/42393384/swift-using-contacts-framework-search-using-identifier-to-match
    func contactWithPredicate(predicate: NSPredicate) -> CNContact? {
        let contactsStore = CNContactStore()

        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .restricted:
                print("User cannot grant permission, e.g. parental controls in force.")
//                exit(1)
        return nil
        case .denied:
                print("User has explicitly denied permission.")
                print("They have to grant it via Preferences app if they change their mind.")
//                exit(1)
            return nil
        case .notDetermined:
                print("You need to request authorization via the API now.")
        case .authorized:
                print("You are already authorized.")
        @unknown default:
            return nil
        } // switch authStatus

        if authorizationStatus == .notDetermined {
            contactsStore.requestAccess(for: .contacts) { success, error in
                if !success {
                    print("Not authorized to access contacts. Error = \(String(describing: error))")
//                    exit(1)
                }
                print("Authorized!")
            }
        }
        
        let keys = [CNContactIdentifierKey, CNContactPhoneNumbersKey]

             var contacts = [CNContact]()
//             var message: String!


             do {
                contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keys as Array<CNKeyDescriptor>)

                 if contacts.count == 0 {
//                     message = "No contacts were found matching the given name."
                    return nil
                 }
             }
             catch {
//                 message = "Unable to fetch contacts."
                return nil
             }

              return contacts[0]
         } // func contactWithPredicate(predicate: NSPredicate) -> CNContact?

    var body: some View {
        HStack {
            let status: EKParticipantStatus = participant.participantStatus
            let contact = self.contactWithPredicate(predicate: participant.contactPredicate)
            
            Image(systemName: status.systemName)
                .foregroundColor(status.color)
            let name: String = participant.name ?? "???"
            #if os(watchOS)
            Text(name)
            #else
            Menu {
                
                Text(participant.EMailAddress)
                
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = participant.EMailAddress
                }, label: {
                    Text("Copy available address")
                })
                
                if contact != nil {
                    let contactURL = URL(string: CONTACTS_PREFIX + contact!.identifier)
                    if contactURL != nil {
                        Button(action: {
                            UIApplication.shared.open(contactURL!, options: [:], completionHandler: nil)
                        }, label: {
                            Text(NSLocalizedString(OPEN_IN_CONTACTS_STRING, comment: ""))
                        })
                    }
                    
                    Button(action: {
                        UIApplication.shared.open(participant.url, options: [:], completionHandler: nil)
                    }, label: {
                        Text("Send E-mail")
                    })
                    
                    #if os(iOS)
                    #if targetEnvironment(macCatalyst)
                    
                    #else
                    ForEach(contact!.phoneNumbers, id:\.self) {
                        labeledPhoneNumber
                        in
                        let phoneNumber: String = labeledPhoneNumber.value.stringValue
                        let phoneNumberURLString: String = "tel://" + phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")

                        Button(action: {
                            UIApplication.shared.open(URL(string: phoneNumberURLString)!, options: [:], completionHandler: nil)
                        }, label: {
                            HStack {
                                Image(systemName: "phone.circle.fill")
                                Text(CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: labeledPhoneNumber.label!) + " " + phoneNumber)
                            } // HStack
                        })
                    } // ForEach
                    #endif
                    #endif
                }
                
            } label: {
                Text(name)
            }
            #endif
            if participant.participantRole == .chair {
                Text("EKParticipantRole.chair")
            }
            if participant.participantRole == .optional {
                Text("EKParticipantRole.optional")
            }
        } // HStack
    } // var body
} // struct ASAEKParticipantView


// MARK:  -

struct ASAEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventDetailView(event: ASAEvent(eventIdentifier: "Foo", title: "Foo", location: "Fooland", startDate: Date(), endDate: Date(), isAllDay: true, timeZone: TimeZone.current, color: .blue, uuid: UUID(), calendarTitleWithLocation: "Foo • Fooland", calendarTitleWithoutLocation: "Foo", isEKEvent: false, calendarCode: .Gregorian, locationData: ASALocation.NullIsland), row: ASARow.generic)
    }
}
