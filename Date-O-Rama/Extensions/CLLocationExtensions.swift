//
//  CLLocationExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

// From https://stackoverflow.com/questions/27996351/swift-convert-decimal-coordinate-into-degrees-minutes-seconds-direction
extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }

    var dmsString:  String {
        let (d, m, s) = self.dms
        return "\(d)°\(m)′\(s)″"
    }
}


// MARK:  -

extension CLLocation {
    var humanInterfaceRepresentation:  String {
        get {
            let absoluteLatitude:  Double = abs(self.coordinate.latitude)
            let absoluteLatitudeString = absoluteLatitude.dmsString
            let latituteDirection = self.coordinate.latitude >= 0.0 ? "N" : "S"
            let absoluteLongitude:  Double = abs(self.coordinate.longitude)
            let absoluteLongitudeString = absoluteLongitude.dmsString
            let longitudeDirection = self.coordinate.longitude >= 0.0 ? "E" : "W"
            var result = "\(absoluteLatitudeString)\(latituteDirection) \(absoluteLongitudeString)\(longitudeDirection)"

            if self.altitude != 0.0 {
                let altitudeString = String(format: "%.0f", self.altitude)

                result = "\(result) \(altitudeString)m"
            }

            return result
        }
    } // var humanInterfaceRepresentation
} // extension CLLocation

//extension CLLocation {
//    static var NullIsland:  CLLocation {
//        // Default, filler location value that keeps being used in this program
//        return CLLocation(latitude: 0.0, longitude: 0.0)
//    } // static var NullIsland:  CLLocation
//} // extension CLLocation
