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
            return ASALocationWithClocks(location: location, clocks: location.genericClocks, usesDeviceLocation: false)
            
        case .EarthLocation:
            return ASALocationWithClocks(location: location, clocks: location.genericClocks, usesDeviceLocation: usesDeviceLocation)
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
    
    func containsLocationOfType(_ type: ASALocationType) -> Bool {
        for locationWithClocks in self {
            if locationWithClocks.location.type == type {
                return true
            }
        }
        
        return false
    } // func containsLocationOfType(_ type: ASALocationType) -> Bool
} // extension Array where Element == ASALocationWithClocks
