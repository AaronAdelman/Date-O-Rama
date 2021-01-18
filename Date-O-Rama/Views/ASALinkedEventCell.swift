//
//  ASALinkedEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import EventKitUI
import SwiftUI

struct ASALinkedEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASARow
    var secondaryRow:  ASARow
    var eventsViewShouldShowSecondaryDates: Bool
    @State private var action:  EKEventViewAction?
    @State private var showingEventView = false
    var rangeStart:  Date
    var rangeEnd:  Date
    @Binding var now:  Date

    let CLOSE_BUTTON_TITLE = "Done"

    let FRAME_MIN_WIDTH:  CGFloat  = 300.0
    let FRAME_MIN_HEIGHT:  CGFloat = 500.0

    var body: some View {
        if event.isEKEvent {
            HStack {
                ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, forClock: false, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)

                Spacer()

                Button(action:  {
                    self.showingEventView = true
                }, label:  {
                    Image(systemName: "info.circle.fill") .font(Font.system(.title))
                })
                .popover(isPresented: $showingEventView, arrowEdge: .leading) {
                    ASAEKEventView(action: self.$action, event: self.event as! EKEvent).frame(minWidth:  FRAME_MIN_WIDTH, minHeight:  FRAME_MIN_HEIGHT)
                }.foregroundColor(.accentColor)
            }
        } else {
            ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, forClock: false, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)
        }
    }
} // struct ASALinkedEventCell

//struct ASALinkedEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALinkedEventCell()
//    }
//}
