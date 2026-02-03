//
//  ASALocationWithClocks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ASALocationWithClocks: NSObject, ObservableObject, Identifiable {
    var id = UUID()

    @Published var location: ASALocation {
        willSet {
            objectWillChange.send()
        } // willSet
    }
    @Published var clocks: Array<ASAClock>
    
    @Published var usesDeviceLocation:  Bool {
        willSet {
            objectWillChange.send()
        } // willSet
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var locationManager: ASALocationManager
    
    init(location: ASALocation, clocks: Array<ASAClock>, usesDeviceLocation: Bool, locationManager: ASALocationManager) {
        self.location           = location
        self.clocks             = clocks
        self.usesDeviceLocation = usesDeviceLocation
        self.locationManager    = locationManager
        super.init()
        registerForLocationChangedNotifications()
    } // init(location: ASALocation, clocks: Array<ASAClock>, usesDeviceLocation: Bool)
    
    static func generic(location: ASALocation, usesDeviceLocation: Bool, locationManager: ASALocationManager) -> ASALocationWithClocks {
        let locationType = location.type
        switch locationType {
        case .earthUniversal, .marsUniversal:
            return ASALocationWithClocks(location: location, clocks: location.genericClocks, usesDeviceLocation: false, locationManager: locationManager)
            
        case .earthLocation:
            return ASALocationWithClocks(location: location, clocks: location.genericClocks, usesDeviceLocation: usesDeviceLocation, locationManager: locationManager)
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
    
    @MainActor @objc func handleLocationChanged(notification:  Notification) -> Void {
        if self.usesDeviceLocation {
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
    
    var containsDeviceLocation: Bool {
        let index = self.firstIndex(where: {$0.usesDeviceLocation})
        return index != nil
    } // var containsDeviceLocation: Bool
    
    func containsLocationOf(type: ASALocationType) -> Bool {
        let index = self.firstIndex(where: {$0.location.type == type})
        return index != nil
    } // func containsLocationOf(type: ASALocationType) -> Bool
} // extension Array where Element == ASALocationWithClocks


extension ASALocationWithClocks {
    var systemName: String {
        if self.usesDeviceLocation {
            return "location.fill"
        } else {
            switch self.location.type {
            case .earthLocation:
                return "mappin"
            case .earthUniversal:
                return "globe.americas.fill"
            case .marsUniversal:
                return "globe.desk.fill"
            }
        }
    }
}
