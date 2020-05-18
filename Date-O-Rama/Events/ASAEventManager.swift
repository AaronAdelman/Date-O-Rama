//
//  ASAEventManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-12.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

class ASAEventManager:  NSObject, ObservableObject {
    private static var sharedEventManager: ASAEventManager = {
        let eventManager = ASAEventManager()
        
        return eventManager
    }()
    
    class func shared() -> ASAEventManager {
        return sharedEventManager
    } // class func shared() -> ASAEventManager
    
    let eventStore = EKEventStore()
    @Published var calendars: [EKCalendar]?
    
    override init() {
        super.init()
    } // init()
    
    @Published var ready:  Bool = false {
        willSet {
          objectWillChange.send()
        }
    }

    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
//        debugPrint(#file, #function, self.calendars as Any)
    } // func loadCalendars()
    
    public func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    debugPrint(#file, #function, "access granted")
                    self.loadCalendars()
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
    } // func requestAccessToCalendar()
    
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
    
} // class ASAEventManager
