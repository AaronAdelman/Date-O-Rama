//
//  ASALocationData.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

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
        
        var temp = ""
        
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
