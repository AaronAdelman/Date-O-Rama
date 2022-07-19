//
//  ASALocationWithClocks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import Combine

class ASALocationWithClocks: NSObject, ObservableObject, Identifiable {
    var id = UUID()

    @Published var location: ASALocation {
        willSet {
            objectWillChange.send()
        } // willSet
        
//        didSet {
//            for clock in clocks {
//                clock.locationData = location
//            }
//        }
    }
    @Published var clocks: Array<ASAClock>
    
    @Published var usesDeviceLocation:  Bool {
        willSet {
            objectWillChange.send()
        } // willSet
        
//        didSet {
//            for clock in clocks {
//                clock.usesDeviceLocation = usesDeviceLocation
//                if usesDeviceLocation {
//                    clock.locationData = ASALocationManager.shared.deviceLocation
//                }
//            }
//        }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(location: ASALocation, clocks: Array<ASAClock>, usesDeviceLocation: Bool) {
        self.location           = location
        self.clocks             = clocks
        self.usesDeviceLocation = usesDeviceLocation
//        for clock in clocks {
//            clock.locationData       = location
//            clock.usesDeviceLocation = usesDeviceLocation
//        }
        super.init()
        registerForLocationChangedNotifications()
    } // init(location: ASALocation, clocks: Array<ASAClock>, usesDeviceLocation: Bool)
    
    static func generic(location: ASALocation, usesDeviceLocation: Bool) -> ASALocationWithClocks {
        let locationType = location.type
        switch locationType {
        case .EarthUniversal, .MarsUniversal:
            return ASALocationWithClocks(location: location, clocks: [ASAClock.generic(calendarCode: locationType.defaultCalendarCode, dateFormat: .full)], usesDeviceLocation: false)
            
        case .EarthLocation:
            let regionCode: (String) = (location.regionCode ?? "")
            let clocks: Array<ASAClock> = regionCode.defaultCalendarCodes.map {
//                let clock = ASAClock.generic(calendarCode: $0, dateFormat: .full)
//                let builtInCalendarNames = $0.genericBuiltInEventCalendarNames(regionCode: regionCode)
//                for fileName in builtInCalendarNames {
//                    let newEventCalendar = ASAEventCalendar(fileName: fileName)
//                    if newEventCalendar.eventsFile != nil {
//                        clock.builtInEventCalendars.append(newEventCalendar)
//                    }
//                } // for fileName in builtInCalendarNames
                let clock = ASAClock.generic(calendarCode: $0, dateFormat: .full, regionCode: regionCode)
                return clock
            }
            return ASALocationWithClocks(location: location, clocks: clocks, usesDeviceLocation: usesDeviceLocation)
        }
    }
    
    fileprivate func registerForLocationChangedNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleLocationChanged(notification:)), name: NSNotification.Name(rawValue: UPDATED_LOCATION_NAME), object: nil)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    } // deinit
    
    @objc func handleLocationChanged(notification:  Notification) -> Void {
        if self.usesDeviceLocation {
            let locationManager = ASALocationManager.shared
//            for clock in clocks {
//                clock.locationData = locationManager.deviceLocation
//            } // for clock in clocks
            self.location = locationManager.deviceLocation
        }
    } // func handle(notification:  Notification) -> Void
} // struct ASALocationWithClocks


// MARK:  -

extension Array where Element == ASALocationWithClocks {
    var clocks: Array<ASAClock> {
        var result: Array<ASAClock> = []
        for entry in self {
            result.append(contentsOf: entry.clocks)
        } // for entry in self
        return result
    } // var clocks: Array<ASAClock>
} // extension Array where Element == ASALocationWithClocks

