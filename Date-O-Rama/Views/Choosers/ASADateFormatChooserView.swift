//
//  ASADateFormatChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASADateFormatChooserView: View {
    @ObservedObject var row:  ASARow

    @State var tempMajorDateFormat:  ASAMajorDateFormat
    @State var tempDateGeekFormat:  String
    @State var calendarCode:  ASACalendarCode

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false

    
    var model:  Array<ASAComponentsPickerSection> = [
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
    
    fileprivate func ComponentsForEach() -> ForEach<[ASAComponentsPickerSection], String, Section<Text, ForEach<[String], String, ASADateFormatComponentCell>, EmptyView>> {
        return ForEach(self.model, id:  \.headerCode) {
            section
            in
            Section(header: Text(verbatim:  section.localizedHeaderTitle())) {
                ForEach(section.items, id:  \.self) {
                    item
                    in
                    ASADateFormatComponentCell(headerCode: section.headerCode, item: item, calendarCode:  self.calendarCode, selectedDateGeekFormat: self.$tempDateGeekFormat)
                } // ForEach(section.items, id:  \.self)
            }
        }
    }
    
    var body: some View {
        List {
            Section(header:  Text("HEADER_Date_format")) {
                ForEach(row.calendar.supportedMajorDateFormats, id: \.self) {
                    format
                    in
                    ASAMajorDateFormatCell(majorDateFormat: format, selectedMajorDateFormat: self.$tempMajorDateFormat)
                }
            } // Section
            if tempMajorDateFormat == .localizedLDML {
                ComponentsForEach()
            }
        } // List
        .navigationBarItems(trailing:
            Button("Cancel", action: {
                self.didCancel = true
                self.presentationMode.wrappedValue.dismiss()
            })
        )
            .onAppear() {
                self.tempMajorDateFormat = self.row.majorDateFormat
                self.tempDateGeekFormat  = self.row.dateGeekFormat
                self.calendarCode        = self.row.calendar.calendarCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.row.majorDateFormat = self.tempMajorDateFormat
                self.row.dateGeekFormat  = self.tempDateGeekFormat
                }
            }
    }
}


// MARK: -

struct ASAMajorDateFormatCell: View {
    let majorDateFormat: ASAMajorDateFormat
    
    @Binding var selectedMajorDateFormat:  ASAMajorDateFormat
    
    var body: some View {
        HStack {
            Text(verbatim:  majorDateFormat.localizedItemName())
            Spacer()
            if majorDateFormat == self.selectedMajorDateFormat {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.selectedMajorDateFormat = self.majorDateFormat
        }
    }
} // struct ASAMajorDateFormatCell


// MARK: -

struct ASADateFormatComponentCell: View {
    let headerCode:  String
    let item: String
    let calendarCode:  ASACalendarCode
    
    @Binding var selectedDateGeekFormat:  String
    
    func selectedItem(selectedDateGeekFormat:  String, headerCode:  String) -> String {
        let components = selectedDateGeekFormat.dateComponents(calendarCode: calendarCode)
        let selection = components[headerCode]
        return selection ?? ""
    }
    
    var body: some View {
        HStack {
            Text(verbatim: NSLocalizedString("ITEM_\(headerCode)_\(item)", comment: ""))
            Spacer()
            if self.item == self.selectedItem(selectedDateGeekFormat: self.selectedDateGeekFormat, headerCode: headerCode) {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            debugPrint("\(#file) \(#function) Geek format before = \(self.selectedDateGeekFormat)")
            var components = self.selectedDateGeekFormat.dateComponents(calendarCode:  self.calendarCode)
            components[self.headerCode] = self.item
            self.selectedDateGeekFormat = String.geekFormat(components: components)
            debugPrint("\(#file) \(#function) Geek format after = \(self.selectedDateGeekFormat)")
        }
    }  // var body
} // struct ASAComponentCell


// MARK: -

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


// MARK: -

struct ASADateFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASADateFormatChooserView(row: ASARow.generic(), tempMajorDateFormat: .full, tempDateGeekFormat: "yyyy", calendarCode: .Gregorian)
    }
}
