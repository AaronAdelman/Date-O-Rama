//
//  ASAThreeLineLargeView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/06/2024.
//  Copyright © 2024 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAThreeLineLargeView:  View {
    var line0:  String
    var line1:  String
    var line2:  String

    var body: some View {
        VStack(alignment:  .center) {
            ASAClockCellText(string: line0, font: .headline, lineLimit: 1)
            ASAClockCellText(string: line1, font: .headline, lineLimit: 1)
            ASAClockCellText(string: line2, font: .headline, lineLimit: 1)
        } // VStack
    } // var body
} // struct ASAThreeLineLargeView

#Preview {
    ASAThreeLineLargeView(line0: "יום ב׳, י״א בסיון תשפ״ד", line1: "Monday, 17 June 2024", line2: "Septidi 27 Prairial An 232")
}
