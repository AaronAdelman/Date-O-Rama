//
//  ASADatePicker.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASADatePicker:  View {
    let BOTTOM_BUTTONS_FONT_SIZE = Font.title

    @Binding var date:  Date {
        didSet {

        } // didSet
    } // var date
    @ObservedObject var primaryRow:  ASARow {
        didSet {

        } // didSet
    } // var primaryRow

    var body: some View {
        HStack {

            Spacer()

            Button(action: {
                self.date = self.date.oneDayBefore
            }) {
                Text("🔺").font(BOTTOM_BUTTONS_FONT_SIZE)
            }


            Button(action: {
                self.date = Date()
            }) {
                Text("Today").font(BOTTOM_BUTTONS_FONT_SIZE)
            }.foregroundColor(.accentColor)

            Button(action: {
                self.date = self.date.oneDayAfter
            }) {
                Text("🔻").font(BOTTOM_BUTTONS_FONT_SIZE)
            }

            Spacer()

            DatePicker(selection:  self.$date, in:  Date.distantPast...Date.distantFuture, displayedComponents: .date) {
                Text("")
            }
            Spacer()
        }
        .border(Color.gray)
    } // var body
} // struct ASADatePicker

struct ASADatePicker_Previews: PreviewProvider {
    static var previews: some View {
        ASADatePicker(date: .constant(Date()), primaryRow: ASARow.generic)
    }
}
