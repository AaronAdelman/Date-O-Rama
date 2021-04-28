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
    @Binding var now:  Date
    var rangeStart:  Date
    var rangeEnd:  Date

    let CLOSE_BUTTON_TITLE = "Done"

    let FRAME_MIN_WIDTH:  CGFloat  = 300.0
    let FRAME_MIN_HEIGHT:  CGFloat = 500.0

    var body: some View {
//        if event.isEKEvent {
            HStack {
                ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, isForClock: false, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)

                Spacer()

                Button(action:  {
                    self.showingEventView = true
                }, label:  {
                    Image(systemName: "info.circle.fill") .font(Font.system(.title))
                })
                .popover(isPresented: $showingEventView, arrowEdge: .leading) {
//                    ASAEKEventView(action: self.$action, event: self.event as! EKEvent)
                    ASAEventDetailView(event: event, row: primaryRow)
                        .frame(minWidth:  FRAME_MIN_WIDTH, minHeight:  FRAME_MIN_HEIGHT)
                }.foregroundColor(.accentColor)
                
                #if targetEnvironment(macCatalyst)
                let SPACER_WIDTH: CGFloat = 16.0
                #else
                let SPACER_WIDTH: CGFloat =  8.0
                #endif
                Spacer()
                    .frame(width: SPACER_WIDTH)
            }
//        } else {
//            ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, isForClock: false, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)
//        }
    } // var body
} // struct ASALinkedEventCell

//struct ASALinkedEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALinkedEventCell()
//    }
//}
