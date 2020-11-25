//
//  ASALocaleChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

let ALL_LOCALES            = 0
let APPLE_LOCALES          = 1
let USERS_LANGUAGE_LOCALES = 2
let USERS_REGION_LOCALES   = 3

fileprivate extension Int {
    var localeCategoryText:  String {
        get {
            switch self {
            case ALL_LOCALES:
                return NSLocalizedString("All locales", comment: "")

            case APPLE_LOCALES:
                return NSLocalizedString("All locales", comment: "")

            case USERS_LANGUAGE_LOCALES:
                return NSLocalizedString("User’s language locales", comment: "")

            case USERS_REGION_LOCALES:
                return NSLocalizedString("User’s region locales", comment: "")

            default:
                return ""
            }
        } // get
    } // var calendarCategoryText:  String
} // extension Int


struct ASALocaleChooserView: View {
    let localeData = ASALocaleData()
    
    @ObservedObject var row:  ASALocatedObject
    
    @State var tempLocaleIdentifier:  String
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    @State var providedLocaleIdentifiers:  Array<String>?

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
                HStack {
                    Picker(selection: $selection, label:
                            Text("Show locales:"), content: {
                                Text("All locales").tag(ALL_LOCALES)
                                Text("Apple locales").tag(APPLE_LOCALES)
                                Text("User’s language locales").tag(USERS_LANGUAGE_LOCALES)
                                Text("User’s region locales").tag(USERS_REGION_LOCALES)
                            }).pickerStyle(MenuPickerStyle())

                    Spacer()

                    Text(verbatim: self.selection.localeCategoryText)
                }
            }
            
            ForEach(self.locales(option: selection)) { item in
                ASALocaleCell(localeString: item.id, localizedLocaleString: item.nativeName, tempLocaleIdentifier: self.$tempLocaleIdentifier)
            } // ForEach(localeData.records)
        } // List
        //            .navigationBarTitle(Text(row.dateString(now: Date()) ))
        .navigationBarItems(trailing:
                                Button("Cancel", action: {
                                    self.didCancel = true
                                    self.presentationMode.wrappedValue.dismiss()
                                })
        )
        .onAppear() {
            self.tempLocaleIdentifier = self.row.localeIdentifier
        }
        .onDisappear() {
            if !self.didCancel {
                self.row.localeIdentifier = self.tempLocaleIdentifier
            }
        }
    } // var body
} // struct ASALocalePickerView

struct ASALocaleCell: View {
    let localeString: String
    let localizedLocaleString:  String
    
    //    @ObservedObject var row:  ASARow
    //    @ObservedObject var row:  ASALocatedObject
    @Binding var tempLocaleIdentifier:  String
    
    var body: some View {
        HStack {
            Text(verbatim: localeString.localeCountryCodeFlag())
            Text(verbatim:  localizedLocaleString)
            Spacer()
            if localeString == self.tempLocaleIdentifier {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            self.tempLocaleIdentifier = self.localeString
        }
    }
}

struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocaleChooserView(row: ASARow.test(), tempLocaleIdentifier: "en_US")
    }
}

