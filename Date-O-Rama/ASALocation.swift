//
//  ASALocation.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASALocation:  Equatable, Identifiable, Hashable {
    var id = UUID()
    var location:  CLLocation = CLLocation.NullIsland
    var name:  String?
    var locality:  String?
    var country:  String?
    var regionCode:  String?
    
    var postalCode: String?
    var administrativeArea: String?
    var subAdministrativeArea: String?
    var subLocality: String?
    var thoroughfare: String?
    var subThoroughfare: String?
    
    var timeZone:  TimeZone = TimeZone.GMT
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.coordinate.latitude)
        hasher.combine(location.coordinate.longitude)
    }
    
    static func ==(lhs: ASALocation, rhs: ASALocation) -> Bool {
        return lhs.location.coordinate.latitude == rhs.location.coordinate.latitude && lhs.location.coordinate.longitude == rhs.location.coordinate.longitude && lhs.location.altitude == rhs.location.altitude
    }
} // struct ASALocation


// MARK:  -

extension ASALocation {
    static func create(placemark:  CLPlacemark?, location:  CLLocation?) -> ASALocation {
        let usedLocation = location != nil ? location! : (placemark?.location ?? CLLocation.NullIsland)
        var country: String? = placemark?.country
        var ISOCountryCode: String? = placemark?.isoCountryCode
        var timeZone: TimeZone = placemark?.timeZone ?? TimeZone.GMT
        var locality: String? = placemark?.locality
        
        if ISOCountryCode == nil {
            // We need to test if Apple's location server screwed up in favor of inappropriate political neutrality and fix any such problem.
            let JudeaAndSamariaNorth: CLLocationDegrees = 32.0 + 40.0 / 60.0
            let JudeaAndSamariaSouth: CLLocationDegrees = 31.0
            let JudeaAndSamariaEast: CLLocationDegrees = 35.0 + 40.0 / 60.0
            let JudeaAndSamariaWest: CLLocationDegrees = 35.0
            
            let GolanNorth: CLLocationDegrees = 33.0 + 20.0 / 60.0
            let GolanSouth: CLLocationDegrees = 32.0 + 30.0 / 60.0
            let GolanEast: CLLocationDegrees = 36.0
            let GolanWest: CLLocationDegrees = 35.0 + 20.0 / 60.0
            
            let GazaStripNorth: CLLocationDegrees = 31.0 + 40.0 / 60.0
            let GazaStripSouth: CLLocationDegrees = 31.0
            let GazaStripEast: CLLocationDegrees = 34.0 + 40.0 / 60.0
            let GazaStripWest: CLLocationDegrees = 34.0
            
            let JerusalemNorth: CLLocationDegrees = 31.0 + 58.0 / 60.0
            let JerusalemSouth: CLLocationDegrees = 31.0 + 42.0 / 60.0
            let JerusalemEast: CLLocationDegrees  = 35.0 + 16.0 / 60.0
            let JerusalemWest: CLLocationDegrees  = 35.0 + 11.0 / 60.0

            if usedLocation.isWithin(north: JudeaAndSamariaNorth, south: JudeaAndSamariaSouth, east: JudeaAndSamariaEast, west: JudeaAndSamariaWest) || usedLocation.isWithin(north: GolanNorth, south: GolanSouth, east: GolanEast, west: GolanWest) {
                country = NSLocalizedString("Israel", comment: "")
                ISOCountryCode = REGION_CODE_Israel
                timeZone = TimeZone(identifier: "Asia/Jerusalem")!
            } else if usedLocation.isWithin(north: GazaStripNorth, south: GazaStripSouth, east: GazaStripEast, west: GazaStripWest) {
                country = NSLocalizedString("Gaza Strip", comment: "")
                ISOCountryCode = REGION_CODE_Palestine
                timeZone = TimeZone(identifier: "Asia/Gaza")!
            }
            
            if usedLocation.isWithin(north: JerusalemNorth, south: JerusalemSouth, east: JerusalemEast, west: JerusalemWest) && locality == nil {
                locality = NSLocalizedString("Jerusalem", comment: "")
            }
        }
        
        let temp = ASALocation(id: UUID(), location: usedLocation, name: placemark?.name, locality: locality, country: country, regionCode: ISOCountryCode, postalCode: placemark?.postalCode, administrativeArea: placemark?.administrativeArea, subAdministrativeArea: placemark?.subAdministrativeArea, subLocality: placemark?.subLocality, thoroughfare: placemark?.thoroughfare, subThoroughfare: placemark?.subThoroughfare, timeZone: timeZone)
        //        debugPrint(#file, #function, placemark as Any, temp)
        return temp
    } // static func create(placemark:  CLPlacemark?) -> ASALocation
    
