//
//  ASACapsuleBorder.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

struct ASACapsuleBorder: ViewModifier {
    var topInset:  CGFloat
    var leadingInset:  CGFloat
    var bottomInset:  CGFloat
    var trailingInset:  CGFloat
    var color:  Color
    var width:  CGFloat

    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: topInset, leading: leadingInset, bottom: bottomInset, trailing: trailingInset))
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: width)
            )    }
}
