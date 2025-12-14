//
//  ASALocation.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

class ASALocation:  Equatable, Identifiable, Hashable, ObservableObject, @unchecked Sendable {
    var id = UUID()
    var location:  CLLocation = CLLocation.nullIsland
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
    
    var type: ASALocationType = .earthUniversal
    
    init(id: UUID = UUID(), location: CLLocation, name: String? = nil, locality: String? = nil, country: String? = nil, regionCode: String? = nil, postalCode: String? = nil, administrativeArea: String? = nil, subAdministrativeArea: String? = nil, subLocality: String? = nil, thoroughfare: String? = nil, subThoroughfare: String? = nil, timeZone: TimeZone, type: ASALocationType) {
        self.id = id
        self.location = location
        self.name = name
        self.locality = locality
        self.country = country
        self.regionCode = regionCode
        self.postalCode = postalCode
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.subLocality = subLocality
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
        self.timeZone = timeZone
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.coordinate.latitude)
        hasher.combine(location.coordinate.longitude)
        hasher.combine(type)
    } // func hash(into hasher: inout Hasher)
    
    static func ==(lhs: ASALocation, rhs: ASALocation) -> Bool {
        if lhs.type != rhs.type {
            return false
        }
        
        if lhs.type == .earthLocation {
        return lhs.location.coordinate.latitude == rhs.location.coordinate.latitude && lhs.location.coordinate.longitude == rhs.location.coordinate.longitude && lhs.location.altitude == rhs.location.altitude
        }
        
        return true
    } // static func ==(lhs: ASALocation, rhs: ASALocation) -> Bool
} // struct ASALocation


// MARK:  -

private extension CLLocation {
    var isWithinJudeaAndSamaria: Bool {
        let JudeaAndSamariaNorth: CLLocationDegrees = 32.0 + 40.0 / 60.0
        let JudeaAndSamariaSouth: CLLocationDegrees = 31.0
        let JudeaAndSamariaEast: CLLocationDegrees = 35.0 + 40.0 / 60.0
        let JudeaAndSamariaWest: CLLocationDegrees = 35.0
        return self.isWithin(north: JudeaAndSamariaNorth, south: JudeaAndSamariaSouth, east: JudeaAndSamariaEast, west: JudeaAndSamariaWest)
    }
    
    var isWithinGolan: Bool {
        let GolanNorth: CLLocationDegrees = 33.0 + 20.0 / 60.0
        let GolanSouth: CLLocationDegrees = 32.0 + 30.0 / 60.0
        let GolanEast: CLLocationDegrees = 36.0
        let GolanWest: CLLocationDegrees = 35.0 + 20.0 / 60.0
        return self.isWithin(north: GolanNorth, south: GolanSouth, east: GolanEast, west: GolanWest)
    }
    
    var isWithinGazaStrip: Bool {
        let GazaStripNorth: CLLocationDegrees = 31.0 + 40.0 / 60.0
        let GazaStripSouth: CLLocationDegrees = 31.0
        let GazaStripEast: CLLocationDegrees = 34.0 + 40.0 / 60.0
        let GazaStripWest: CLLocationDegrees = 34.0
        return self.isWithin(north: GazaStripNorth, south: GazaStripSouth, east: GazaStripEast, west: GazaStripWest)
    }
    
    var isWithinJerusalem: Bool {
        let JerusalemNorth: CLLocationDegrees = 31.0 + 58.0 / 60.0
        let JerusalemSouth: CLLocationDegrees = 31.0 + 42.0 / 60.0
        let JerusalemEast: CLLocationDegrees  = 35.0 + 16.0 / 60.0
        let JerusalemWest: CLLocationDegrees  = 35.0 + 11.0 / 60.0
        return self.isWithin(north: JerusalemNorth, south: JerusalemSouth, east: JerusalemEast, west: JerusalemWest)
    }
}

