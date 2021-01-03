//
//  ASAEKEventManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-12.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

class ASAEKEventManager:  NSObject, ObservableObject {
    private static var sharedEventManager: ASAEKEventManager = {
        let eventManager = ASAEKEventManager()
        
        return eventManager
    }()
    
    static var shared:  ASAEKEventManager {
        return sharedEventManager
    } // static var shared
    
    @Published var eventStore = EKEventStore()

//    public var titles:  Array<String> {
//        get {
//            if calendars != nil {
//                return calendars!.map {$0.title}
//            } else {
//                return []
//            }
//        } // get
//    } // var titles

//    @Published var calendars: [EKCalendar]?

//    public var calendarSet:  Set<EKCalendar> {
//        get {
//            var calendarSet = Set<EKCalendar>()
//            for calendar in self.calendars! {
//                calendarSet.insert(calendar)
//            } // for calendar in parent.calendarArray
//            return calendarSet
//        } // get
//    } // var calendarSet

    @AppStorage("USE_EXTERNAL_EVENTS") var shouldUseEKEvents: Bool = true

    @Published var userHasPermission:  Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    override init() {
        super.init()
        
        self.requestAccessToEKCalendars()
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil, using: {
            notification
            in
            debugPrint(#file, #function, notification)
            self.requestAccessToEKCalendars()

            self.objectWillChange.send()
        })
    } // init()
    
    @Published var ready:  Bool = false {
        willSet {
          objectWillChange.send()
        }
    }

//    func loadEKCalendars() {
//        let EKCalendarTitles = ASAUserData.shared.EKCalendarTitles
//        if EKCalendarTitles.count == 0 {
//            self.calendars = eventStore.calendars(for: EKEntityType.event)
//        } else {
//            self.reloadEKCalendars(titles: EKCalendarTitles)
//        }
//        debugPrint(#file, #function, self.calendars as Any)
//    } // func loadExternalCalendars()

    public func allEventCalendars() -> [EKCalendar] {
        return self.eventStore.calendars(for: .event)
    }

    func EKCalendars(titles:  Array<String>?) -> Array<EKCalendar> {
        if titles == nil {
            return ASAEKEventManager.shared.eventStore.calendars(for: EKEntityType.event)
        } else {
            var temp:  Array<EKCalendar> = []
            for title in titles! {
                let calendar = allEventCalendars().first(where: {$0.title == title})
                if calendar != nil {
                    temp.append(calendar!)
                }
            } // for title in titles
            return temp
        }
    } // static func EKCalendars(titles:  Array<String>?) -> Array<EKCalendar>

//    func reloadEKCalendars(titles:  Array<String>) {
//        var temp:  Array<EKCalendar> = []
//        for title in titles {
//            let calendar = self.eventStore.calendars(for: .event).first(where: {$0.title == title})
//            if calendar != nil {
//                temp.append(calendar!)
//            }
//        }
//        self.calendars = temp
//    } // func reloadEKCalendars(titles:  Array<String>)
    
    fileprivate func handleAccessGranted() {
        DispatchQueue.main.async(execute: {
            debugPrint(#file, #function, "access granted")
            self.userHasPermission = true
//            self.loadEKCalendars()

            self.ready = true
        })
    }

    fileprivate func handleAccessDenied() {
        DispatchQueue.main.async(execute: {
            //                self.needPermissionView.fadeIn()
            debugPrint(#file, #function, "access denied")
            self.userHasPermission = false
            self.shouldUseEKEvents = false
            self.ready = true
        })
    }

    public func requestAccessToEKCalendars() {
        switch EKEventStore.authorizationStatus(for: .event) {

        case .authorized:
            debugPrint(#file, #function, "Authorized")
            self.handleAccessGranted()

        case .denied:
            debugPrint(#file, #function, "Access denied")
            self.handleAccessDenied()

        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                                        {(granted: Bool, error: Error?) -> Void in
                                            if granted {
                                                debugPrint(#file, #function, "Access granted")
                                                self.handleAccessGranted()
                                            } else {
                                                debugPrint(#file, #function, "Access denied")
                                                self.handleAccessDenied()
                                            }
                                        })

            debugPrint(#file, #function, "Not Determined")
        default:
            debugPrint(#file, #function, "Case Default")
        }


        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                self.handleAccessGranted()
            } else {
                self.handleAccessDenied()
            }
        })
    } // func requestAccessToEKCalendars()
    
//    public func eventsFor(startDate:  Date, endDate: Date) -> Array<ASAEventCompatible> {
//        // Use an event store instance to create and properly configure an NSPredicate
//        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: self.calendars)
//
//        // Use the configured NSPredicate to find and return events in the store that match
//        let rawEvents:  Array<EKEvent> = eventStore.events(matching: eventsPredicate)
//        return rawEvents
//    } // func eventsFor(startDate:  Date, endDate: Date) -> Array<ASAEventCompatible>

    public func eventsFor(startDate:  Date, endDate: Date, calendars:  Array<EKCalendar>) -> Array<ASAEventCompatible> {
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)

        // Use the configured NSPredicate to find and return events in the store that match
        let rawEvents:  Array<EKEvent> = eventStore.events(matching: eventsPredicate)
        return rawEvents
    } // func eventsFor(startDate:  Date, endDate: Date, calendars:  Array<EKCalendar>) -> Array<ASAEventCompatible>
} // class ASAEKEventManager
