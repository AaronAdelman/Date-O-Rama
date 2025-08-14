//
//  ASALocationManager.swift
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
#if os(watchOS)
#else
import UIKit
#endif

let UPDATED_LOCATION_NAME = "UPDATED_LOCATION"


// MARK: -

final class ASALocationManager: NSObject, ObservableObject, Sendable {
    @MainActor static let shared = ASALocationManager()
    
    private let monitor = NWPathMonitor()
    @MainActor @Published var connectedToTheInternet = false
    
    fileprivate func updateDesiredAccuracy() {
#if os(watchOS)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyReduced
#else
        DispatchQueue.main.async {
            let batteryState = UIDevice.current.batteryState
            var desiredAccuracy: CLLocationAccuracy
            if batteryState == .unplugged || batteryState == .unknown {
                desiredAccuracy = kCLLocationAccuracyReduced
            } else {
                desiredAccuracy = kCLLocationAccuracyBest
            }
            self.locationManager.desiredAccuracy = desiredAccuracy
            let generator = UIImpactFeedbackGenerator()
            generator.prepare()
            for _ in 1...4 {
                generator.impactOccurred(intensity: 1.0)
            }
        }
#endif
    }
    
    public func setUp() async {
        self.locationManager.delegate = self
        self.deviceLocation = await ASALocation.currentTimeZoneDefault
        
#if os(watchOS)
#else
        NotificationCenter.default.addObserver(forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: nil, using: {notificaton in
            self.updateDesiredAccuracy()
        })
#endif
        
        updateDesiredAccuracy()
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.connectedToTheInternet = (path.status == .satisfied)
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    override init() {
        super.init()
        Task {
            await self.setUp()
        }
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
    
    @Published var deviceLocation: ASALocation = ASALocation.NullIsland {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            } // DispatchQueue.main.async
        } // willSet
    } // var deviceLocation
    
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
        Task {
            await self.setUp()
        }
    } // func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            // TODO:  Set self.lastError
            
            self.locationManager.requestAlwaysAuthorization()
            return
        }
        //        print(#file, #function, location)
        self.lastError = nil
        self.reverseGeocode(location)
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    
    fileprivate func reverseGeocode(_ location: CLLocation) {
        let coder = CLGeocoder();
        coder.reverseGeocodeLocation(location) { (placemarks, error) in
            let place = placemarks?.last;
            
            if place == nil || error != nil {
                //                debugPrint(#file, #function, place ?? "nil place", error ?? "nil error")
                                
                let tempLocation = ASALocation(location: location, country: self.lastDevicePlacemark?.country, regionCode: self.lastDevicePlacemark?.isoCountryCode, timeZone: TimeZone.autoupdatingCurrent, type: .earthLocation)
                
                self.finishDidUpdateLocations(tempLocation)
                
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
    } // fileprivate func reverseGeocode(_ location: CLLocation)
    
    fileprivate func finishDidUpdateLocations(_ tempLocationData: ASALocation) {
        self.deviceLocation = tempLocationData
        self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION_NAME), object: nil)
        
        //        debugPrint(#file, #function, tempLocationData.location ?? "nil location")
    } // func finishDidUpdateLocations(_ tempLocationData: ASALocation)
    
#if os(watchOS)
#else
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        //        debugPrint(#file, #function)
    } // func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        //        debugPrint(#file, #function)
        self.locationManager.requestAlwaysAuthorization()
    } // func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        debugPrint(#file, #function, error.debugDescription)
        self.locationManager.requestAlwaysAuthorization()
    } // func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
#endif
} // extension ASALocationManager
