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

    @State var tempMajorTimeFormat:  ASATimeFormat
//    @State var tempTimeGeekFormat:  String
    @State var calendarCode:  ASACalendarCode

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    var model:  Array<ASAComponentsPickerSection> = [
        ASAComponentsPickerSection(headerCode: "a", items: ["", "a", "aaaa", "aaaaa", "b", "bbbb", "bbbbb", "B", "BBBB", "BBBBB"]),
        ASAComponentsPickerSection(headerCode: "H", items: [
            //        "",
            "h", "hh", "H", "HH", "k", "kk", "K", "KK"]),
        ASAComponentsPickerSection(headerCode: "m", items: [
            //            "",
            "m", "mm"]),
        ASAComponentsPickerSection(headerCode: "s", items: ["", "s", "ss"]),
        ASAComponentsPickerSection(headerCode: "z", items: ["", "z", "zzzz", "O", "OOOO", "v", "vvvv", "V", "VV", "VVV", "VVVV", "X", "XX", "XXX", "XXXX", "XXXXX", "x", "xx", "xxx", "xxxx", "xxxxx"])
    ]
    
//    fileprivate func ComponentsForEach() -> ForEach<[ASAComponentsPickerSection], String, Section<Text, ForEach<[String], String, ASATimeFormatComponentCell>, EmptyView>> {
//        return ForEach(self.model, id:  \.headerCode) {
//            section
//            in
//            Section(header: Text(verbatim:  section.localizedHeaderTitle())) {
//                ForEach(section.items, id:  \.self) {
//                    item
//                    in
//                    ASATimeFormatComponentCell(headerCode: section.headerCode, item: item, calendarCode: self.calendarCode, selectedTimeGeekFormat: self.$tempTimeGeekFormat)
//                } // ForEach(section.items, id:  \.self)
//            }
//        }
//    }
    
    var body: some View {
        List {
            Section(header:  Text("HEADER_Time_format")) {
                ForEach(row.calendar.supportedMajorTimeFormats, id: \.self) {
                    format
                    in
                    ASAMajorTimeFormatCell(timeFormat: format, selectedMajorTimeFormat: self.$tempMajorTimeFormat)
                }
            } // Section
//            if self.tempMajorTimeFormat == .localizedLDML {
//                ComponentsForEach()
//            }
        } // List
            .navigationBarItems(trailing:
                Button("Cancel", action: {
                    self.didCancel = true
                    self.presentationMode.wrappedValue.dismiss()
                })
        )
            .onAppear() {
                self.tempMajorTimeFormat = self.row.timeFormat
//                self.tempTimeGeekFormat  = self.row.timeGeekFormat
                self.calendarCode        = self.row.calendar.calendarCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.row.timeFormat = self.tempMajorTimeFormat
//                self.row.timeGeekFormat  = self.tempTimeGeekFormat
            }
        }
    }
}


// MARK: -

struct ASAMajorTimeFormatCell: View {
    let timeFormat: ASATimeFormat
    
    @Binding var selectedMajorTimeFormat:  ASATimeFormat

    var body: some View {
        HStack {
            Text(verbatim:  timeFormat.localizedItemName())
            Spacer()
            if timeFormat == self.selectedMajorTimeFormat {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.selectedMajorTimeFormat = self.timeFormat
        }
    }
} // struct ASAMajorTimeFormatCell


// MARK: -

//struct ASATimeFormatComponentCell: View {
//    let headerCode:  String
//    let item: String
//    let calendarCode:  ASACalendarCode
//
//    @Binding var selectedTimeGeekFormat:  String
//
//    func selectedItem(selectedTimeGeekFormat:  String, headerCode:  String) -> String {
//        let components = selectedTimeGeekFormat.timeComponents(calendarCode: self.calendarCode)
//        let selection = components[headerCode]
//        return selection ?? ""
//    }
//
//    var body: some View {
//        HStack {
//            Text(verbatim: NSLocalizedString("ITEM_\(headerCode)_\(item)", comment: ""))
//            Spacer()
//            if self.item == self.selectedItem(selectedTimeGeekFormat: self.selectedTimeGeekFormat, headerCode: headerCode) {
//                Image(systemName: "checkmark")
//                    .foregroundColor(.accentColor)
//            }
//        }
//        .onTapGesture {
//            //            debugPrint("\(#file) \(#function) Geek format before = \(self.row.timeGeekFormat)")
//            var components = self.selectedTimeGeekFormat.timeComponents(calendarCode: self.calendarCode)
//            components[self.headerCode] = self.item
//            self.selectedTimeGeekFormat = String.geekFormat(components: components)
//            //            debugPrint("\(#file) \(#function) Geek format after = \(self.row.timeGeekFormat)")
//        }
//    }  // var body
//} // struct ASATimeFormatComponentCell


// MARK: -

struct ASATimeFormatChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASATimeFormatChooserView(row: ASARow.generic(), tempMajorTimeFormat: .medium,
//                                 tempTimeGeekFormat: "HHmmss",
                                 calendarCode: .Gregorian)
    }
}
