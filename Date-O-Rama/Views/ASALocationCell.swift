//
//  ASALocationCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASALocationCell:  View {
    var usesDeviceLocation:  Bool
    var locationData:  ASALocationData
    @ObservedObject var locationManager = ASALocationManager.shared

    func rawDeviceLocationString(authorizationStatus:  CLAuthorizationStatus?) -> String {
        let RAW_LAST_DEVICE_LOCATION_STRING = "LAST_DEVICE_LOCATION"

        if authorizationStatus == nil {
            return RAW_LAST_DEVICE_LOCATION_STRING
        }

        if authorizationStatus!.authorizedAtLeastWhenInUse {
            return "DEVICE_LOCATION"
        } else {
            return RAW_LAST_DEVICE_LOCATION_STRING
        }
    } // func rawDeviceLocationString(authorizationStatus:  CLAuthorizationStatus?) -> String
    
    var body: some View {
        HStack {
            Text("HEADER_LOCATION").bold()
            Spacer()
            VStack {
                if usesDeviceLocation {
                    HStack {
                        Spacer()
                        ASASmallLocationSymbol()
                        Text(NSLocalizedString(rawDeviceLocationString(authorizationStatus: locationManager.locationAuthorizationStatus), comment:  "")).multilineTextAlignment(.trailing)
                    }
                    if !(locationManager.locationAuthorizationStatus?.authorizedAtLeastWhenInUse ?? false) {
                        Text("NO_DEVICE_LOCATION_PERMISSION").foregroundColor(.gray)
                    }
                }
                HStack {
                    Spacer()
                    Text(verbatim:
//                            locationData.location != nil ?
                            locationData.location.humanInterfaceRepresentation
//                            : ""
                    ).multilineTextAlignment(.trailing)
                }
                if locationData.name != nil {
                    HStack {
                        Spacer()
                        Text(locationData.name!)
                    }
                }
                
                if locationData.subLocality != nil && locationData.locality != locationData.subLocality {
                    HStack {
                        Spacer()
                        Text(locationData.subLocality!)
                    }
                }
                
                if locationData.locality != nil && locationData.locality != locationData.name {
                    HStack {
                        Spacer()
                        Text(locationData.locality!)
                    }
                }
                
                if locationData.subAdministrativeArea != nil {
                    HStack {
                        Spacer()
                        Text(locationData.subAdministrativeArea!)
                    }
                }
                
                if locationData.administrativeArea != nil {
                    HStack {
                        Spacer()
                        Text(locationData.administrativeArea!)
                    }
                }

                if locationData.postalCode != nil {
                    HStack {
                        Spacer()
                        Text(locationData.postalCode!)
                    }
                }

                HStack {
                    Spacer()
                    if locationData.country != nil {
                        Text(locationData.country!)
                        Text((locationData.ISOCountryCode ?? "").flag())
                    }
                }
                
                
            } // VStack
        } // HStack
    } // body
} // struct ASALocationCell

struct ASALocationCell_Previews: PreviewProvider {
    static var previews: some View {
        ASALocationCell(usesDeviceLocation: true, locationData: ASALocationData())
    }
}
