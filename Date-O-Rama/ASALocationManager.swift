//
//  LocationManager.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  Based on https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers
//

import Foundation
import Combine
import CoreLocation
import Network

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

    private let monitor = NWPathMonitor()
    @Published var connectedToTheInternet = false {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            } // DispatchQueue.main.async
        } // willSet
    } // var connectedToTheInternet

    override init() {
        super.init()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.requestAlwaysAuthorization()

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                debugPrint(#file, #function, "We’re connected!")
                self.connectedToTheInternet = true
            } else {
                debugPrint(#file, #function, "No connection.")
                self.connectedToTheInternet = false
            }

            debugPrint(#file, #function, path.isExpensive)
        }

        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    } // init()
    
    let notificationCenter = NotificationCenter.default

    @Published var locationAuthorizationStatus: CLAuthorizationStatus? {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            } // DispatchQueue.main.async
        } // willSet
    } // var locationAuthorizationStatus
    
    private var lastDeviceLocation: CLLocation?
    
    private var lastDevicePlacemark: CLPlacemark?
    
    @Published var deviceLocationData: ASALocation = ASALocation.currentTimeZoneDefault {
        willSet {
            objectWillChange.send()
        } // willSet
    } // var deviceLocationData

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()

    var lastError:  Error?
} // class ASALocationManager


// MARK:  - CLLocationManagerDelegate

extension ASALocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationAuthorizationStatus = status
//        print(#file, #function, status)
        self.lastError = nil
        self.locationManager.startUpdatingLocation()
    } // func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(#file, #function, error)
        self.lastError = error
//        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
    } // func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)

    fileprivate func reverseGeocode(_ location: CLLocation) {
        let coder = CLGeocoder();
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;
            
            if place == nil || error != nil {
//                debugPrint(#file, #function, place ?? "nil place", error ?? "nil error")
                
                var tempLocationData = ASALocation()
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
            let tempLocationData = ASALocation.create(placemark: place, location: location)
            self.finishDidUpdateLocations(tempLocationData)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        print(#file, #function, location)
        
        let Δ = self.lastDeviceLocation?.distance(from: location)

        if Δ == nil || Δ! >= 10.0 {
            self.reverseGeocode(location)
        }
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

    fileprivate func finishDidUpdateLocations(_ tempLocationData: ASALocation) {
        self.deviceLocationData = tempLocationData
        self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION_NAME), object: nil)
        
//        debugPrint(#file, #function, tempLocationData.location ?? "nil location")
    } // func finishDidUpdateLocations(_ tempLocationData: ASALocation)

    #if os(watchOS)
    #else
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        debugPrint(#file, #function)
    } // func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        debugPrint(#file, #function)
//        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
    } // func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        debugPrint(#file, #function, error.debugDescription)
        self.locationManager.requestAlwaysAuthorization()
    } // func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
    #endif
} // extension ASALocationManager
