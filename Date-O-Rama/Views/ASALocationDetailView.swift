//
//  ASALocationDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 18/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationDetailView: View {
    @ObservedObject var locationWithClocks:  ASALocationWithClocks
    var now:  Date
    
    @State private var showingActionSheet = false
    
    @EnvironmentObject var userData:  ASAModel
    
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
                    NavigationLink(destination:  ASALocationChooserView(locationWithClocks: locationWithClocks, shouldCreateNewLocationWithClocks: false).environmentObject(userData).environmentObject(locationWithClocks.locationManager), label: {
                        ASALocationCell(usesDeviceLocation: $locationWithClocks.usesDeviceLocation, locationData: locationWithClocks.location).environmentObject(locationWithClocks.locationManager)
                    })
                    
                    ASATimeZoneCell(timeZone: $locationWithClocks.location.timeZone, now: now)
                } // Section
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingActionSheet = true
                        }) {
                            Text("Delete this location").foregroundStyle(Color.red).frame(alignment: .center)
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
            .foregroundStyle(Color.primary)
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
