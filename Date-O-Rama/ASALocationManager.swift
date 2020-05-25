//
//  LocationManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  Based on https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers
//

import Foundation
import CoreLocation
import Combine

let UPDATED_LOCATION = "UPDATED_LOCATION"


// MARK: -

class ASALocationManager: NSObject, ObservableObject {
    private static var sharedLocationManager: ASALocationManager = {
        let locationManager = ASALocationManager()

        return locationManager
    }()
    
    class func shared() -> ASALocationManager {
        return sharedLocationManager
    } // class func shared() -> ASALocationManager

    override init() {
        super.init()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    } // init()
    
    let notificationCenter = NotificationCenter.default

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    private var lastDeviceLocation: CLLocation?
    
    private var lastDevicePlacemark: CLPlacemark?
    
    @Published var locationData: ASALocationData = ASALocationData(location: nil, name: nil, locality: nil, country: nil, ISOCountryCode: nil, timeZone:  TimeZone.autoupdatingCurrent) {
        willSet {
            objectWillChange.send()
        } // willSet
    } // var locationData
    
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }

    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

extension ASALocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        //        print(#function, location)
        let Δ = self.lastDeviceLocation?.distance(from: location)

        if Δ == nil || Δ! >= 10.0 {
            let coder = CLGeocoder();
            coder.reverseGeocodeLocation(location) { (placemarks, error) in
                let place = placemarks?.last;
                
                self.lastDevicePlacemark = place
                self.lastDeviceLocation = location
                let tempLocationData = ASALocationData.create(placemark: place)
                self.locationData = tempLocationData
                self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION), object: nil)
                
                debugPrint(#file, #function, location, place as Any)
            }
        }
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

} // extension ASALocationManager
