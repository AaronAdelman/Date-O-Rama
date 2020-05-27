//
//  ASAClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 25.0 as CGFloat
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.mainRows, id:  \.uuid) { row in
                    NavigationLink(
                        destination: ASAClockDetailView(selectedRow: row, now: self.now)
                            .onReceive(row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences()
                        }
                    ) {
                        ASAMainRowsViewCell(row: row, now: self.now, INSET: self.INSET)
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
            .navigationBarTitle(Text("CLOCKS_TAB"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: {
                        withAnimation {
                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows before")
                            self.userData.mainRows.insert(ASARow.generic(), at: 0)
                            self.userData.savePreferences()
                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows after")
                        }
                }
                ) {
                    Text(verbatim:  "➕")
                }
            )
            }.navigationViewStyle(StackNavigationViewStyle())
            .onReceive(timer) { input in
//                for row in self.userData.mainRows {
//                    let transition = row.startOfNextDay(now: self.now)
////                    debugPrint("ն:  \(self.now); 🕛:  \(transition); 🔣:  \(input)…")
//                    if  input >= transition {
////                        debugPrint("\(#file) \(#function) After transition time (\(transition)), updating date to \(input)…")
                        self.now = Date()
//                        break
//                    }
//                } // for row in self.userData.mainRows
//                debugPrint("==========")
                
//                debugPrint("\(#file) \(#function) \(self.locationManager.statusString) \(String(describing: self.deviceLocation)), \(self.now.solarEvents(latitude: self.deviceLocation.coordinate.latitude, longitude: self.deviceLocation.coordinate.longitude, events: [.sunrise, .sunset]))")
        }
    }
} // struct ASAMainRowsView

struct ASAMainRowsViewCell:  View {
    @ObservedObject  var row:  ASARow
    var now:  Date
    var INSET:  CGFloat
    
    let ROW_HEIGHT = 30.0 as CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(verbatim: "🗓")
                Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
            }.frame(height: ROW_HEIGHT)
            
            HStack {
                Spacer().frame(width: self.INSET)
                VStack(alignment: .leading) {
                    if row.calendar.canSplitTimeFromDate {
                        Text(verbatim:  row.dateString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                        Text(verbatim:  row.timeString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                    } else {
                        Text(verbatim:  row.dateTimeString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                    }
                }
            }
//            HStack {
//                Spacer().frame(width: self.INSET)
//                Text(verbatim: "🗓")
//                Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
//            }.frame(height: ROW_HEIGHT)
            
            HStack {
                //                if row.usesDeviceLocation {
                //                    Image(systemName: "location.fill")
                //                }
                VStack(alignment: .leading) {
                    if row.calendar.supportsTimeZones || row.calendar.supportsLocations {
                        //                        HStack {
                        //                            Spacer().frame(width: self.INSET)
                        //                            Text(row.effectiveTimeZone.emoji(date:  self.now))
                        //                            Text(verbatim: "\(row.effectiveTimeZone.localizedName(for: row.effectiveTimeZone.isDaylightSavingTime(for: self.now) ? .daylightSaving : .standard, locale: Locale.current) ?? "") • \(row.effectiveTimeZone.abbreviation() ?? "")").font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                        ASAMainRowsLocationSubcell(INSET: self.INSET, row: row, now: self.now).frame(height: ROW_HEIGHT)
                        //                        }.frame(height: ROW_HEIGHT)
                        //                        ASAMainRowsLocationSubcell(INSET: self.INSET, row: row, now: self.now).frame(height: ROW_HEIGHT)
                    }
                }
            }
            
        } // VStack
    } // var body
} // struct ASAMainRowsViewCell

struct ASAMainRowsLocationSubcell:  View {
    var INSET:  CGFloat
    @ObservedObject var row:  ASARow
    var now:  Date

    var body: some View {
        HStack {
            Spacer().frame(width: self.INSET)
            Text(verbatim:  row.emoji(date:  self.now))

            if row.placeName == nil && row.locality == nil && row.country == nil {
                if row.location != nil {
                    Text(verbatim:  row.location!.humanInterfaceRepresentation()).font(.subheadline)
                }
            } else {
                Text(row.locationData.formattedOneLineAddress()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(2).frame(height: 60.0)
            }
        } // HStack
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
