//
//  ASAMainRowsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine

struct ASAMainRowsView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var dummyRow:  ASARow = ASARow.dummy()
    @State var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.mainRows, id:  \.uid) { row in
                    NavigationLink(
                        destination: ASACalendarDetailView(selectedRow: row, now: self.now)
                            .onReceive(row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences()
                        }
                    ) {
                        VStack(alignment: .leading) {
                            Text(verbatim:  row.dateString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                            Text(verbatim:  row.calendar.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(2)
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
                    Image(systemName: "plus")
                }
            )
            ASACalendarDetailView(selectedRow: self.dummyRow, now: self.now)
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            .onReceive(timer) { input in
                let midnight = self.now.nextMidnight()
                if input > midnight {
                    debugPrint("\(#file) \(#function) After midnight (\(midnight)), updating date to \(input)…")
                    self.now = Date()
                }
        }
    }
} // struct ASAMainRowsView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsView().environmentObject(ASAUserData())
    }
}