    var formattedOneLineAddress:  String {
        get {
            let SEPARATOR = NSLocalizedString("ADDRESS_SEPARATOR", comment: "")

            var temp: Array<String> = []
            temp.appendIfDifferentAndNotNil(string: self.locality)
            temp.appendIfDifferentAndNotNil(string: self.administrativeArea)
            temp.appendIfDifferentAndNotNil(string: self.country)

            if temp.count == 0 {
                return self.location.humanInterfaceRepresentation
            }

            return temp.joined(separator: SEPARATOR)
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
            let SEPARATOR = NSLocalizedString("ADDRESS_SEPARATOR", comment: "")

            var temp: Array<String> = []
            temp.appendIfDifferentAndNotNil(string: self.name)
            temp.appendIfDifferentAndNotNil(string: self.locality)
            temp.appendIfDifferentAndNotNil(string: self.administrativeArea)
            temp.appendIfDifferentAndNotNil(string: self.country)

            if temp.count == 0 {
                return self.location.humanInterfaceRepresentation
            }

            return temp.joined(separator: SEPARATOR)
        } // get
    } // var longFormattedOneLineAddress
} // extension ASALocation


// MARK:  -

extension ASALocation {
    static var NullIsland:  ASALocation {
        return ASALocation(id: UUID(), location: CLLocation.NullIsland, name: nil, locality: nil, country: nil, regionCode: nil, postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: TimeZone.GMT)
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
    static var cachedCurrentTimeZoneDefaultIdentifier:  String?
    static var cachedCurrentTimeZoneDefaultLocation:  ASALocation?

    static var currentTimeZoneDefault:  ASALocation {
        let currentTimeZone: TimeZone = TimeZone.current
        let currentTimeZoneIdentifier = currentTimeZone.identifier
        if cachedCurrentTimeZoneDefaultIdentifier != nil && cachedCurrentTimeZoneDefaultLocation != nil {
            if currentTimeZoneIdentifier == cachedCurrentTimeZoneDefaultIdentifier! {
                // Used cached info
                return cachedCurrentTimeZoneDefaultLocation!
            }
        }

        do {
            let fileURL = Bundle.main.url(forResource:"TimeZones", withExtension: "txt")
            if fileURL == nil {
                debugPrint(#file, #function, "Could not open!")
            }

            let jsonData = (try? Data(contentsOf: fileURL!))!
            let newJSONDecoder = JSONDecoder()

            let timeZoneDatabase = try newJSONDecoder.decode(ASATimeZoneDatabase.self, from: jsonData)
            let entry:  ASATimeZoneEntry? = timeZoneDatabase.entries.first(where: { $0.name == currentTimeZoneIdentifier })

            if entry == nil {
                return ASALocation.NullIsland
            }

            let countryCode: String = entry!.ISOCountryCode ?? ""
            let name:  String = entry!.name
            let country = countryName(countryCode: countryCode)
            let (locality, administrativeArea) = localityAndAdministrativeArea(name: name)
            let latitude: CLLocationDegrees = entry!.latitude
            let longitude: CLLocationDegrees = entry!.longitude

            let result: ASALocation = ASALocation(id: UUID(), location: CLLocation(latitude: latitude, longitude: longitude), name: nil, locality: locality, country: country, regionCode: countryCode, postalCode: nil, administrativeArea: administrativeArea, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: currentTimeZone)

            // Store result in cache
            ASALocation.cachedCurrentTimeZoneDefaultIdentifier = currentTimeZoneIdentifier
            ASALocation.cachedCurrentTimeZoneDefaultLocation = result

            return result
        } catch {
            debugPrint(#file, #function, error)
            return ASALocation.NullIsland
        }
    } // static var currentTimeZoneDefault
} // extension ASALocation
