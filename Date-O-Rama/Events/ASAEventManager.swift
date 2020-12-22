//
//  ASAEventManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

class ASAEventManager {
    static let eventManager = ASAEKEventManager.shared
    static let userData = ASAUserData.shared
    
    static func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible> {
        var unsortedEvents: [ASAEventCompatible] = []
        if ASAEKEventManager.shared.shouldUseEKEvents {
            let externalEvents = self.eventManager.eventsFor(startDate: startDate, endDate: endDate)
            unsortedEvents = unsortedEvents + externalEvents
        }

        for eventCalendar in userData.ASAEventCalendars {
            unsortedEvents = unsortedEvents + eventCalendar.eventDetails(startDate:  startDate, endDate:  endDate, ISOCountryCode: eventCalendar.locationData.ISOCountryCode, requestedLocaleIdentifier: eventCalendar.localeIdentifier)
        } // for eventCalendar in userData.internalEventCalendars

        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func events(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
}
