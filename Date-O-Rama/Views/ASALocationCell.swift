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
        switch authorizationStatus! {
        case .authorizedAlways, .authorizedWhenInUse:
            return "DEVICE_LOCATION"
        default:
            return "LAST_DEVICE_LOCATION"
        } // switch authorizationStatus
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
                }
                HStack {
                    Spacer()
                    Text(verbatim: locationData.location != nil ?  locationData.location!.humanInterfaceRepresentation : "").multilineTextAlignment(.trailing)
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
