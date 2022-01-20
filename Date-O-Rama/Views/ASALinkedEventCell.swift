//
//  ASALinkedEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
#if os(watchOS)
#else
import EventKitUI
#endif
import SwiftUI

struct ASALinkedEventCell:  View {
    var event:  ASAEventCompatible
    var primaryRow:  ASAClock
    var secondaryRow:  ASAClock
    var eventsViewShouldShowSecondaryDates: Bool
    #if os(watchOS)
    #else
    @State private var action:  EKEventEditViewAction?
    #endif
    @State private var showingEventView = false
    @Binding var now:  Date
    var rangeStart:  Date
    var rangeEnd:  Date
    
    let CLOSE_BUTTON_TITLE = "Done"
    
    let FRAME_MIN_WIDTH:  CGFloat  = 300.0
    let FRAME_MIN_HEIGHT:  CGFloat = 500.0
    
    var isForClock: Bool
    
    #if os(watchOS)
    let compact = true
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    #endif
    
    var body: some View {
        #if os(watchOS)
        NavigationLink(destination: ASAEventDetailDispatchView(event: event, clock: primaryRow, now: $now, shouldShowSecondaryDates: false, rangeStart: rangeStart, rangeEnd: rangeEnd), label: {
            HStack {
                ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, isForClock: false, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)
                Spacer()
                ASACompactForwardChevronSymbol()
            } // HStack
        })
        #else
        HStack {
            if !isForClock {
                #if targetEnvironment(macCatalyst)
                #else
                Spacer()
                    .frame(width: 8.0)
                #endif
            }
            
            ASAEventCell(event: event, primaryRow: self.primaryRow, secondaryRow: self.secondaryRow, eventsViewShouldShowSecondaryDates: self.eventsViewShouldShowSecondaryDates, isForClock: isForClock, now: $now, rangeStart: rangeStart, rangeEnd:  rangeEnd)
            
            Spacer()
            
            Menu {
                Button(action: {
                    showingEventView = true
                }) {
                    Label("Details…", systemImage: "info.circle.fill")
                }
                
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundColor(event.color)
                    .font(.title)
            }
            .popover(isPresented: $showingEventView, arrowEdge: .leading) {
                ASAEventDetailDispatchView(event: event, clock: primaryRow, now: $now, shouldShowSecondaryDates: false, rangeStart: rangeStart, rangeEnd: rangeEnd, action: $action)
                    .frame(minWidth:  FRAME_MIN_WIDTH, minHeight:  FRAME_MIN_HEIGHT)
            }
            .foregroundColor(.accentColor)
            .onChange(of: action, perform: {
                newValue
                in
                if action == .deleted {
                    self.showingEventView = false
                }
            })
            
            if !isForClock {
                #if targetEnvironment(macCatalyst)
                let SPACER_WIDTH: CGFloat = 16.0
                #else
                let SPACER_WIDTH: CGFloat =  8.0
                #endif
                Spacer()
                    .frame(width: SPACER_WIDTH)
            }
        }
//        .modifier(ASAEventCellStyle(event: event))
        #endif
    } // var body
} // struct ASALinkedEventCell

//struct ASALinkedEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALinkedEventCell()
//    }
//}
