//
//  ASAWatchClocksView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 25.0 as CGFloat
    
    var body: some View {
//        NavigationView {
            List {
                ForEach(userData.mainRows, id:  \.uuid) { row in
                    NavigationLink(
                        destination: ASAWatchClockDetailView(selectedRow: row, now: self.now)
//                            .onReceive(row.objectWillChange) { _ in
//                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
//                                self.userData.objectWillChange.send()
//                                self.userData.savePreferences(code: .clocks)
//                        }
                    ) {
//                        ASAMainRowsViewCell(row: row, compact: true, now: self.now, INSET: self.INSET, shouldShowTime: true)
                        ASAClockCell(processedRow: ASAProcessedRow(row: row, now: now), now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 0.0, shouldShowTime: false)
                    }
                }
//                .onMove { (source: IndexSet, destination: Int) -> Void in
//                    self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
//                    self.userData.savePreferences(code: .clocks)
//                }
//                .onDelete { indices in
//                    indices.forEach {
//                        debugPrint("\(#file) \(#function)")
//                        self.userData.mainRows.remove(at: $0) }
//                    self.userData.savePreferences(code: .clocks)
//                }
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
//            .navigationBarItems(
//                leading: EditButton(),
//                trailing: Button(
//                    action: {
//                        withAnimation {
//                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows before")
//                            self.userData.mainRows.insert(ASARow.generic(), at: 0)
//                            self.userData.savePreferences()
//                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows after")
//                        }
//                }
//                ) {
//                    Text(verbatim:  "➕")
//                }
//            )
//            }.navigationViewStyle(StackNavigationViewStyle())
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
}

struct ASAWatchClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAWatchClocksView()
    }
}
