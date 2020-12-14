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

let UPDATED_LOCATION_NAME = "UPDATED_LOCATION"


// MARK: -

class ASALocationManager: NSObject, ObservableObject {
    private static var sharedLocationManager: ASALocationManager = {
        let locationManager = ASALocationManager()

        return locationManager
    }()
    
    static var shared:  ASALocationManager {
        return sharedLocationManager
    } // static var shared

    override init() {
        super.init()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    } // init()
    
    let notificationCenter = NotificationCenter.default

    @Published var locationAuthorizationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    private var lastDeviceLocation: CLLocation?
    
    private var lastDevicePlacemark: CLPlacemark?
    
    @Published var deviceLocationData: ASALocationData = ASALocationData(location: nil, name: nil, locality: nil, country: nil, ISOCountryCode: nil, timeZone:  TimeZone.autoupdatingCurrent) {
        willSet {
            objectWillChange.send()
        } // willSet
    } // var deviceLocationData

//    var statusString: String {
//        guard let status = locationAuthorizationStatus else {
//            return "unknown"
//        }
//
//        switch status {
//        case .notDetermined: return "notDetermined"
//        case .authorizedWhenInUse: return "authorizedWhenInUse"
//        case .authorizedAlways: return "authorizedAlways"
//        case .restricted: return "restricted"
//        case .denied: return "denied"
//        default: return "unknown"
//        }
//    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

extension ASALocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationAuthorizationStatus = status
//        print(#function, statusString)
    }

    fileprivate func reverseGeocode(_ location: CLLocation) {
        let coder = CLGeocoder();
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;
            
            if place == nil || error != nil {
//                debugPrint(#file, #function, place ?? "nil place", error ?? "nil error")
                
                var tempLocationData = ASALocationData()
                tempLocationData.location              = location
                tempLocationData.timeZone              = TimeZone.autoupdatingCurrent

                tempLocationData.country  = self.lastDevicePlacemark?.country
                tempLocationData.ISOCountryCode = self.lastDevicePlacemark?.isoCountryCode

                self.finishDidUpdateLocations(tempLocationData)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                    self.reverseGeocode(location)
                }
                return
            }
            
            self.lastDevicePlacemark = place
            self.lastDeviceLocation = location
            let tempLocationData = ASALocationData.create(placemark: place, location: location)
            self.finishDidUpdateLocations(tempLocationData)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        print(#file, #function, location)
        
        let Δ = self.lastDeviceLocation?.distance(from: location)

        if Δ == nil || Δ! >= 10.0 {
            reverseGeocode(location)
        }
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

    fileprivate func finishDidUpdateLocations(_ tempLocationData: ASALocationData) {
        self.deviceLocationData = tempLocationData
        self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION_NAME), object: nil)
        
//        debugPrint(#file, #function, tempLocationData.location ?? "nil location")
    } // func finishDidUpdateLocations(_ tempLocationData: ASALocationData)
} // extension ASALocationManager
