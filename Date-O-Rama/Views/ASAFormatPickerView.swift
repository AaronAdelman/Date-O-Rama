//
//  ASAFormatPickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAFormatPickerView: View {
    @ObservedObject var row:  ASARow

    var body: some View {
        List {
            Section(header:  Text("HEADER_Format")) {
                ASAMajorDateFormatCell(majorDateFormat: .full, row: row)
                ASAMajorDateFormatCell(majorDateFormat: .long, row: row)
                ASAMajorDateFormatCell(majorDateFormat: .medium, row: row)
                ASAMajorDateFormatCell(majorDateFormat: .short, row: row)
                ASAMajorDateFormatCell(majorDateFormat: .localizedLDML, row: row)
                ASAMajorDateFormatCell(majorDateFormat: .rawLDML, row: row)
            } // Section
        }
        .navigationBarTitle(Text(row.dateString(now: Date()) ))
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

struct ASAFormatPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASAFormatPickerView(row: ASARow.generic())
    }
}
