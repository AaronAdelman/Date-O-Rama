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

//struct ASALocationDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALocationDetailView()
//    }
//}
