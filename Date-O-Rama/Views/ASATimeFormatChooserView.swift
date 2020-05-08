//
//  ASATimeFormatChooserView.swift
//  Time-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-07.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASATimeFormatChooserView: View {
    @ObservedObject var row:  ASARow
    
    var model:  Array<ASAComponentsPickerSection> = [
        ASAComponentsPickerSection(headerCode: "a", items: ["", "a", "aaaa", "aaaaa", "b", "bbbb", "bbbbb", "B", "BBBB", "BBBBB"]),
    ASAComponentsPickerSection(headerCode: "H", items: [
//        "",
                                                        "h", "hh", "H", "HH", "k", "kk", "K", "KK"]),
        ASAComponentsPickerSection(headerCode: "m", items: [
//            "",
            "m", "mm"]),
        ASAComponentsPickerSection(headerCode: "s", items: ["", "s", "ss"])
    ]
    
    fileprivate func ComponentsForEach() -> ForEach<[ASAComponentsPickerSection], String, Section<Text, ForEach<[String], String, ASATimeFormatComponentCell>, EmptyView>> {
        return ForEach(self.model, id:  \.headerCode) {
            section
            in
            Section(header: Text(verbatim:  section.localizedHeaderTitle())) {
                ForEach(section.items, id:  \.self) {
                    item
                    in
                    ASATimeFormatComponentCell(headerCode: section.headerCode, item: item, row:  self.row)
                } // ForEach(section.items, id:  \.self)
            }
        }
    }
    
    var body: some View {
        List {
            Section(header:  Text("HEADER_Time_format")) {
                ForEach(row.calendar.supportedMajorTimeFormats, id: \.self) {
                    format
                    in
                    ASAMajorTimeFormatCell(majorTimeFormat: format, row: self.row)
                }
            } // Section
            if row.majorTimeFormat == .localizedLDML {
                ComponentsForEach()
            }
        } // List
            .navigationBarTitle(Text(row.timeString(now: Date()) ))
    }
}


// MARK: -

struct ASAMajorTimeFormatCell: View {
    let majorTimeFormat: ASAMajorTimeFormat
    
    @ObservedObject var row:  ASARow
    
    var body: some View {
        HStack {
            Text(verbatim:  majorTimeFormat.localizedItemName())
            Spacer()
            if majorTimeFormat == self.row.majorTimeFormat {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.row.majorTimeFormat = self.majorTimeFormat
        }
    }
} // struct ASAMajorTimeFormatCell


// MARK: -

struct ASATimeFormatComponentCell: View {
    let headerCode:  String
    let item: String
    
    @ObservedObject var row: ASARow
    
    func selectedItem(row:  ASARow, headerCode:  String) -> String {
        let components = row.timeGeekFormat.timeComponents(calendarCode: row.calendar.calendarCode)
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
            debugPrint("\(#file) \(#function) Geek format before = \(self.row.timeGeekFormat)")
            var components = self.row.timeGeekFormat.timeComponents(calendarCode: self.row.calendar.calendarCode)
            components[self.headerCode] = self.item
            self.row.timeGeekFormat = String.geekFormat(components: components)
            debugPrint("\(#file) \(#function) Geek format after = \(self.row.timeGeekFormat)")
        }
    }  // var body
} // struct ASATimeFormatComponentCell





// MARK: -

struct ASATimeFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeFormatChooserView(row: ASARow.generic())
    }
}
