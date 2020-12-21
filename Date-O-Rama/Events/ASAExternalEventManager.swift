//
//  ASAExternalEventManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-12.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

class ASAExternalEventManager:  NSObject, ObservableObject {
    private static var sharedEventManager: ASAExternalEventManager = {
        let eventManager = ASAExternalEventManager()
        
        return eventManager
    }()
    
    static var shared:  ASAExternalEventManager {
        return sharedEventManager
    } // class func shared() -> ASAEventManager
    
    @Published var eventStore = EKEventStore()

    public var titles:  Array<String> {
        get {
            if calendars != nil {
                return calendars!.map {$0.title}
            } else {
                return []
            }
        } // get
    } // var titles

    @Published var calendars: [EKCalendar]?

    public var calendarSet:  Set<EKCalendar> {
        get {
            var calendarSet = Set<EKCalendar>()
            for calendar in self.calendars! {
                calendarSet.insert(calendar)
            } // for calendar in parent.calendarArray
            return calendarSet
        } // get
    } // var calendarSet

    @AppStorage("USE_EXTERNAL_EVENTS") var shouldUseExternalEvents: Bool = true

    @Published var userHasPermission:  Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    override init() {
        super.init()
        
        self.requestAccessToExternalCalendars()
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil, using: {
            notification
            in
            debugPrint(#file, #function, notification)
            self.requestAccessToExternalCalendars()

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
            self.reloadExternalCalendars(titles: externalEventCalendarIdentifiers)
        }
//        debugPrint(#file, #function, self.calendars as Any)
    } // func loadExternalCalendars()

    func reloadExternalCalendars(titles:  Array<String>) {
        var temp:  Array<EKCalendar> = []
        for title in titles {
            let calendar = self.eventStore.calendars(for: .event).first(where: {$0.title == title})
            if calendar != nil {
                temp.append(calendar!)
            }
        }
        self.calendars = temp
    } // func reloadExternalCalendars(titles:  Array<String>)
    
    fileprivate func handleAccessGranted() {
        DispatchQueue.main.async(execute: {
            debugPrint(#file, #function, "access granted")
            self.userHasPermission = true
            self.loadExternalCalendars()

            self.ready = true
        })
    }

    fileprivate func handleAccessDenied() {
        DispatchQueue.main.async(execute: {
            //                self.needPermissionView.fadeIn()
            debugPrint(#file, #function, "access denied")
            self.userHasPermission = false
            self.shouldUseExternalEvents = false
            self.ready = true
        })
    }

    public func requestAccessToExternalCalendars() {
        switch EKEventStore.authorizationStatus(for: .event) {

        case .authorized:
            print("Authorized")
            self.handleAccessGranted()

        case .denied:
            print("Access denied")
            self.handleAccessDenied()

        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                                        {(granted: Bool, error: Error?) -> Void in
                                            if granted {
                                                print("Access granted")
                                                self.handleAccessGranted()
                                            } else {
                                                print("Access denied")
                                                self.handleAccessDenied()
                                            }
                                        })

            print("Not Determined")
        default:
            print("Case Default")
        }


        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                self.handleAccessGranted()
            } else {
                self.handleAccessDenied()
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
