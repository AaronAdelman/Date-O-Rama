//
//  ASACalendarDetailCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarDetailCell:  View {
    var title:  String
    var detail:  String
    var systemIconName:  String?
    
    var body:  some View {
        HStack {
            if systemIconName != nil {
                Image(systemName: systemIconName!)
            }
            Text(verbatim:  title).bold()
            Spacer()
            Text(verbatim:  detail).multilineTextAlignment(.trailing)
        } // HStack
    } // var body
} // struct ASACalendarDetailCell

struct ASACalendarDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailCell(title: "Blah", detail: "Blah")
    }
}
