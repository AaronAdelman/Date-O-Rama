//
//  ASALocationDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 18/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI
import MapKit

struct ASALocationDetailView: View {
    @Binding var locationWithClocks:  ASALocationWithClocks
    @Binding var now:  Date
    
    @State private var showingActionSheet = false
    
    @EnvironmentObject var userData:  ASAUserData
    
    @Environment(\.presentationMode) var presentationMode
    
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var body: some View {
#if os(watchOS)
        EmptyView()
#else
        NavigationView {
            List {
                Section {
                    NavigationLink(destination:  ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: false), label: {
                        ASALocationCell(usesDeviceLocation: $locationWithClocks.usesDeviceLocation, locationData: locationWithClocks.location)
                    })
                    
                    ASATimeZoneCell(timeZone: $locationWithClocks.location.timeZone, now: now)
                } // Section
                
                Section {
                    if locationWithClocks.location.type == .EarthLocation {
                        let METERS = 1000000.0
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: locationWithClocks.location.location.coordinate , latitudinalMeters: METERS, longitudinalMeters: METERS)), annotationItems:  [locationWithClocks.location]) {
                            tempLocationData
                            in
                            MapPin(coordinate: tempLocationData.location.coordinate )
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding()
                    } else {
                        HStack(alignment: .center) {
                            Spacer()
                            ASAQuasiLocationImage(locationType: locationWithClocks.location.type)
                            Spacer()
                        }
                    }
                } // Section
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingActionSheet = true
                        }) {
                            Text("Delete this location").foregroundColor(Color.red).frame(alignment: .center)
                        }
                        Spacer()
                    } // HStack
                    .actionSheet(isPresented: self.$showingActionSheet) {
                        ActionSheet(title: Text("Are you sure you want to delete this location?"), buttons: [
                            .destructive(Text("Delete this location")) {
                                self.userData.removeLocationWithClocks(locationWithClocks)
                                self.dismiss()
                            },
                            .cancel()
                        ])
                    }
                }
            } // List
            .font(.body)
            .foregroundColor(.primary)
            .navigationTitle("Location Details")
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
#endif
    }
}


//  -

extension ASALocationType {
    var image: Image? {
        switch self {
        case .EarthLocation:
            return nil
        case .EarthUniversal:
            return Image("Earth")
        case .MarsUniversal:
            return Image("Mars")
        }
    }
}


//  -

struct ASAQuasiLocationImage: View {
    var locationType: ASALocationType
    
    var body: some View {
        let DIMENSION = 350.0
        (locationType.image ?? Image(systemName: "photo"))
            .resizable()
            .scaledToFit()
            .frame(width: DIMENSION, height: DIMENSION, alignment: .center)
    }
}

//struct ASALocationDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationDetailView()
//    }
//}
