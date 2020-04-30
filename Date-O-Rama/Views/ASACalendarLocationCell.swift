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
    var placemark:  CLPlacemark?
    var now:  Date
    
    var body: some View {
        HStack {
            Text((placemark?.isoCountryCode ?? "").flag())
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
                if placemark?.name != nil {
                    HStack {
                        Spacer()
                        Text(placemark!.name!)
                    }
                }
                if placemark?.locality != nil {
                    HStack {
                        Spacer()
                        Text(placemark!.locality!)
                    }
                }
                if placemark != nil {
                    HStack {
                        Spacer()
                        if placemark?.country != nil {
                            Text(placemark!.country!)
                        }
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
