//
//  Line.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 19/04/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

// From https://stackoverflow.com/questions/58526632/swiftui-create-a-single-dashed-line-with-swiftui
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
