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
    var location:  CLLocation?
    var placeName:  String?
    var locality:  String?
    var country:  String?
    var ISOCountryCode:  String?
    var now:  Date
    
    var body: some View {
        HStack {
            Text((ISOCountryCode ?? "").flag())
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
                    Text(verbatim: location != nil ?  location!.humanInterfaceRepresentation() : "").multilineTextAlignment(.trailing)
                }
                if placeName != nil {
                    HStack {
                        Spacer()
                        Text(placeName!)
                    }
                }
                if locality != nil {
                    HStack {
                        Spacer()
                        Text(locality!)
                    }
                }

                    HStack {
                        Spacer()
                        if country != nil {
                            Text(country!)
                        }
                    }
                
            } // VStack
        } // HStack
    } // body
} // struct ASACalendarLocationCell

struct ASACalendarLocationCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarLocationCell(usesDeviceLocation: true, now: Date())
    }
}
