//
//  ASALocation.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASALocation:  Equatable, Identifiable {
    var id = UUID()
    var location:  CLLocation = CLLocation.NullIsland
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
    
    var timeZone:  TimeZone = TimeZone.GMT
} // struct ASALocation


// MARK:  -

extension ASALocation {
    static func create(placemark:  CLPlacemark?, location:  CLLocation?) -> ASALocation {
        let usedLocation = location != nil ? location! : (placemark?.location ?? CLLocation.NullIsland)
        let temp = ASALocation(id: UUID(), location: usedLocation, name: placemark?.name, locality: placemark?.locality, country: placemark?.country, ISOCountryCode: placemark?.isoCountryCode, postalCode: placemark?.postalCode, administrativeArea: placemark?.administrativeArea, subAdministrativeArea: placemark?.subAdministrativeArea, subLocality: placemark?.subLocality, thoroughfare: placemark?.thoroughfare, subThoroughfare: placemark?.subThoroughfare, timeZone: placemark?.timeZone ?? TimeZone.GMT)
        //        debugPrint(#file, #function, placemark as Any, temp)
        return temp
    } // static func create(placemark:  CLPlacemark?) -> ASALocation
    
    var formattedOneLineAddress:  String {
        get {
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

            if temp == "" {
                if self.name != nil {
                    temp = self.name!
                } else {
                    temp = self.location.humanInterfaceRepresentation
                }
            }

            return temp
        } // get
    } // var formattedOneLineAddress

    var shortFormattedOneLineAddress:  String {
        get {
            if self.locality != nil {
                return self.locality!
            }

            if self.administrativeArea != nil {
                return self.administrativeArea!            }

            if self.country != nil {
                return self.country!
            }

            if self.name != nil {
                return self.name!
            } else {
                return self.location.humanInterfaceRepresentation
            }
        } // get
    } // var shortFormattedOneLineAddress

    var longFormattedOneLineAddress:  String {
        get {
            let separator = NSLocalizedString("ADDRESS_SEPARATOR", comment: "")

            var temp = ""

            if self.name != nil {
                temp += "\(temp.count > 0 ? separator : "")\(self.name!)"
            }

            if self.locality != nil {
                temp += "\(temp.count > 0 ? separator : "")\(self.locality!)"
            }

            if self.administrativeArea != nil {
                temp += "\(temp.count > 0 ? separator : "")\(self.administrativeArea!)"
            }

            if self.country != nil {
                temp += "\(temp.count > 0 ? separator : "")\(self.country!)"
            }

            if temp == "" {
                temp = self.location.humanInterfaceRepresentation
            }

            return temp
        } // get
    } // var longFormattedOneLineAddress
} // extension ASALocation


// MARK:  -

extension ASALocation {
    static var NullIsland:  ASALocation {
        return ASALocation(id: UUID(), location: CLLocation.NullIsland, name: nil, locality: nil, country: nil, ISOCountryCode: nil, postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: TimeZone.GMT)
    } // static var NullIsland
} // extension ASALocation
