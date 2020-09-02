//
//  ASALocationChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-03.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASALocationChooserView: View {
    @ObservedObject var locatedObject:  ASALocatedObject
    @State var enteredAddress:  String = ""
    @State var locationDataArray:  Array<ASALocationData> = []
    @State var tempLocationData:  ASALocationData = ASALocationData()
    @State var tempUsesDeviceLocation: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    var body: some View {
        Form {
            Section {
                ASATimeZoneCell(timeZone: tempLocationData.timeZone ?? TimeZone.autoupdatingCurrent, now: Date())
                ASALocationCell(usesDeviceLocation: tempUsesDeviceLocation, locationData: tempLocationData)
            }
            Section {
                Toggle(isOn: $tempUsesDeviceLocation) {
                    Text("Use device location")
                }
            }
            if !tempUsesDeviceLocation {
                HStack {
                    TextField("Requested address", text: $enteredAddress)
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.geolocate()
                    }) {Text("🔍").foregroundColor(.accentColor).bold()}
                }
                Section {
                    ForEach(self.locationDataArray, id: \.uid) {
                        locationData
                        in
                        ASALocationChooserViewCell(locationData: locationData, selectedLocationData: self.$tempLocationData)
                            .onTapGesture {
                                self.tempLocationData = locationData
                        }
                    }
                } // Section
                Section {
                    MapView(coordinate: tempLocationData.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
                        .aspectRatio(1.0, contentMode: .fit)
                } // Section
            }
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
                    self.locatedObject.locationData = ASALocationManager.shared().locationData
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
                var temp:  Array<ASALocationData> = []
                for placemark in placemarks ?? [] {
                    temp.append(ASALocationData.create(placemark: placemark, location: nil))
                }
                self.locationDataArray = temp
            } else {
                self.locationDataArray = []
            }
        }
    } // func geolocate()
} // struct ASALocationChooserView

struct ASALocationChooserViewCell:  View {
    var locationData:  ASALocationData
    
    @Binding var selectedLocationData:  ASALocationData
    
    var body: some View {
        HStack {
            Text(locationData.longFormattedOneLineAddress)
            Spacer()
            if self.locationData == self.selectedLocationData {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    }
}


struct LocationChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocationChooserView(locatedObject: ASARow.test(), tempLocationData: ASALocationData())
    }
}
