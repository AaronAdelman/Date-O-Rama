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

    var body: some View {
        #if os(watchOS)
        Text(verbatim:  string)
            .font(font)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
            .allowsTightening(true)
        #else
        Text(verbatim:  string)
            .font(font)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .allowsTightening(true)
        #endif
    } // var body
} // struct ASAClockCellText

struct ASAClockCellText_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCellText(string: "99 Bottles of Beer on the Wall", font: .headline)
    }
}
