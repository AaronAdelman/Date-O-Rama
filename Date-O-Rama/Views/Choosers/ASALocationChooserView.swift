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
    @State var tempLocationData:  ASALocation = ASALocation(type: .EarthLocation)
    @State var tempUsesDeviceLocation: Bool = false {
        didSet {
            if tempUsesDeviceLocation == true {
                tempLocationData = ASALocationManager.shared.deviceLocation
            }
        } // didSet
    } // var tempUsesDeviceLocation
    @ObservedObject var locationManager = ASALocationManager.shared

    @Environment(\.dismiss) var dismiss
    
#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
#endif
    
    fileprivate func propagateInfoBackToParent() {
        debugPrint(#file, #function, "Propagate info back to parent")
        let changingLocationType = (self.tempLocationData.type != self.locationWithClocks.location.type)
        
        let usesDeviceLocation = self.tempUsesDeviceLocation && tempLocationData.type == .EarthLocation
        self.locationWithClocks.usesDeviceLocation = usesDeviceLocation
        if usesDeviceLocation {
            self.locationWithClocks.location = ASALocationManager.shared.deviceLocation
        } else {
            self.locationWithClocks.location = self.tempLocationData
        }
        if changingLocationType {
            self.locationWithClocks.clocks = locationWithClocks.location.genericClocks
        }
    }
    
    fileprivate func createNewLocationWithClocks() {
        debugPrint(#file, #function, "Create new location with clocks")
        let userData: ASAUserData = ASAUserData.shared
        let newLocationWithClocks = ASALocationWithClocks.generic(location: tempLocationData, usesDeviceLocation: tempUsesDeviceLocation)
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
                    self.dismiss()
                })
                .font(Font.body)
                
                Spacer()
                    .frame(width: SIDE_SPACER_WIDTH)
            } // HStack
            
            Form {
                Section {
                    ASALocationCell(usesDeviceLocation: $tempUsesDeviceLocation, locationData: $tempLocationData)
                    ASATimeZoneCell(timeZone: $tempLocationData.timeZone, now: Date())
                }
                
                let pickerStyle: Any = compact ? WheelPickerStyle() : SegmentedPickerStyle()
                Section {
                    Picker(selection: $tempLocationData.type, label:
                            Text("Location Type").bold().lineLimit(2), content: {
                        ForEach(ASALocationType.allCases) {
                            Text($0.localizedName).tag($0.rawValue)
                        }
                    })
                    .modifier(ASAPicker(compact: compact))
                }
                
                if tempLocationData.type == .EarthLocation {
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
            }
            .font(Font.body)
            .onAppear() {
                self.tempUsesDeviceLocation = self.locationWithClocks.usesDeviceLocation
                self.tempLocationData = self.locationWithClocks.location
            }
            .onDisappear() {
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
