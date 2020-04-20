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
                        destination: DetailView(selectedRow: row)
                            .onReceive(row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences()
                        }
                    ) {
                        VStack(alignment: .leading) {
                            Text(verbatim:  row.dateString(now:self.now)).font(.headline).multilineTextAlignment(.leading).lineLimit(2)
                            Text(verbatim:  row.calendarCode.localizedName()).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                        }
                    }
                }
                .onMove { (source: IndexSet, destination: Int) -> Void in
                    self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
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
            DetailView(selectedRow: self.dummyRow)
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


struct ASADetailCell:  View {
    var title:  String
    var detail:  String
    var body:  some View {
        HStack {
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail)
        } // HStack
    } // var body
} // struct ASADetailCell


struct DetailView: View {
    @ObservedObject var selectedRow:  ASARow
    
    var body: some View {
        List {
            //            if selectedRow != nil {
            if selectedRow.dummy != true {
                Section(header:  Text(NSLocalizedString("HEADER_Row", comment: ""))) {
                    NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow)) {
                        ASADetailCell(title: NSLocalizedString("HEADER_Calendar", comment: ""), detail: self.selectedRow.calendarCode.localizedName())
                    }
                    if selectedRow.supportsLocales() {
                        NavigationLink(destination: ASALocalePickerView(row: selectedRow)) {
                            ASADetailCell(title:  NSLocalizedString("HEADER_Locale", comment: ""), detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                        }
                    }
                    NavigationLink(destination: ASAFormatPickerView(row: selectedRow)) {
                        ASADetailCell(title:  NSLocalizedString("HEADER_Date_format", comment: ""), detail: selectedRow.majorDateFormat.localizedItemName())
                    }
                }
                Section(header:  Text("HEADER_Date")) {
                    ForEach(selectedRow.details(), id: \.name) {
                        detail
                        in
                        HStack {
                            Text(NSLocalizedString(detail.name, comment: "")).bold()
                            Spacer()
                            Text(verbatim:  (self.selectedRow.dateString(now: Date(), LDMLString: detail.geekCode)) )
                        }
                    }
                }
            } else {
                //                Text("Detail view content goes here")
                EmptyView()
            }
        }.navigationBarTitle(Text(selectedRow.dateString(now: Date()) ))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsView().environmentObject(ASAUserData())
    }
}
