//
//  ASARowChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASARowChooser: View {
    @Binding var selectedUUIDString:  String
    let mainRows = ASAUserData.shared.mainRows
    
    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var body: some View {
        List {
            ForEach(mainRows) {
                row
                in
                ASARowCell(selectedUUIDString: self.$selectedUUIDString, row: row)
                    .onTapGesture {
                        self.selectedUUIDString = row.uuid.uuidString
                        self.dismiss()
                    }
            }
        }
    }
}

struct ASARowCell: View {
    @Binding var selectedUUIDString:  String

    var row:  ASARow
    
    var body: some View {
        HStack {
            VStack(alignment:  .leading) {
                Text(verbatim:  row.calendar.calendarCode.localizedName).font(.headline)
                HStack {
                    if row.usesDeviceLocation {
                        ASALocationSymbol()
                    }
                    Text(verbatim:  row.regionCodeEmoji(date:  Date()))
                    Text(verbatim: row.locationData.formattedOneLineAddress).font(.subheadlineMonospacedDigit)
                }
            }
            Spacer()
            if selectedUUIDString == self.row.uuid.uuidString {
                ASACheckmarkSymbol()
            }
        }
    }
}


struct ASARowChooser_Previews: PreviewProvider {
    static var previews: some View {
        ASARowChooser(selectedUUIDString: .constant(UUID().uuidString))
    }
}
