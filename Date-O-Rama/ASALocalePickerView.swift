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


struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocalePickerView()
    }
}
