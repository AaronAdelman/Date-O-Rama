//
//  ASAExternalEventManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-12.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

class ASAExternalEventManager:  NSObject, ObservableObject {
    private static var sharedEventManager: ASAExternalEventManager = {
        let eventManager = ASAExternalEventManager()
        
        return eventManager
    }()
    
    class func shared() -> ASAExternalEventManager {
        return sharedEventManager
    } // class func shared() -> ASAEventManager
    
    @Published var eventStore = EKEventStore()

    public var calendarIdentifiers:  Array<String> {
        get {
            if calendars != nil {
                return calendars!.map {$0.calendarIdentifier}
            } else {
                return []
            }
        } // get
    } // var calendarIdentifiers

    @Published var calendars: [EKCalendar]?

    public var calendarSet:  Set<EKCalendar> {
        get {
            var calendarSet = Set<EKCalendar>()
            for calendar in self.calendars! {
                calendarSet.insert(calendar)
            } // for calendar in parent.calendarArray
            return calendarSet
        }
    }
    
    override init() {
        super.init()
        
        self.requestAccessToExternalCalendars()
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil, using: {notification
            in
//            debugPrint(#file, #function, notification)
            self.objectWillChange.send()
        })
    } // init()
    
    @Published var ready:  Bool = false {
        willSet {
          objectWillChange.send()
        }
    }

    func loadExternalCalendars() {
        let externalEventCalendarIdentifiers = ASAUserData.shared().externalEventCalendarIdentifiers
        if externalEventCalendarIdentifiers.count == 0 {
            self.calendars = eventStore.calendars(for: EKEntityType.event)
        } else {
            self.reloadExternalCalendars(calendarIdentifiers: externalEventCalendarIdentifiers)
        }
//        debugPrint(#file, #function, self.calendars as Any)
    } // func loadExternalCalendars()

    func reloadExternalCalendars(calendarIdentifiers:  Array<String>) {
        var temp:  Array<EKCalendar> = []
        for identifier in calendarIdentifiers {
            let calendar = self.eventStore.calendar(withIdentifier: identifier)
            if calendar != nil {
                temp.append(calendar!)
            }
        }
        self.calendars = temp
    } // func reloadExternalCalendars(calendarIdentifiers:  Array<String>)
    
    public func requestAccessToExternalCalendars() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    debugPrint(#file, #function, "access granted")
                    self.loadExternalCalendars()
                    //                self.refreshTableView()
                    self.ready = true
                })
            } else {
                DispatchQueue.main.async(execute: {
                    //                self.needPermissionView.fadeIn()
                    debugPrint(#file, #function, "access denied")
                })
            }
        })
    } // func requestAccessToExternalCalendars()
    
    public func eventsFor(startDate:  Date, endDate: Date) -> Array<ASAEventCompatible> {
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: self.calendars)
        
        // Use the configured NSPredicate to find and return events in the store that match
        let rawEvents:  Array<EKEvent> = eventStore.events(matching: eventsPredicate)
//        let events:  Array<EKEvent> = rawEvents.sorted(by: {
//            (e1: EKEvent, e2: EKEvent) -> Bool in
//            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
//        })
//        return events
        return rawEvents
    } // func eventsFor(startDate:  Date, endDate: Date) -> Array<ASAEventCompatible>
    
} // class ASAExternalEventManager
