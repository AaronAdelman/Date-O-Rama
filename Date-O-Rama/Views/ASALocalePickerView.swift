//
//  ASALocalePickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASALocalePickerView: View {
    let localeData = ASALocaleData()
    
    @ObservedObject var row:  ASARow
    var currentLocation:  CLLocation
    
    var body: some View {
        List {
            ForEach(localeData.records) { item in
                ASALocaleCell(localeString: item.id, localizedLocaleString: item.nativeName, row: self.row)
            } // ForEach(localeData.records)
        } // List
            .navigationBarTitle(Text(row.dateString(now: Date(), defaultLocation: self.currentLocation) ))
    } // var body
} // struct ASALocalePickerView

struct ASALocaleCell: View {
    let localeString: String
    let localizedLocaleString:  String
    
    @ObservedObject var row:  ASARow

    var body: some View {
        HStack {
            Text(verbatim: localeString.localeCountryCodeFlag())
            Text(verbatim:  localizedLocaleString)
            Spacer()
            if localeString == self.row.localeIdentifier {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.row.localeIdentifier = self.localeString
        }
    }
}

struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocalePickerView(row: ASARow.test(), currentLocation: CLLocation(latitude: 0.0, longitude: 0.0))
    }
}

