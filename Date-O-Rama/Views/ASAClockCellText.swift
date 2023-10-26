//
//  ASAClockCellText.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 27/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockCellText:  View {
    var string:  String
    var font:  Font
    var lineLimit:  Int

    var body: some View {
        #if os(watchOS)
        Text(verbatim:  string)
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(ASAScalable(lineLimit: 1))
        #else
        Text(verbatim:  string)
            .font(font)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .modifier(ASAScalable(lineLimit: lineLimit))
        #endif
    } // var body
} // struct ASAClockCellText

struct ASAClockCellText_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCellText(string: "99 Bottles of Beer on the Wall", font: .headline, lineLimit: 2)
    }
}
