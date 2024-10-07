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
    @MainActor static let shared = ASAEKEventManager()
    
    @Published var eventStore = EKEventStore()
    
    @Published var shouldUseEKEvents: Bool = true
    
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
//            debugPrint(#file, #function, notification)
            self.requestAccessToEKCalendars()
            
            self.objectWillChange.send()
        })
    } // init()
    
    @Published var ready:  Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
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
    
    fileprivate func handleAccessGranted() {
        DispatchQueue.main.async(execute: {
//            debugPrint(#file, #function, "access granted")
            self.userHasPermission = true
            self.shouldUseEKEvents = true
            self.ready = true
        })
    }
    
    fileprivate func handleAccessDenied() {
        DispatchQueue.main.async(execute: {
            //                self.needPermissionView.fadeIn()
//            debugPrint(#file, #function, "access denied")
            self.userHasPermission = false
            self.shouldUseEKEvents = false
            self.ready = true
        })
    }
    
    public func requestAccessToEKCalendars() {
        switch EKEventStore.authorizationStatus(for: .event) {
        
        case .authorized:
//            debugPrint(#file, #function, "Authorized")
            self.handleAccessGranted()
            
        case .denied:
            debugPrint(#file, #function, "Access denied")
            self.handleAccessDenied()
            
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                                        {(granted: Bool, error: Error?) -> Void in
                                            if granted {
//                                                debugPrint(#file, #function, "Access granted")
                                                self.handleAccessGranted()
                                            } else {
                                                debugPrint(#file, #function, "Access denied")
                                                self.handleAccessDenied()
                                            }
                                        })
            
//            debugPrint(#file, #function, "Not Determined")
        default:
            debugPrint(#file, #function, "Case Default")
        }
        
        if #available(iOS 17.0, watchOS 10.0, *) {
            eventStore.requestFullAccessToEvents(completion: {
                (accessGranted: Bool, error: Error?) in
                self.handleRequestAccessResult(accessGranted: accessGranted, error: error)
            })
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: EKEntityType.event) {
                (accessGranted: Bool, error: Error?) in
                self.handleRequestAccessResult(accessGranted: accessGranted, error: error)
            }
        }
    } // func requestAccessToEKCalendars()
    
    private func handleRequestAccessResult            (accessGranted: Bool, error: Error?) {
        //            debugPrint(#file, #function, "Access granted:", accessGranted, error as Any)
        if accessGranted == true {
            self.handleAccessGranted()
        } else {
            self.handleAccessDenied()
        }
    }
    
    public func eventsFor(startDate:  Date, endDate: Date, calendars:  Array<EKCalendar>) -> Array<ASAEventCompatible> {
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        // Use the configured NSPredicate to find and return events in the store that match
        let rawEvents:  Array<EKEvent> = eventStore.events(matching: eventsPredicate)
        return rawEvents
    } // func eventsFor(startDate:  Date, endDate: Date, calendars:  Array<EKCalendar>) -> Array<ASAEventCompatible>
} // class ASAEKEventManager
