//
//  ASAMainRowsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


struct ASAMainRowsView: View {
    @State var rows:  Array<ASARow> = [ASARow.test()]

    var body: some View {
        NavigationView {
//            MasterView(rows: self.$rows)
            List {
                ForEach(rows, id:  \.uid) { row in
                    NavigationLink(
                        destination: DetailView(selectedRow: row )
                    ) {
                        Text(row.dateString(now: Date()))
                    }
                }
                .onDelete { indices in
                    indices.forEach {
                        debugPrint("\(#file) \(#function)")
                        self.rows.remove(at: $0) }
                }
            }
                .navigationBarTitle(Text("Date-O-Rama"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation {
                                debugPrint("\(#file) \(#function) + button, \(self.rows.count) rows before")
                                self.rows.insert(ASARow.generic(), at: 0)
                                debugPrint("\(#file) \(#function) + button, \(self.rows.count) rows after")
                            }
                        }
                    ) {
                        Image(systemName: "plus")
                    }
                )
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

//struct MasterView: View {
//    @Binding var rows:  Array<ASARow>
//
//    var body: some View {
//        List {
//            ForEach(rows, id:  \.uid) { row in
//                NavigationLink(
//                    destination: DetailView(selectedRow: row )
//                ) {
//                    Text(row.dateString(now: Date()))
//                }
//            }
//            .onDelete { indices in
//                indices.forEach {
//                    debugPrint("\(#file) \(#function)")
//                    self.rows.remove(at: $0) }
//            }
//        }
//    }
//}


struct ASADetailCell:  View {
    var title:  String
    var detail:  String
    var body:  some View {
        HStack {
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail)
        }
    }
}

struct ASADetail {
    var name:  String
    var geekCode:  String
}

struct DetailView: View {
    let details:  Array<ASADetail> = [
        ASADetail(name: "Era", geekCode: "GGGG"),
        ASADetail(name: "Calendar year", geekCode: "y"),
        ASADetail(name: "Month", geekCode: "MMMM"),
        ASADetail(name: "Day of month", geekCode: "d"),
        ASADetail(name: "Weekday", geekCode: "eeee"),
        ASADetail(name: "Quarter", geekCode: "QQQQ"),
        ASADetail(name: "Year (for “week of year”)", geekCode: "Y"),
        ASADetail(name: "Week of year", geekCode: "w"),
        ASADetail(name: "Week of month", geekCode: "W"),
        ASADetail(name: "Day of week in month", geekCode: "F"),
        ASADetail(name: "Day of year", geekCode: "D"),
        ASADetail(name: "Cyclic year name", geekCode: "UUUU"),
        ASADetail(name: "Related Gregorian year", geekCode: "r"),
        ASADetail(name: "Modified Julian day", geekCode: "g")    ]
    @State var selectedRow:  ASARow?
    
    var body: some View {
        List {
            if selectedRow != nil {
                Section(header:  Text("Row")) {
                    NavigationLink(destination: ASACalendarPickerView(row: selectedRow!)) {
                        ASADetailCell(title: "Calendar", detail: selectedRow!.calendarCode.localizedName())
                    }
                    NavigationLink(destination: ASALocalePickerView(localeIdentifier: selectedRow!.localeIdentifier)) {
                        ASADetailCell(title:  "Locale", detail: selectedRow!.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                    }
                }
                Section(header:  Text("Date")) {
                    ForEach(self.details, id: \.name) {
                        detail
                        in
                        HStack {
                            Text(verbatim:  detail.name).bold()
                            Spacer()
                            Text(verbatim:  (self.selectedRow?.dateString(now: Date(), LDMLString: detail.geekCode)) ?? "")
                        }
                    }
                }
            } else {
                Text("Detail view content goes here")
            }
        }.navigationBarTitle(                Text(selectedRow?.dateString(now: Date()) ?? "???"))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsView()
    }
}
