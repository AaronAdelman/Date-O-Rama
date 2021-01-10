//
//  ASALocationChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-03.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct ASALocationChooserView: View {
    @ObservedObject var locatedObject:  ASALocatedObject
    @State var enteredAddress:  String = ""
    @State var locationDataArray:  Array<ASALocation> = []
    @State var tempLocationData:  ASALocation = ASALocation()
    @State var tempUsesDeviceLocation: Bool = false {
        didSet {
            if tempUsesDeviceLocation == true {
                tempLocationData = ASALocationManager.shared.deviceLocationData
            }
        } // didSet
    } // var tempUsesDeviceLocation
    @ObservedObject var locationManager = ASALocationManager.shared

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    var body: some View {
        Form {
            Section {
                ASALocationCell(usesDeviceLocation: tempUsesDeviceLocation, locationData: tempLocationData)
                ASATimeZoneCell(timeZone: tempLocationData.timeZone, now: Date())
            }
            Section {
                if !locationManager.connectedToTheInternet {
                    Text("CANNOT_GEOLOCATE").foregroundColor(.gray)
                }

                if locationManager.connectedToTheInternet {
                    Toggle(isOn: $tempUsesDeviceLocation) {
                        Text("Use device location")
                    }
                }
            } // Section

            if !tempUsesDeviceLocation && locationManager.connectedToTheInternet {
                HStack {
                    TextField("Requested address", text: $enteredAddress)
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.geolocate()
                    }) {
                        Text("🔍").foregroundColor(.accentColor).bold()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                Section {
                    ForEach(self.locationDataArray, id: \.id) {
                        locationData
                        in
                        ASALocationChooserViewCell(locationData: locationData, selectedLocationData: self.$tempLocationData)
                            .onTapGesture {
                                self.tempLocationData = locationData
                            }
                    }
                } // Section
            }
            Section {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: self.tempLocationData.location.coordinate , latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)), annotationItems:  [self.tempLocationData]) {
                    tempLocationData
                    in
                    MapPin(coordinate: tempLocationData.location.coordinate )
                }
                .aspectRatio(1.0, contentMode: .fit)
            } // Section
        }
        .navigationBarItems(trailing:
                                Button("Cancel", action: {
                                    self.didCancel = true
                                    self.presentationMode.wrappedValue.dismiss()
                                })
        )
        .onAppear() {
            self.tempUsesDeviceLocation = self.locatedObject.usesDeviceLocation
            self.tempLocationData = self.locatedObject.locationData
        }
        .onDisappear() {
            if !self.didCancel {
                //                debugPrint(#file, #function, "Before row", self.locatedObject.usesDeviceLocation, self.locatedObject.locationData)
                //                debugPrint(#file, #function, "Before temp", self.tempUsesDeviceLocation, self.tempLocationData)
                self.locatedObject.usesDeviceLocation = self.tempUsesDeviceLocation
                if self.tempUsesDeviceLocation {
                    self.locatedObject.locationData = ASALocationManager.shared.deviceLocationData
                } else {
                    self.locatedObject.locationData = self.tempLocationData
                }
                //                debugPrint(#file, #function, "After row", self.locatedObject.usesDeviceLocation, self.locatedObject.locationData)
            }
        }
    }
    
    func geolocate() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.enteredAddress) { (placemarks, error)
            in
            debugPrint(#file, #function, placemarks as Any, error as Any)
            
            if error == nil {
                var temp:  Array<ASALocation> = []
                for placemark in placemarks ?? [] {
                    temp.append(ASALocation.create(placemark: placemark, location: nil))
                }
                self.locationDataArray = temp
            } else {
                self.locationDataArray = []
            }
        }
    } // func geolocate()
} // struct ASALocationChooserView


// MARK:  -

struct ASALocationChooserViewCell:  View {
    var locationData:  ASALocation
    
    @Binding var selectedLocationData:  ASALocation
    
    var body: some View {
        HStack {
            Text(locationData.longFormattedOneLineAddress)
            Spacer()
            if self.locationData == self.selectedLocationData {
                ASACheckmarkSymbol()
            }
        }
    }
}


// MARK:  -

struct LocationChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocationChooserView(locatedObject: ASARow.generic, tempLocationData: ASALocation())
    }
}
