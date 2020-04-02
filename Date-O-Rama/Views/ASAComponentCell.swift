//
//  ASAComponentCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-01.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAComponentCell: View {
    let headerCode:  String
    let item: String
    
    @Binding var row: ASARow
    
    func selectedItem(row:  ASARow, headerCode:  String) -> String {
        let components = row.geekFormat.components(calendarCode: row.calendarCode)
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
            debugPrint("\(#file) \(#function) Geek format before = \(self.row.geekFormat)")
            var components = self.row.geekFormat.components(calendarCode: self.row.calendarCode)
            components[self.headerCode] = self.item
            let temp = self.row
            temp.geekFormat = String.geekFormat(components: components)
            self.row = temp
            debugPrint("\(#file) \(#function) Geek format after = \(self.row.geekFormat)")
        }
    }  // var body
} // struct ASAComponentCell

struct ASAComponentCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAComponentCell(headerCode: "E", item: "eee", row: .constant(ASARow.test()))
    }
}