extension ASALocation {
    static func create(placemark:  CLPlacemark?, location:  CLLocation?) -> ASALocation {
        let usedLocation = location != nil ? location! : (placemark?.location ?? CLLocation.nullIsland)
        var country: String? = placemark?.country
        var ISOCountryCode: String? = placemark?.isoCountryCode
        var timeZone: TimeZone = placemark?.timeZone ?? TimeZone.GMT
        var locality: String? = placemark?.locality
        
        if ISOCountryCode == nil {
            // We need to test if Apple's location server screwed up in favor of inappropriate political neutrality and fix any such problem.
              
            if usedLocation.isWithinJudeaAndSamaria || usedLocation.isWithinGolan {
                ISOCountryCode = REGION_CODE_Israel
                country = Locale.current.localizedString(forRegionCode: ISOCountryCode!)
                timeZone = TimeZone(identifier: "Asia/Jerusalem")!
            } else if usedLocation.isWithinGazaStrip {
                ISOCountryCode = REGION_CODE_Palestine
                country = Locale.current.localizedString(forRegionCode: ISOCountryCode!)
                timeZone = TimeZone(identifier: "Asia/Gaza")!
            }
            
            if usedLocation.isWithinJerusalem && locality == nil {
                locality = NSLocalizedString("Jerusalem", comment: "")
            }
        }
        
        let temp = ASALocation(id: UUID(), location: usedLocation, name: placemark?.name, locality: locality, country: country, regionCode: ISOCountryCode, postalCode: placemark?.postalCode, administrativeArea: placemark?.administrativeArea, subAdministrativeArea: placemark?.subAdministrativeArea, subLocality: placemark?.subLocality, thoroughfare: placemark?.thoroughfare, subThoroughfare: placemark?.subThoroughfare, timeZone: timeZone, type: .earthLocation)
        //        debugPrint(#file, #function, placemark as Any, temp)
        return temp
    } // static func create(placemark:  CLPlacemark?) -> ASALocation
    
    var formattedOneLineAddress:  String {
        switch self.type {
        case .earthUniversal:
            return NSLocalizedString("Earth (all locations)", comment: "")
            
        case .marsUniversal:
            return NSLocalizedString("Mars (all locations)", comment: "")
            
        case .earthLocation:
            let SEPARATOR = NSLocalizedString("ADDRESS_SEPARATOR", comment: "")
            
            var temp: Array<String> = []
            temp.appendIfDifferentAndNotNil(string: self.locality)
            temp.appendIfDifferentAndNotNil(string: self.administrativeArea)
            temp.appendIfDifferentAndNotNil(string: self.country)
            
            if temp.count == 0 {
                return self.location.humanInterfaceRepresentation
            }
            
            return temp.joined(separator: SEPARATOR)
        } // switch self.type
    } // var formattedOneLineAddress

    var shortFormattedOneLineAddress:  String {
        switch self.type {
        case .earthUniversal, .marsUniversal:
            return self.formattedOneLineAddress
            
        case .earthLocation:
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
        } // switch self.type
    } // var shortFormattedOneLineAddress

    var longFormattedOneLineAddress:  String {
        switch self.type {
        case .earthUniversal, .marsUniversal:
            return self.formattedOneLineAddress
            
        case .earthLocation:
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
        } // switch self.type
    } // var longFormattedOneLineAddress

    static var NullIsland: ASALocation {
        return ASALocation(id: UUID(), location: CLLocation.nullIsland, name: nil, locality: nil, country: nil, regionCode: nil, postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: TimeZone.GMT, type: .earthLocation)
    } // static var NullIsland: ASALocation
    
    static var EarthUniversal: ASALocation {
        return ASALocation(id: UUID(), location: .nullIsland, timeZone: .GMT, type: .earthUniversal)
    } // static var EarthUniversal: ASALocation
    
    static var MarsUniversal: ASALocation {
        return ASALocation(id: UUID(), location: .nullIsland, timeZone: .GMT, type: .marsUniversal)
    } // static var MarsUniversal: ASALocation
    
    var flag: String {
        var code: String
        switch self.type {
        case .earthUniversal:
            code = REGION_CODE_Earth
            
        case .marsUniversal:
            code = REGION_CODE_Mars
        
        case .earthLocation:
            code = (self.regionCode ?? "")
        }
        return code.flag
    } // switch self.type
    
    func abbreviatedTimeZoneString(for now: Date) -> String {
        switch self.type {
        case .earthLocation:
            return self.timeZone.abbreviation(for: now) ?? ""
            
        case .earthUniversal:
            return TimeZone.GMT.abbreviation() ?? ""
            
        case .marsUniversal:
            return "MTC"
        } // switch self.type
    } // func abbreviatedTimeZoneString(for now: Date) -> String
    
    func localizedTimeZoneName(for now: Date) -> String {
        switch self.type {
        case .earthLocation:
            return self.timeZone.localizedName(for: now) 
            
        case .earthUniversal:
            return TimeZone.GMT.localizedName(for: now) 
            
        case .marsUniversal:
            return "Coordinated Martian Time"
        } // switch self.type
    } // func localizedTimeZoneName(for now: Date) -> String
    
