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
    var labelColor          = Color(UIColor.label)
    var secondaryLabelColor = Color(UIColor.secondaryLabel)
    #endif
    
    let GregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        return calendar
    }()
    
    var body: some View {
        List {
            Section {
                Text(event.title)
                    .font(.title)
                if event.location != nil {
                    Text(event.location!)
                }
                HStack {
                    ASAEventColorRectangle(color: event.color)
                    Text(event.calendarTitleWithLocation)
                } // HStack
            } // Section
            
            Section {
                let (startDateString, endDateString) = row.startAndEndDateStrings(event: event, isPrimaryRow: true, eventIsTodayOnly: false)
                if startDateString == endDateString {
                    Text(startDateString)
                } else {
                    Text(startDateString + " — " + endDateString)
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
                    if eventAsEKEvent.hasRecurrenceRules {
                        let numberOfRecurrenceRules = eventAsEKEvent.recurrenceRules!.count
                        ForEach(0..<numberOfRecurrenceRules, id: \.self) {
                            i
                            in
                            let recurrenceRule = eventAsEKEvent.recurrenceRules![i]
                            
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
                    }
                }
            } // Section
            
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
            
            Section {
                if event.hasNotes {
                    Text(event.notes!)
                }
                
                let eventURL = event.url
                if eventURL != nil {
                    if eventURL!.absoluteString.hasPrefix(CONTACTS_PREFIX) {
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
                }
            } // Section
            
            Section {
                let geoLocation = event.geoLocation
                if geoLocation != nil {
                    Map(coordinateRegion: .constant(region), interactionModes: [.zoom])
                        .aspectRatio(1.0, contentMode: .fit)
                }
            } // Section
            
            Section {
                let currentUser: EKParticipant? = event.currentUser
                if currentUser != nil {
                    let status = currentUser!.participantStatus
                    HStack {
                        Text("My status")
                        Image(systemName: status.systemName)
                            .foregroundColor(status.color)
                        Text(status.text)
                    } // HStack
                }
            } // Section
        } // List
        .foregroundColor(labelColor)
        .onAppear() {
            let geoLocation: CLLocation? = event.geoLocation
            if geoLocation != nil {
                let meters = 1000.0
                self.region = MKCoordinateRegion(center: geoLocation!.coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
            }
        }
    } // body
} // struct ASAEventDetailView


struct ASAEventPropertyView: View {
    var key: String
    var value: String
    
    var body: some View {
        HStack {
            Text(NSLocalizedString(key, comment: ""))
                .bold()
            Spacer()
            Text(value)
        } // HStack
    }
}


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
                Text(participant.name ?? "???")
            }
            if participant.participantRole == .chair {
                Text("EKParticipantRole.chair")
            }
            if participant.participantRole == .optional {
                Text("EKParticipantRole.optional")
            }
        } // HStack
    } // var body
} // struct ASAEKParticipantView


struct ASAEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventDetailView(event: ASAEvent(eventIdentifier: "Foo", title: "Foo", location: "Fooland", startDate: Date(), endDate: Date(), isAllDay: true, timeZone: TimeZone.current, color: .blue, uuid: UUID(), calendarTitleWithLocation: "Foo • Fooland", calendarTitleWithoutLocation: "Foo", isEKEvent: false, calendarCode: .Gregorian, locationData: ASALocation.NullIsland), row: ASARow.generic)
    }
}
