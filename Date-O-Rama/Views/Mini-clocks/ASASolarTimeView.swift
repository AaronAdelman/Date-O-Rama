//
//  ASASolarTimeView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASASolarTimeView: View {
    @State private var maskedRectScalesAlong = false
    var degrees: Double
    var dimension: CGFloat
    //    let CIRCLE_WIDTH: CGFloat = 10.0
    var font: Font
    
    
    private let VERTICAL_FUDGE: CGFloat = 12.0
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: VERTICAL_FUDGE)
            
            ZStack {
                let LINE_WIDTH: CGFloat = 2.0
                
                Circle()  // Circular path: Dotted semicircle
                    .trim(from: 1/2, to: LINE_WIDTH)
                    //                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [7, 7]))
                    .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH, dash: [2, 2]))
                    .frame(width:   dimension, height: dimension)
                
                Image(systemName: "sun.max.fill")  // Sun symbol
                    .font(font)
                    .offset(x: -dimension / 2.0)
                    .rotationEffect(.degrees(degrees))
                
                //            ZStack {
                //                Rectangle() // Masked to parent
                //                    .frame(width:   dimension, height: dimension / 2.0)
                //                    .opacity(0.1)
                //                    .scaleEffect(x: maskedRectScalesAlong ? 0.9 : 0, y: 1, anchor: .leading)
                //                    .offset(y: (-dimension / 4.0))
                //                    .onAppear(){
                //                        self.maskedRectScalesAlong.toggle()
                //                    }
                //
                //            }.frame(width: dimension, height: dimension)
                //            .clipShape(Circle())  // Mask to bounds + mask to parent
                
                Rectangle()  // X-axis
                    .frame(width: 4.0 * dimension / 3.0, height: LINE_WIDTH)
                    .opacity(0.5)
                
                //            Circle() // Point Left
                //                .frame(width: CIRCLE_WIDTH, height: 10)
                //                .offset(x: (-dimension / 2.0))
                //
                //            Circle() // Point Right
                //                .frame(width: CIRCLE_WIDTH, height: 10)
                //                .offset(x: dimension / 2.0)
            }
            
            Spacer()
                .frame(height: VERTICAL_FUDGE)
        } // VStack
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct ASASolarTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ASASolarTimeView(degrees: 48.0, dimension: 48.0, font: .body)
    }
}
