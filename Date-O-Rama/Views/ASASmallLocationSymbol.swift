//
//  ASASmallLocationSymbol.swift
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
        get {
            switch self {
            case .authorizedAlways, .authorizedWhenInUse:
                return "location.fill"

            case .notDetermined:
                return "location"

            default:
                return "location.slash.fill"
            } // switch self
        } // get
    } // var symbolName
} // extension CLAuthorizationStatus

struct ASASmallLocationSymbol:  View {
    @ObservedObject var locationManager = ASALocationManager.shared

    var body:  some View {
        Image(systemName:  (self.locationManager.locationAuthorizationStatus ?? CLAuthorizationStatus.denied).symbolName).imageScale(.small)
    } // var body
} // struct ASASmallLocationSymbol
