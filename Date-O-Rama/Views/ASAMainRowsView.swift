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
    @State var dummyRow:  ASARow = ASARow.generic()

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
            DetailView(selectedRow: self.dummyRow)
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
        ASADetail(name: "HEADER_G", geekCode: "GGGG"),
        ASADetail(name: "HEADER_y", geekCode: "y"),
        ASADetail(name: "HEADER_M", geekCode: "MMMM"),
        ASADetail(name: "HEADER_d", geekCode: "d"),
        ASADetail(name: "HEADER_E", geekCode: "eeee"),
        ASADetail(name: "HEADER_Q", geekCode: "QQQQ"),
        ASADetail(name: "HEADER_Y", geekCode: "Y"),
        ASADetail(name: "HEADER_w", geekCode: "w"),
        ASADetail(name: "HEADER_W", geekCode: "W"),
        ASADetail(name: "HEADER_F", geekCode: "F"),
        ASADetail(name: "HEADER_D", geekCode: "D"),
        ASADetail(name: "HEADER_U", geekCode: "UUUU"),
        ASADetail(name: "HEADER_r", geekCode: "r"),
        ASADetail(name: "HEADER_g", geekCode: "g")    ]
    
    @ObservedObject var selectedRow:  ASARow
    
    var body: some View {
        List {
            //            if selectedRow != nil {
            Section(header:  Text("Row")) {
                NavigationLink(destination: ASACalendarPickerView(row: self.selectedRow)) {
                    ASADetailCell(title: "Calendar", detail: self.selectedRow.calendarCode.localizedName())
                }
                NavigationLink(destination: ASALocalePickerView(row: selectedRow)) {
                    ASADetailCell(title:  "Locale", detail: selectedRow.localeIdentifier.asSelfLocalizedLocaleIdentifier())
                }
            }
            Section(header:  Text("Date")) {
                ForEach(self.details, id: \.name) {
                    detail
                    in
                    HStack {
                        Text(NSLocalizedString(detail.name, comment: "")).bold()
                        Spacer()
                        Text(verbatim:  (self.selectedRow.dateString(now: Date(), LDMLString: detail.geekCode)) )
                    }
                }
            }
            //            } else {
            //                Text("Detail view content goes here")
            //            }
        }.navigationBarTitle(Text(selectedRow.dateString(now: Date()) ))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAMainRowsView()
    }
}
