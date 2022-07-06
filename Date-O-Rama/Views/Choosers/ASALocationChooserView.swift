//
//  ASALocationChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct ASALocationChooserView: View {
    @ObservedObject var locationWithClocks: ASALocationWithClocks
    var shouldCreateNewLocationWithClocks: Bool

    @State var enteredAddress:  String = ""
    @State var locationDataArray:  Array<ASALocation> = []
    @State var tempLocationData:  ASALocation = ASALocation()
    @State var tempUsesDeviceLocation: Bool = false {
        didSet {
            if tempUsesDeviceLocation == true {
                tempLocationData = ASALocationManager.shared.deviceLocation
            }
        } // didSet
    } // var tempUsesDeviceLocation
    @ObservedObject var locationManager = ASALocationManager.shared

    @Environment(\.dismiss) var dismiss
//    @State var didCancel = false
    
    fileprivate func propagateInfoBackToParent() {
        debugPrint(#file, #function, "Propagate info back to parent")
        self.locationWithClocks.usesDeviceLocation = self.tempUsesDeviceLocation
        if self.tempUsesDeviceLocation {
            self.locationWithClocks.location = ASALocationManager.shared.deviceLocation
        } else {
            self.locationWithClocks.location = self.tempLocationData
        }
    }
    
    fileprivate func createNewLocationWithClocks() {
        debugPrint(#file, #function, "Create new location with clocks")
        let userData: ASAUserData = ASAUserData.shared
        let newLocationWithClocks = ASALocationWithClocks(location: tempLocationData, clocks: [ASAClock.generic], usesDeviceLocation: tempUsesDeviceLocation)
        userData.addLocationWithClocks(newLocationWithClocks)
    }
    
    var body: some View {
        let SIDE_SPACER_WIDTH = 20.0
        
        VStack {
            Spacer()
                .frame(height: 10.0)
            
            HStack {
                Spacer()
                    .frame(width: SIDE_SPACER_WIDTH)
                
                Button("OK", action: {
                    debugPrint(#file, #function, "OK button")
//                    self.didCancel = false
                    if shouldCreateNewLocationWithClocks {
                        createNewLocationWithClocks()
                    } else {
                        propagateInfoBackToParent()
                    }
                    self.dismiss()
                })
                .font(Font.body)
                
                Spacer()
                
                Button("Cancel", action: {
                    debugPrint(#file, #function, "Cancel button")
//                    self.didCancel = true
                    self.dismiss()
                })
                .font(Font.body)
                
                Spacer()
                    .frame(width: SIDE_SPACER_WIDTH)
            } // HStack
            
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
                            Text("🔍")
                                .foregroundColor(.accentColor)
                                .bold()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                    Section {
                        ForEach(self.locationDataArray, id: \.id) {
                            locationData
                            in
                            ASALocationChooserViewCell(location: locationData, selectedLocation: self.$tempLocationData)
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
            .font(Font.body)
            .onAppear() {
                self.tempUsesDeviceLocation = self.locationWithClocks.usesDeviceLocation
                self.tempLocationData = self.locationWithClocks.location
            }
            .onDisappear() {
//                handleDisappearance()
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
}


// MARK:  -

struct ASALocationChooserViewCell:  View {
    var location: ASALocation
    
    @Binding var selectedLocation: ASALocation
    
    var body: some View {
        HStack {
            Text(location.longFormattedOneLineAddress)
            Spacer()
            if self.location == self.selectedLocation {
                ASACheckmarkSymbol()
            }
        }
    }
}
