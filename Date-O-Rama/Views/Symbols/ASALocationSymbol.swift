//
//  ASALocationSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

extension CLAuthorizationStatus {
    var symbolName:  String {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return "location.fill"
            
        case .notDetermined:
            return "location"
            
        default:
            return "location.slash.fill"
        } // switch self
    } // var symbolName
    
    var symbolColor:  Color {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return Color.green
            
        case .notDetermined:
            return Color.yellow
            
        case .restricted:
            return Color.orange
            
        case .denied:
            return Color.red
            
        @unknown default:
            return Color.gray
        } // switch self
    } // var symbolColor
} // extension CLAuthorizationStatus

struct ASALocationSymbol:  View {
    @ObservedObject var locationManager: ASALocationManager

    var body:  some View {
        let SCALE: Image.Scale = .small
        if self.locationManager.locationAuthorizationStatus == nil {
            Image(systemName:  "location.slash")
                .imageScale(SCALE)
                .foregroundColor(.pink)
        } else {
            let effectiveStatus: CLAuthorizationStatus = self.locationManager.locationAuthorizationStatus!
            Image(systemName:  (effectiveStatus).symbolName)
                .imageScale(SCALE)
                .foregroundColor(effectiveStatus.symbolColor)
        }
    } // var body
} // struct ASALocationSymbol
