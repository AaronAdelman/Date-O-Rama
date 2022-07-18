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
                if locationWithClocks.location.type == .EarthLocation {
                    Section(header:  Text("")) {
                        NavigationLink(destination:  ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: false), label: {
                            ASALocationCell(usesDeviceLocation: locationWithClocks.usesDeviceLocation, locationData: locationWithClocks.location)
                        })
                        
                        ASATimeZoneCell(timeZone: locationWithClocks.location.timeZone, now: now)
                    } // Section
                    
                    Section {
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: locationWithClocks.location.location.coordinate , latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)), annotationItems:  [locationWithClocks.location]) {
                            tempLocationData
                            in
                            MapPin(coordinate: tempLocationData.location.coordinate )
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding()
                    } // Section
                } else {
                    ASAQuasiLocationSection(locationType: locationWithClocks.location.type)
                }
                
                Section(header:  Text("")) {
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
    var rawText: String? {
        switch self {
        case .EarthLocation:
            return nil
        case .EarthUniversal:
            return "EarthUniversal description"
        case .MarsUniversal:
            return "MarsUniversal description"
        }
    }

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

struct ASAQuasiLocationSection: View {
    var locationType: ASALocationType
    
    var body: some View {
        Section(header:  Text(NSLocalizedString(locationType.rawText ?? "", comment: ""))
            .font(.title)) {
            (locationType.image ?? Image(systemName: "photo"))
                .resizable()
                .scaledToFit()
        }
    }
}

//struct ASALocationDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationDetailView()
//    }
//}
