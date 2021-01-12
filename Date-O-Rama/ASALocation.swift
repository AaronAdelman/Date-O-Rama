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


// MARK:  -

struct ASATimeZoneEntry:  Codable {
    var ISOCountryCode:  String?
    var latitude:  CLLocationDegrees
    var longitude:  CLLocationDegrees
    var name:  String
} // struct ASATimeZoneEntry

struct ASATimeZoneDatabase:  Codable {
    var entries:  Array<ASATimeZoneEntry>
} // struct ASATimeZoneDatabase

// Based on https://stackoverflow.com/questions/35682554/getting-country-name-from-country-code
func countryName(countryCode: String) -> String? {
    let current = Locale.current
    return current.localizedString(forRegionCode: countryCode)
}

fileprivate extension String {
    var withUnderscoresReplacedBySpaces: String {
        return self.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
    }
} // extension String

fileprivate func localityAndAdministrativeArea(name:  String) -> (String, String?) {
    let pieces = name.split(separator: "/")
    let lastPiece:  String = String(pieces.last ?? "")
    let locality = lastPiece.withUnderscoresReplacedBySpaces
    var administrativeArea:  String? = nil
    if pieces.count > 2 {
        administrativeArea = String(pieces[pieces.count - 2]).withUnderscoresReplacedBySpaces
    }
    return (locality, administrativeArea)
} // fileprivate func localityAndAdministrativeArea(name:  String) -> (String, String?)

extension ASALocation {
    static var currentTimeZoneDefault:  ASALocation {
        do {
            let fileURL = Bundle.main.url(forResource:"TimeZones", withExtension: "txt")
            if fileURL == nil {
                debugPrint(#file, #function, "Could not open!")
            }

            let jsonData = (try? Data(contentsOf: fileURL!))!
            let newJSONDecoder = JSONDecoder()

            let timeZoneDatabase = try newJSONDecoder.decode(ASATimeZoneDatabase.self, from: jsonData)
//            for entry in timeZoneDatabase.entries {
//                debugPrint(#file, #function,  entry, localityAndAdministrativeArea(name: entry.name), countryName(countryCode: entry.ISOCountryCode ?? "N/A") as Any)
//            }
            let currentTimeZone: TimeZone = TimeZone.current
            let entry:  ASATimeZoneEntry? = timeZoneDatabase.entries.first(where: { $0.name == currentTimeZone.identifier })

            if entry == nil {
                return ASALocation.NullIsland
            }

            let countryCode: String = entry!.ISOCountryCode ?? ""
            let name:  String = entry!.name
            let country = countryName(countryCode: countryCode)
            let (locality, administrativeArea) = localityAndAdministrativeArea(name: name)
            let latitude: CLLocationDegrees = entry!.latitude
            let longitude: CLLocationDegrees = entry!.longitude

            return ASALocation(id: UUID(), location: CLLocation(latitude: latitude, longitude: longitude), name: nil, locality: locality, country: country, ISOCountryCode: countryCode, postalCode: nil, administrativeArea: administrativeArea, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: currentTimeZone)
        } catch {
            debugPrint(#file, #function, error)
            return ASALocation.NullIsland
        }
    } // static var currentTimeZoneDefault
} // extension ASALocation
