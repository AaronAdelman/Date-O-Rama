//
//  ASALocaleChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASALocaleChooserView: View {
    let localeData = ASALocaleData()
    
    @ObservedObject var row:  ASALocatedObject
    @State var providedLocaleIdentifiers:  Array<String>?
    
    let ALL_LOCALES            = 0
    let APPLE_LOCALES          = 1
    let USERS_LANGUAGE_LOCALES = 2
    let USERS_REGION_LOCALES   = 3

    @State var selection = 0 // All locales
    
    func locales(option:  Int) -> Array<ASALocaleRecord> {
        if providedLocaleIdentifiers != nil {
            let result: [ASALocaleRecord] = self.localeData.defaultLocaleRecords() +  self.localeData.sortedLocalizedRecords(identifiers:  providedLocaleIdentifiers!)
            return result
        }

        switch selection {
        case ALL_LOCALES:
            return self.localeData.allRecords
            
        case APPLE_LOCALES:
            return self.localeData.standardLocaleRecords
            
        case USERS_LANGUAGE_LOCALES:
            return self.localeData.recordsForUsersLanguage
            
        case USERS_REGION_LOCALES:
            return self.localeData.recordsForUsersRegion
            
        default:
            return []
        } // switch selection
    } // func locales(option:  Int) -> Array<ASALocaleRecord>
    
    var body: some View {
        List {
            if providedLocaleIdentifiers == nil {
            Picker(selection: $selection, label:
                Text("Show locales:"), content: {
                    Text("All locales").tag(ALL_LOCALES)
                    Text("Apple locales").tag(APPLE_LOCALES)
                    Text("User’s language locales").tag(USERS_LANGUAGE_LOCALES)
                    Text("User’s region locales").tag(USERS_REGION_LOCALES)
            })
            }

            ForEach(self.locales(option: selection)) { item in
                ASALocaleCell(localeString: item.id, localizedLocaleString: item.nativeName, row: self.row)
            } // ForEach(localeData.records)
        } // List
//            .navigationBarTitle(Text(row.dateString(now: Date()) ))
    } // var body
} // struct ASALocalePickerView

struct ASALocaleCell: View {
    let localeString: String
    let localizedLocaleString:  String
    
//    @ObservedObject var row:  ASARow
    @ObservedObject var row:  ASALocatedObject

    var body: some View {
        HStack {
            Text(verbatim: localeString.localeCountryCodeFlag())
            Text(verbatim:  localizedLocaleString)
            Spacer()
            if localeString == self.row.localeIdentifier {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            self.row.localeIdentifier = self.localeString
        }
    }
}

struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocaleChooserView(row: ASARow.test())
    }
}

