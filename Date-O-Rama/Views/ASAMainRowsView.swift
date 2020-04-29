//
//  ASAMainRowsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASAMainRowsView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var dummyRow:  ASARow = ASARow.dummy()
    @State var now = Date()
    @ObservedObject var locationManager = LocationManager()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var currentLocation:  CLLocation? {
        get {
            return self.locationManager.lastLocation
        } // get
    } // var currentLocation
    
    var currentPlacemark:  CLPlacemark? {
        get {
            return self.locationManager.lastPlacemark
        } // get
    } // var currentPlacemark

    
    let INSET = 25.0 as CGFloat
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.mainRows, id:  \.uid) { row in
                    NavigationLink(
                        destination: ASACalendarDetailView(selectedRow: row, now: self.now, currentLocation: self.currentLocation, currentPlacemark: self.currentPlacemark)
                            .onReceive(row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences()
                        }
                    ) {
                        VStack(alignment: .leading) {
                            Text(verbatim:  row.dateString(now:self.now, defaultLocation: self.currentLocation)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                            HStack {
                                Spacer().frame(width: self.INSET)
//                                Image(systemName: "calendar")
                                Text(verbatim: "🗓")
                                Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                            }
                            if row.calendar.supportsTimeZones() {
                                HStack {
                                    Spacer().frame(width: self.INSET)
                                    Text(row.timeZone.emoji(date:  self.now))
                                    Text(verbatim: "\(row.timeZone.localizedName(for: row.timeZone.isDaylightSavingTime(for: self.now) ? .daylightSaving : .standard, locale: Locale.current) ?? "") • \(row.timeZone.abbreviation() ?? "")").font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                                }
                            }
                            if row.calendar.supportsLocations() {
                                ASAMainRowLocationSubcell(INSET: self.INSET, row: row, now: self.now, currentLocation: self.currentLocation, currentPlacemark: self.currentPlacemark)
                            }
                        }
                    }
                }
                .onMove { (source: IndexSet, destination: Int) -> Void in
                    self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                    self.userData.savePreferences()
                }
                .onDelete { indices in
                    indices.forEach {
                        debugPrint("\(#file) \(#function)")
                        self.userData.mainRows.remove(at: $0) }
                    self.userData.savePreferences()
                }
            }
            .navigationBarTitle(Text("Date-O-Rama"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: {
                        withAnimation {
                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows before")
                            self.userData.mainRows.insert(ASARow.generic(), at: self.userData.mainRows.count)
                            self.userData.savePreferences()
                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows after")
                        }
                }
                ) {
//                    Image(systemName: "plus")
                    Text(verbatim:  "➕")
                }
            )
//            ASACalendarDetailView(selectedRow: self.dummyRow, now: self.now, currentLocation: self.currentLocation)
//        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            }.navigationViewStyle(StackNavigationViewStyle())
            .onReceive(timer) { input in
                for row in self.userData.mainRows {
                    let transition = row.calendar.transitionToNextDay(now: self.now, location: self.currentLocation, timeZone: row.timeZone)
//                    debugPrint("\(#file) \(#function) Transition time:  \(transition); input time:  \(input)…")
//                    debugPrint("ն:  \(self.now); 🕛:  \(transition); 🔣:  \(input)…")
                    if  input >= transition {
//                        debugPrint("\(#file) \(#function) After transition time (\(transition)), updating date to \(input)…")
                        self.now = Date()
                        break
                    }
                } // for row in self.userData.mainRows
//                debugPrint("==========")
                
//                debugPrint("\(#file) \(#function) \(self.locationManager.statusString) \(String(describing: self.currentLocation)), \(self.now.solarEvents(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude, events: [.sunrise, .sunset]))")
        }
    }
} // struct ASAMainRowsView

struct ASAMainRowLocationSubcell:  View {
    var INSET:  CGFloat
    var row:  ASARow
    var now:  Date
    var currentLocation:  CLLocation?
    var currentPlacemark:  CLPlacemark?
    
    func location() -> CLLocation? {
        if row.usesDeviceLocation {
            return currentLocation
        } else {
            return row.location
        }
    } // func location() -> CLLocation?
    
    func placemark() -> CLPlacemark? {
        if row.usesDeviceLocation {
            return currentPlacemark
        } else {
            return row.placemark
        }
    } // func placemark() -> CLPlacemark?
    
    var body: some View {
        HStack {
            Spacer().frame(width: self.INSET)
            Text((self.placemark()?.isoCountryCode ?? "").flag())
            if row.usesDeviceLocation {
                Image(systemName: "location.fill")
            }
            if placemark() == nil {
                if location() != nil {
                    Text(verbatim:  location()!.humanInterfaceRepresentation()).multilineTextAlignment(.trailing)
                }
            } else {
                Text(placemark()!.name ?? "")
                Text(placemark()!.locality ?? "")
                Text(placemark()!.country ?? "")
            }
        } // HStack
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsView().environmentObject(ASAUserData())
    }
}
