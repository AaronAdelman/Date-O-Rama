//
//  ASALocalePickerView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocalePickerView: View {
    let localeData = ASALocaleData()
    
    @State var localeIdentifier: String? = nil

    var body: some View {
        List {
            ForEach(localeData.records) { item in
                ASALocaleCell(localeString: item.id, localizedLocaleString: item.nativeName, selectedLocaleString: self.$localeIdentifier)
            } // ForEach(localeData.records)
        } // List
    } // var body
} // struct ASALocalePickerView

struct ASALocaleCell: View {
    let localeString: String
    let localizedLocaleString:  String
    
    @Binding var selectedLocaleString: String?
    
    var body: some View {
        HStack {
            Text(verbatim:  localizedLocaleString)
            Spacer()
            if localeString == selectedLocaleString {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
            self.selectedLocaleString = self.localeString
        }
    }
}

struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocalePickerView()
    }
}
