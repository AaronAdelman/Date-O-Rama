//
//  ASAMainRowsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


struct ASAMainRowsView: View {
    @State var mainRows:  Array<ASARow> = [ASARow.test()]

    var body: some View {
        NavigationView {
            MasterView(rows: self.$mainRows)
                .navigationBarTitle(Text("Date-O-Rama"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation {
                                debugPrint("\(#file) \(#function) + button, \(self.mainRows.count) rows before")
                                self.mainRows.insert(ASARow.generic(), at: 0)
                                debugPrint("\(#file) \(#function) + button, \(self.mainRows.count) rows after")
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

struct MasterView: View {
    @Binding var rows:  Array<ASARow>
    
    var body: some View {
        List {
            ForEach(rows, id:  \.uid) { row in
                NavigationLink(
                    destination: DetailView(selectedRow: row )
                ) {
                    Text(row.dateString(now: Date()))
                }
            }.onDelete { indices in
                indices.forEach {
                    debugPrint("\(#file) \(#function)")
                    self.rows.remove(at: $0) }
            }
        }
    }
}


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

struct DetailView: View {
    var selectedRow:  ASARow?

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
                    Group {
                        ASADetailCell(title: "Era", detail: selectedRow!.dateString(now: Date(), LDMLString: "GGGG"))
                        
                        ASADetailCell(title: "Calendar year", detail: selectedRow!.dateString(now: Date(), LDMLString: "y"))
                        ASADetailCell(title: "Month", detail: selectedRow!.dateString(now: Date(), LDMLString: "MMMM"))
                        ASADetailCell(title: "Day of month", detail: selectedRow!.dateString(now: Date(), LDMLString: "d"))
                        ASADetailCell(title: "Weekday", detail: selectedRow!.dateString(now: Date(), LDMLString: "eeee"))
                    }
                    Group {
                        ASADetailCell(title: "Quarter", detail: selectedRow!.dateString(now: Date(), LDMLString: "QQQQ"))
                        
                        ASADetailCell(title: "Year (for “week of year”)", detail: selectedRow!.dateString(now: Date(), LDMLString: "Y"))
                        ASADetailCell(title: "Week of year", detail: selectedRow!.dateString(now: Date(), LDMLString: "w"))
                        
                        ASADetailCell(title: "Week of month", detail: selectedRow!.dateString(now: Date(), LDMLString: "W"))
                        ASADetailCell(title: "Day of week in month", detail: selectedRow!.dateString(now: Date(), LDMLString: "F"))
                        
                        ASADetailCell(title: "Day of year", detail: selectedRow!.dateString(now: Date(), LDMLString: "D"))
                        
                        ASADetailCell(title: "Cyclic year name", detail: selectedRow!.dateString(now: Date(), LDMLString: "UUUU"))
                        
                        ASADetailCell(title: "Related Gregorian year", detail: selectedRow!.dateString(now: Date(), LDMLString: "r"))
                        
                        ASADetailCell(title: "Modified Julian day", detail: selectedRow!.dateString(now: Date(), LDMLString: "g"))
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
