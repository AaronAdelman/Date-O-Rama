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

struct ASALocationData:  Equatable {
    var uid = UUID()
    var location:  CLLocation?
    var name:  String?
    var locality:  String?
    var country:  String?
    var ISOCountryCode:  String?
    
    var postalCode: String?
    var administrativeArea: String?
    var subAdministrativeArea: String?
    var subLocality: String?
    var thoroughfare: String?
    var subThoroughfare: String?
    
    var timeZone:  TimeZone?
} // struct ASALocationData

extension ASALocationData {
    static func create(placemark:  CLPlacemark?) -> ASALocationData {
        let temp = ASALocationData(uid: UUID(), location: placemark?.location, name: placemark?.name, locality: placemark?.locality, country: placemark?.country, ISOCountryCode: placemark?.isoCountryCode, postalCode: placemark?.postalCode, administrativeArea: placemark?.administrativeArea, subAdministrativeArea: placemark?.subAdministrativeArea, subLocality: placemark?.subLocality, thoroughfare: placemark?.thoroughfare, subThoroughfare: placemark?.subThoroughfare, timeZone: placemark?.timeZone)
        debugPrint(#file, #function, placemark as Any, temp)
        return temp
    } // static func create(placemark:  CLPlacemark?) -> ASALocationData
    
    func formattedOneLineAddress() -> String {
        let separator = NSLocalizedString("ADDRESS_SEPARATOR", comment: "")
        
//        var temp = self.name ?? ""
        var temp = ""

//        if self.locality != nil && self.locality != self.name {
            if self.locality != nil {
                temp += "\(temp.count > 0 ? separator : "")\(self.locality!)"
        }
        
        if self.administrativeArea != nil {
            temp += "\(temp.count > 0 ? separator : "")\(self.administrativeArea!)"
        }
        
        if self.country != nil {
            temp += "\(temp.count > 0 ? separator : "")\(self.country!)"
        }
        
        return temp
    }
} // extension ASALocationData


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
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

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
        //        self.lastLocation = location
        //        print(#function, location)
        let Δ = self.lastDeviceLocation?.distance(from: location)

        if Δ == nil || Δ! >= 10.0 {
            let coder = CLGeocoder();
            coder.reverseGeocodeLocation(location) { (placemarks, error) in
                let place = placemarks?.last;
                
                self.lastDevicePlacemark = place
                self.lastDeviceLocation = location
//                let tempLocationData = ASALocationData(location: location, name: place?.name, locality: place?.locality, country: place?.country, ISOCountryCode: place?.isoCountryCode, timeZone:  place?.timeZone)
                let tempLocationData = ASALocationData.create(placemark: place)
                self.locationData = tempLocationData
                self.notificationCenter.post(name: Notification.Name(UPDATED_LOCATION), object: nil)
                
                debugPrint(#file, #function, location, place as Any)
            }
        }
    } // func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

} // extension ASALocationManager
