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
    var isForClock:  Bool

    var body:  some View {
        let pastCutoffDate: Bool = cutoffDate < Date()
        let foregroundColor: Color = pastCutoffDate ? .secondary : .primary
        
        #if os(watchOS)
        Text(verbatim:  verbatim)
            .font(timeFontSize)
            .foregroundColor(foregroundColor)
            .modifier(ASAScalable(lineLimit: 1))
        #else
        Text(verbatim:  verbatim)
            .frame(width:  timeWidth)
            .font(timeFontSize)
            .foregroundColor(foregroundColor)
            .modifier(ASAScalable(lineLimit: 2))
        #endif
    } // var body
} // struct ASATimesText


//struct ASATimeText_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimeText()
//    }
//}
