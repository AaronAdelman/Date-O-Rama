//
//  CLLocationExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    func humanInterfaceRepresentation() -> String {
        let absoluteLatitude:  Double = abs(self.coordinate.latitude)
        let absoluteLatitudeString = String(format: "%.4f", absoluteLatitude)
        let latituteDirection = self.coordinate.latitude >= 0.0 ? "N" : "S"
        let absoluteLongitude:  Double = abs(self.coordinate.longitude)
        let absoluteLongitudeString = String(format: "%.4f", absoluteLongitude)
        let longitudeDirection = self.coordinate.longitude >= 0.0 ? "E" : "W"
        
        let altitudeString = String(format: "%.0f", self.altitude)

        let result = "\(absoluteLatitudeString)°\(latituteDirection) \(absoluteLongitudeString)°\(longitudeDirection) \(altitudeString)m"
        return result
    } // func ISO6079HumanInterfaceRepresentation() -> String
} // extension CLLocation
