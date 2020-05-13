//
//  ASARowChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASARowChooser: View {
    @Binding var selectedRow:  ASARow
    let mainRows = ASAUserData.shared().mainRows
    
    var body: some View {
        List {
            ForEach(mainRows) {
                row
                in
                ASARowCell(selectedRow: self.selectedRow, row: row).onTapGesture {
                    self.selectedRow = row
                }
            }
        }
    }
}

struct ASARowCell: View {
    @ObservedObject var selectedRow:  ASARow

    var row:  ASARow
    
    var body: some View {
        HStack {
            VStack {
                Text(verbatim:  row.calendar.calendarCode.localizedName())
                Text(verbatim: row.locationData.formattedOneLineAddress() )
            }
            Spacer()
            if selectedRow.uuid == self.row.uuid {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
//        .onTapGesture {
////            selectedRow = row
//        }
    }
}


struct ASARowChooser_Previews: PreviewProvider {
    static var previews: some View {
        ASARowChooser(selectedRow: .constant(ASARow.generic()))
    }
}
