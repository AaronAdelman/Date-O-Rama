//
//  ASALocationWithClocks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

class ASALocationWithClocks: NSObject, ObservableObject {
    @Published var location: ASALocation {
        didSet {
            for clock in clocks {
                clock.locationData = location
            }
        }
    }
    @Published var clocks: Array<ASAClock>
    @Published var usesDeviceLocation:  Bool
    
    init(location: ASALocation, clocks: Array<ASAClock>, usesDeviceLocation: Bool) {
        self.location           = location
        self.clocks             = clocks
        self.usesDeviceLocation = usesDeviceLocation
        super.init()
        registerForLocationChangedNotifications()
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
            for clock in clocks {
                clock.locationData = locationManager.deviceLocationData
            } // for clock in clocks
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

