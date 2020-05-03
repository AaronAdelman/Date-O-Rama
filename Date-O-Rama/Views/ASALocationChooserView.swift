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
    @ObservedObject var row:  ASARow
    @State var enteredAddress:  String = ""
    @State var locationDataArray:  Array<ASALocationData> = []
    @State var tempLocationData:  ASALocationData = ASALocationData()
    @State var tempUsesDeviceLocation: Bool = false
    
    var body: some View {
        Form {
            Section {
                ASACalendarLocationCell(usesDeviceLocation: tempUsesDeviceLocation, location: tempLocationData.location, placeName: tempLocationData.name, locality: tempLocationData.locality, country: tempLocationData.country, ISOCountryCode: tempLocationData.ISOCountryCode)
            }
            Section {
                Toggle(isOn: $tempUsesDeviceLocation) {
                    Text("Use device location")
                }
            }
            if !tempUsesDeviceLocation {
                Section {
                    Text("Address")
                    TextField("Requested address", text: $enteredAddress)
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.geolocate()
                    }) {Text("Check").foregroundColor(.accentColor).bold()}
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
            }
        }
        .navigationBarTitle(Text(row.dateString(now: Date()) ))
        .onAppear() {
            self.tempUsesDeviceLocation = self.row.usesDeviceLocation
            self.tempLocationData = self.row.locationData
        }
        .onDisappear() {
            debugPrint(#file, #function, "Before row", self.row.usesDeviceLocation, self.row.locationData)
            debugPrint(#file, #function, "Before temp", self.tempUsesDeviceLocation, self.tempLocationData)
            self.row.usesDeviceLocation = self.tempUsesDeviceLocation
            self.row.locationData = self.tempLocationData
            debugPrint(#file, #function, "After row", self.row.usesDeviceLocation, self.row.locationData)
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
                    temp.append(ASALocationData.create(placemark: placemark))
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
            Text("\(locationData.name ?? "") \(locationData.locality ?? "") \(locationData.country ?? "")")
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
        ASALocationChooserView(row: ASARow.test(), tempLocationData: ASALocationData())
    }
}
