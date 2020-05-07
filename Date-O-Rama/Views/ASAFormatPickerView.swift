//
//  ASAFormatPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASAFormatPickerView: View {
    @ObservedObject var row:  ASARow
//    var deviceLocation:  CLLocation?
    
    var model:  Array<ASAComponentsPickerSection> {
        get {
            if self.row.calendar.calendarCode == ASACalendarCode.ISO8601 {
                return [
                    ASAComponentsPickerSection(headerCode: "y", items: ["", "yyyy"]),
                    ASAComponentsPickerSection(headerCode: "M", items: ["", "MM"]),
                    ASAComponentsPickerSection(headerCode: "w", items: ["", "ww"]),
                    ASAComponentsPickerSection(headerCode: "d", items: ["", "dd"]),
                    ASAComponentsPickerSection(headerCode: "-", items: ["", "-"])
                ]
            } else {
                return [
                    ASAComponentsPickerSection(headerCode: "E", items: ["", "eeeee", "eeeeee", "eee", "eeee", "e", "ee"
                    ]),
                    ASAComponentsPickerSection(headerCode: "y", items: ["", "y", "yy", "yyy", "yyyy"]),
                    ASAComponentsPickerSection(headerCode: "M", items: ["", "MMMMM", "MMM", "MMMM", "M", "MM"]),
                    ASAComponentsPickerSection(headerCode: "d", items: ["", "d", "dd"]),
                    ASAComponentsPickerSection(headerCode: "G", items: ["", "GGGGG", "G", "GGGG"]),
                    ASAComponentsPickerSection(headerCode: "Y", items: ["", "Y", "YY", "YYY", "YYYY"]),
                    ASAComponentsPickerSection(headerCode: "U", items: ["", "UUUUU", "U", "UUUU"]),
//                    ASAComponentsPickerSection(headerCode: "r", items: ["", "r", "rr", "rrr", "rrrr"]),
                    ASAComponentsPickerSection(headerCode: "Q", items: ["", "Q", "QQ", "QQQQQ", "QQQ", "QQQQ"]),
                    ASAComponentsPickerSection(headerCode: "w", items: ["", "w", "ww"]),
                    ASAComponentsPickerSection(headerCode: "W", items: ["", "W"]),
                    ASAComponentsPickerSection(headerCode: "D", items: ["", "D", "DD", "DDD"]),
                    ASAComponentsPickerSection(headerCode: "F", items: ["", "F"]),
//                    ASAComponentsPickerSection(headerCode: "g", items: ["", "g"])
                ]
            }
        } // get
    } // var model

    fileprivate func ComponentsForEach() -> ForEach<[ASAComponentsPickerSection], String, Section<Text, ForEach<[String], String, ASAComponentCell>, EmptyView>> {
        return ForEach(self.model, id:  \.headerCode) {
            section
            in
            Section(header: Text(verbatim:  section.localizedHeaderTitle())) {
                ForEach(section.items, id:  \.self) {
                    item
                    in
                    ASAComponentCell(headerCode: section.headerCode, item: item, row:  self.row)
                } // ForEach(section.items, id:  \.self)
            }
        }
    }
    
    var body: some View {
        List {
            if row.calendar.calendarCode == ASACalendarCode.ISO8601 {
                ComponentsForEach()
            } else {
                Section(header:  Text("HEADER_Date_format")) {
                    ASAMajorDateFormatCell(majorDateFormat: .full, row: row)
                    ASAMajorDateFormatCell(majorDateFormat: .long, row: row)
                    ASAMajorDateFormatCell(majorDateFormat: .medium, row: row)
                    ASAMajorDateFormatCell(majorDateFormat: .short, row: row)
                    ASAMajorDateFormatCell(majorDateFormat: .localizedLDML, row: row)
//                    ASAMajorDateFormatCell(majorDateFormat: .rawLDML, row: row)
                } // Section
                if row.majorDateFormat == .localizedLDML {
                    ComponentsForEach()
                }
//                if row.majorDateFormat == .rawLDML {
//                    Section(header:  Text("LDML")) {
//                        Text("Quux")
//                    }
//                }
            }
        }
        .navigationBarTitle(Text(row.dateTimeString(now: Date()) ))
    }
}

struct ASAMajorDateFormatCell: View {
    let majorDateFormat: ASAMajorDateFormat
    
    @ObservedObject var row:  ASARow

    var body: some View {
        HStack {
            Text(verbatim:  majorDateFormat.localizedItemName())
            Spacer()
            if majorDateFormat == self.row.majorDateFormat {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.row.majorDateFormat = self.majorDateFormat
        }
    }
} // struct ASAMajorDateFormatCell

struct ASAComponentCell: View {
    let headerCode:  String
    let item: String
    
    @ObservedObject var row: ASARow
    
    func selectedItem(row:  ASARow, headerCode:  String) -> String {
        let components = row.dateGeekFormat.components(calendarCode: row.calendar.calendarCode)
        let selection = components[headerCode]
        return selection ?? ""
    }
    
    var body: some View {
        HStack {
            Text(verbatim: NSLocalizedString("ITEM_\(headerCode)_\(item)", comment: ""))
            Spacer()
            if self.item == self.selectedItem(row: self.row, headerCode: headerCode) {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            debugPrint("\(#file) \(#function) Geek format before = \(self.row.dateGeekFormat)")
            var components = self.row.dateGeekFormat.components(calendarCode: self.row.calendar.calendarCode)
            components[self.headerCode] = self.item
            self.row.dateGeekFormat = String.geekFormat(components: components)
            debugPrint("\(#file) \(#function) Geek format after = \(self.row.dateGeekFormat)")
        }
    }  // var body
} // struct ASAComponentCell

struct ASAComponentsPickerSection {
    var headerCode:  String
    var items:  Array<String>
} // struct ASAComponentsPickerSection

extension ASAComponentsPickerSection {
    func localizedHeaderTitle() -> String {
        let sectionCode = self.headerCode
        let unlocalizedTitle = "HEADER_\(sectionCode)"
        let headerTitle = NSLocalizedString(unlocalizedTitle, comment: "")
        return headerTitle
    } // func localizedHeaderTitle() -> String
} // extension ASAComponentsPickerSection


struct ASAFormatPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASAFormatPickerView(row: ASARow.generic())
    }
}
