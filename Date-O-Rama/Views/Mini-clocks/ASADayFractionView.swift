//
//  ASADayFractionView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/07/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASADayFractionView: View {
    var progress: Double
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var julianDayWidth:  CGFloat {
        get {
            if self.sizeClass! == .compact {
                return 128.0
            } else {
                return 256.0
            }
        } // get
    } // var julianDayWidth
    
    var body: some View {        
        #if targetEnvironment(macCatalyst)
        let verticalInset: CGFloat = -5.0
        #else
        let verticalInset: CGFloat =  1.0
        #endif
        ProgressView(value: progress)
            .accentColor(Color("julianDayForeground"))
            .frame(maxWidth:  julianDayWidth)
            .modifier(ASACapsuleBorder(topInset: verticalInset, leadingInset: 1.0, bottomInset: verticalInset, trailingInset: 1.0, color: Color("julianDayBorder"), width: 1.0))    }
}

struct ASADayFractionView_Previews: PreviewProvider {
    static var previews: some View {
        ASADayFractionView(progress: 0.5)
    }
}
