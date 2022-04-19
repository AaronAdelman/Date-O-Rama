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
    
    #if os(watchOS)
    let compact = true
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif

    var body:  some View {
        let pastCutoffDate: Bool = cutoffDate < Date()
        let foregroundColor: Color = pastCutoffDate ? .secondary : .primary
        
        #if os(watchOS)
        Text(verbatim:  verbatim)
            .font(timeFontSize)
            .foregroundColor(foregroundColor)
            .modifier(ASAScalable(lineLimit: 1))
        #else
        if compact {
        Text(verbatim:  verbatim)
            .frame(width:  timeWidth)
            .font(timeFontSize)
            .foregroundColor(foregroundColor)
            .modifier(ASAScalable(lineLimit: 2))
            .multilineTextAlignment(.leading)
        } else {
            Text(verbatim:  verbatim)
                .font(timeFontSize)
                .foregroundColor(foregroundColor)
                .modifier(ASAScalable(lineLimit: 2))
                .multilineTextAlignment(.leading)
        }
        #endif
    } // var body
} // struct ASATimesText


//struct ASATimeText_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimeText()
//    }
//}
