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
    
    fileprivate func saveUserData() {
        self.userData.savePreferences()
        
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        appDelegate.sendUserData(appDelegate.session)
    } // func saveUserData()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.mainRows, id:  \.uuid) { row in
                    NavigationLink(
                        destination: ASAClockDetailView(selectedRow: row, now: self.now)
                            .onReceive(row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.saveUserData()
                        }
                    ) {
                        ASAMainRowsViewCell(row: row, now: self.now, INSET: self.INSET)
                    }
                }
                .onMove { (source: IndexSet, destination: Int) -> Void in
                    self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                    self.saveUserData()
                }
                .onDelete { indices in
                    indices.forEach {
                        debugPrint("\(#file) \(#function)")
                        self.userData.mainRows.remove(at: $0) }
                    self.saveUserData()
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
                            self.saveUserData()
                            debugPrint("\(#file) \(#function) + button, \(self.userData.mainRows.count) rows after")
                        }
                }
                ) {
                    Text(verbatim:  "➕")
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
            .onReceive(timer) { input in
                self.now = Date()
        }
    }
} // struct ASAClocksView

struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
