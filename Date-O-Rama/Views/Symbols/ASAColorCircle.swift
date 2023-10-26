//
//  ASAColorCircle.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAColorCircle: View {
    var color: Color
    
    var body: some View {
        let CIRCLE_DIAMETER:  CGFloat = 8.0
        
        Circle()
            .foregroundColor(color)
            .frame(width: CIRCLE_DIAMETER, height: CIRCLE_DIAMETER)
    }
}


struct ASACalendarCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ASAColorCircle(color: .blue)
    }
}
