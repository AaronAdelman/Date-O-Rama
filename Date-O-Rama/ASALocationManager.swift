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

struct ASALocationData {
    var location:  CLLocation?
    var name:  String?
    var locality:  String?
    var country:  String?
    var ISOCountryCode:  String?
} // struct ASALocationData


let UPDATED_LOCATION = "UPDATED_LOCATION"


// MARK: -


class ASALocationManager: NSObject, ObservableObject {
    private static var sharedLocationManager: ASALocationManager = {
        let locationManager = ASALocationManager()

        return locationManager
    }()
    
    class func shared() -> ASALocationManager {
        return sharedLocationManager
    }

    override init() {
        super.init()
        self.locationManager.delegate = self
        
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    let notificationCenter = NotificationCenter.default

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    //    @Published var lastDeviceLocation: CLLocation? {
    //        willSet {
    //            objectWillChange.send()
    //        }
    //    }
    //
    //    @Published var lastDevicePlacemark: CLPlacemark? {
    //        willSet {
    //            objectWillChange.send()
    //        }
    //    }
    
    private var lastDeviceLocation: CLLocation?
    
    private var lastDevicePlacemark: CLPlacemark?
    
    @Published var locationData: ASALocationData = ASALocationData(location: nil, name: nil, locality: nil, country: nil, ISOCountryCode: nil) {
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
//        self.lastLocation = location
//        print(#function, location)
        
        let coder = CLGeocoder();
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;

            let Δ = self.lastDeviceLocation?.distance(from: location)
            
//            if place != nil {
//                self.lastDevicePlacemark = place
//                self.lastDeviceLocation = place?.location
//            } else {
//                // Uh-oh!  We had a reverse geocoding failure.  Only change the placemark if the distance is more than a kilometer to avoid the relevant info from disappearing needlessly.
//                if (Δ ?? 0.0) > 1000.0 {
//                    self.lastDevicePlacemark = nil
//                }
//                self.lastDeviceLocation = location
//            }
            
            if Δ ?? 1000000000.0 >= 10.0 {
                self.lastDevicePlacemark = place
                self.lastDeviceLocation = location
                let tempLocationData = ASALocationData(location: location, name: place?.name, locality: place?.locality, country: place?.country, ISOCountryCode: place?.isoCountryCode)
                self.locationData = tempLocationData
                self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION), object: nil)
            }
            
            debugPrint(#file, #function, location, place as Any)
        }
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

} // extension ASALocationManager
