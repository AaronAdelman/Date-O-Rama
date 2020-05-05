//
//  ASACalendarLocationCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASACalendarLocationCell:  View {
    var usesDeviceLocation:  Bool
    //    var location:  CLLocation?
    //    var placeName:  String?
    //    var locality:  String?
    //    var country:  String?
    //    var ISOCountryCode:  String?
    var locationData:  ASALocationData
    
    var body: some View {
        HStack {
            Text((locationData.ISOCountryCode ?? "").flag())
            Text("HEADER_LOCATION").bold()
            Spacer()
            VStack {
                if usesDeviceLocation {
                    HStack {
                        Spacer()
                        Image(systemName: "location.fill")
                        Text("DEVICE_LOCATION").multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Spacer()
                    Text(verbatim: locationData.location != nil ?  locationData.location!.humanInterfaceRepresentation() : "").multilineTextAlignment(.trailing)
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
                
                HStack {
                    Spacer()
                    if locationData.country != nil {
                        Text(locationData.country!)
                    }
                }
                
                if locationData.postalCode != nil {
                    HStack {
                        Spacer()
                        Text(locationData.postalCode!)
                    }
                }
                
                
            } // VStack
        } // HStack
    } // body
} // struct ASACalendarLocationCell

struct ASACalendarLocationCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarLocationCell(usesDeviceLocation: true, locationData: ASALocationData())
    }
}
