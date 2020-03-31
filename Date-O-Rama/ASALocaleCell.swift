//
//  ASALocaleCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

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

struct ASALocaleCell_Previews: PreviewProvider {
    static var previews: some View {
        ASALocaleCell(localeString: "he_IL", localizedLocaleString:  "עברית (ישראל)", selectedLocaleString: .constant("en_US"))
    }
}
