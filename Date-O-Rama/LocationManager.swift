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

class LocationManager: NSObject, ObservableObject {

    override init() {
        super.init()
        self.locationManager.delegate = self
        
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastDeviceLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
  
    @Published var lastDevicePlacemark: CLPlacemark? {
        willSet {
            objectWillChange.send()
        }
    }


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

extension LocationManager: CLLocationManagerDelegate {

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
            self.lastDeviceLocation = location
            
            if place != nil {
                self.lastDevicePlacemark = place
            } else {
                // Uh-oh!  We had a reverse geocoding failure.  Only change the placemark if the distance is more than 10 meters to avoid the relevant info from disappearing needlessly.
                if (Δ ?? 0.0) > 10.0 {
                    self.lastDevicePlacemark = nil
                }
            }
            debugPrint(#file, #function, location, place as Any)
        }
    }

}