    var properName: String? {
        switch self.type {
        case .earthLocation:
            return name

        case .earthUniversal:
            return NSLocalizedString("Earth (all locations)", comment: "")
            
        case .marsUniversal:
            return NSLocalizedString("Mars (all locations)", comment: "")
        } // switch self.type
    } // var properName
    
    var genericClocks: Array<ASAClock> {
        let locationType = self.type

        switch locationType {
        case .earthLocation:
            let regionCode: (String) = (self.regionCode ?? "")
            let clocks: Array<ASAClock> = regionCode.defaultCalendarCodes.map {
                let clock = ASAClock.generic(calendarCode: $0, dateFormat: .full, regionCode: regionCode)
                return clock
            }
            return clocks

        case .earthUniversal, .marsUniversal:
            return [ASAClock.generic(calendarCode: locationType.defaultCalendarCode, dateFormat: .full)]
        }
    }
} // extension ASALocation

extension ASALocation {
    func backgroundGradient(dayPart: ASADayPart) -> LinearGradient {
        let dayTop      = Color("dayTop")
        let dayBottom   = Color("dayBottom")
        let nightTop    = Color("nightTop")
        let nightBottom = Color("nightBottom")
        let generic: [Color] = [.black, .brown]
        let colors: [Color] = {
            switch self.type {
            case .earthUniversal, .marsUniversal:
                return generic
            case .earthLocation:
                switch dayPart {
                case .day:
                    return [dayTop, dayBottom]
                case .night:
                    return [nightTop, nightBottom]
                case .unknown:
                    return generic
                }
            }
        }()
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}


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

actor ASALocationCache {
    static let shared = ASALocationCache()

    private var cachedIdentifier: String?
    private var cachedLocation: ASALocation?

    func currentTimeZoneDefault() async -> ASALocation {
        let currentTimeZone = TimeZone.current
        let currentTimeZoneIdentifier = currentTimeZone.identifier

        if let cachedIdentifier, let cachedLocation,
           cachedIdentifier == currentTimeZoneIdentifier {
            return cachedLocation
        }

        do {
            guard let fileURL = Bundle.main.url(forResource: "TimeZones", withExtension: "txt") else {
                debugPrint(#file, #function, "Could not open!")
                return ASALocation.NullIsland
            }

            let jsonData = try Data(contentsOf: fileURL)
            let newJSONDecoder = JSONDecoder()
            newJSONDecoder.allowsJSON5 = true

            let timeZoneDatabase = try newJSONDecoder.decode(ASATimeZoneDatabase.self, from: jsonData)
            guard let entry = timeZoneDatabase.entries.first(where: { $0.name == currentTimeZoneIdentifier }) else {
                return ASALocation.NullIsland
            }

            let countryCode = entry.ISOCountryCode ?? ""
            let name = entry.name
            let country = countryName(countryCode: countryCode)
            let (locality, administrativeArea) = localityAndAdministrativeArea(name: name)
            let latitude = entry.latitude
            let longitude = entry.longitude

            let result = ASALocation(
                id: UUID(),
                location: CLLocation(latitude: latitude, longitude: longitude),
                name: nil,
                locality: locality,
                country: country,
                regionCode: countryCode,
                postalCode: nil,
                administrativeArea: administrativeArea,
                subAdministrativeArea: nil,
                subLocality: nil,
                thoroughfare: nil,
                subThoroughfare: nil,
                timeZone: currentTimeZone,
                type: .earthLocation
            )

            cachedIdentifier = currentTimeZoneIdentifier
            cachedLocation = result
            return result
        } catch {
            debugPrint(#file, #function, error)
            return ASALocation.NullIsland
        }
    }
}

extension ASALocation {
    static var currentTimeZoneDefault: ASALocation {
        get async {
            await ASALocationCache.shared.currentTimeZoneDefault()
        }
    }

    func updateWith(_ otherLocation: ASALocation) {
        self.location              = otherLocation.location
        self.name                  = otherLocation.name
        self.country               = otherLocation.country
        self.locality              = otherLocation.locality
        self.regionCode            = otherLocation.regionCode
        self.postalCode            = otherLocation.postalCode
        self.administrativeArea    = otherLocation.administrativeArea
        self.subAdministrativeArea = otherLocation.subAdministrativeArea
        self.subLocality           = otherLocation.subLocality
        self.thoroughfare          = otherLocation.thoroughfare
        self.subThoroughfare       = otherLocation.subThoroughfare
        self.timeZone              = otherLocation.timeZone
    }
}
