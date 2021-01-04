//
//  ASATimeText.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATimeText:  View {
    var verbatim:  String
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var cutoffDate:  Date
    var labelColor:  Color

    var body:  some View {
        Text(verbatim:  verbatim)
            .lineLimit(2)
            .frame(width:  timeWidth)
            .font(timeFontSize)
            .foregroundColor(labelColor.grayIfBefore(cutoffDate))
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
    } // var body
} // struct ASATimesText


//struct ASATimeText_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimeText()
//    }
//}
