//
//  ASAComponentsPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-01.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI


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


// MARK : -

struct ASAComponentsPickerView: View {
    @State var row:         ASARow
        
    let PREVIEW_HEADER_CODE = "Preview"
    
    var model:  Array<ASAComponentsPickerSection> {
        get {
            if self.row.calendarCode == ASACalendarCode.ISO8601 {
                return [
                    ASAComponentsPickerSection(headerCode: PREVIEW_HEADER_CODE, items: ["Preview"]),
                    ASAComponentsPickerSection(headerCode: "y", items: ["", "yyyy"]),
                    ASAComponentsPickerSection(headerCode: "M", items: ["", "MM"]),
                    ASAComponentsPickerSection(headerCode: "w", items: ["", "ww"]),
                    ASAComponentsPickerSection(headerCode: "d", items: ["", "dd"]),
                    ASAComponentsPickerSection(headerCode: "-", items: ["", "-"])
                ]
            } else {
                return [
                    ASAComponentsPickerSection(headerCode: "Preview", items: ["Preview"]),
                    ASAComponentsPickerSection(headerCode: "E", items: ["", "eeeee", "eeeeee", "eee", "eeee", "e", "ee"
                    ]),
                    ASAComponentsPickerSection(headerCode: "y", items: ["", "y", "yy", "yyy", "yyyy"]),
                    ASAComponentsPickerSection(headerCode: "M", items: ["", "MMMMM", "MMM", "MMMM", "M", "MM"]),
                    ASAComponentsPickerSection(headerCode: "d", items: ["", "d", "dd"]),
                    ASAComponentsPickerSection(headerCode: "G", items: ["", "GGGGG", "G", "GGGG"]),
                    ASAComponentsPickerSection(headerCode: "Y", items: ["", "Y", "YY", "YYY", "YYYY"]),
                    ASAComponentsPickerSection(headerCode: "U", items: ["", "UUUUU", "U", "UUUU"]),
                    ASAComponentsPickerSection(headerCode: "r", items: ["", "r", "rr", "rrr", "rrrr"]),
                    ASAComponentsPickerSection(headerCode: "Q", items: ["", "Q", "QQ", "QQQQQ", "QQQ", "QQQQ"]),
                    ASAComponentsPickerSection(headerCode: "w", items: ["", "w", "ww"]),
                    ASAComponentsPickerSection(headerCode: "W", items: ["", "W"]),
                    ASAComponentsPickerSection(headerCode: "D", items: ["", "D", "DD", "DDD"]),
                    ASAComponentsPickerSection(headerCode: "F", items: ["", "F"]),
                    ASAComponentsPickerSection(headerCode: "g", items: ["", "g"])
                ]
            }
        } // get
    } // var model
    
    func previewDateString() -> String {
        self.row.majorDateFormat = .localizedLDML
        
        let now = Date()
        let dateString = self.row.dateString(now: now)
        return dateString
    } // func previewDateString() -> String
    
    var body: some View {
        List {
            ForEach(self.model, id:  \.headerCode) {
                section
                in
                Section(header: Text(verbatim:  section.localizedHeaderTitle())) {
                    if section.headerCode == self.PREVIEW_HEADER_CODE {
                        Text(self.previewDateString())
                    } else {
                        ForEach(section.items, id:  \.self) {
                            item
                            in
                            ASAComponentCell(headerCode: section.headerCode, item: item, row:  self.$row)
                        } // ForEach(section.items, id:  \.self)
                    }
                }
            }
        } // List
    } // var body
}

struct ASAComponentsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASAComponentsPickerView(row:  ASARow.test())
    }
}
