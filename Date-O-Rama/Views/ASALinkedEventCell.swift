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
    var primaryClock:  ASAClock
#if os(watchOS)
#else
    @State private var action:  EKEventEditViewAction?
#endif
    @State private var showingEventView = false
    var now:  Date
    var location: ASALocation
    var usesDeviceLocation: Bool
        
    let FRAME_MIN_WIDTH: CGFloat  = 400.0
    let FRAME_MIN_HEIGHT: CGFloat = 700.0
    
    var isForClock: Bool
    var eventIsTodayOnly: Bool
    var startDateString: String?
    var endDateString: String
    
#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
    } // var compact
#endif
    
    var body: some View {
#if os(watchOS)
        NavigationLink(destination: ASAEventDetailView(event: event, clock: primaryClock, location: location, usesDeviceLocation: usesDeviceLocation), label: {
            HStack {
                ASAEventCell(event: event, primaryClock: self.primaryClock, isForClock: false, now: now, location: location, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString)
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
            
            ASAEventCell(event: event, primaryClock: self.primaryClock, isForClock: isForClock, now: now, location: location, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString)
            
            Spacer()
            
            Menu {
                Button(action: {
                    showingEventView = true
                }) {
                    ASAGetInfoLabel()
                }
                
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundColor(event.color)
                    .font(.title)
            }
            .popover(isPresented: $showingEventView) {
                ScrollView {
                    ASAEventDetailView(event: event, clock: primaryClock, location: location, usesDeviceLocation: usesDeviceLocation, action: $action)
                        .frame(minWidth: FRAME_MIN_WIDTH, minHeight: FRAME_MIN_HEIGHT)
                }
            }
            .foregroundColor(.accentColor)
            .onChange(of: action) { _, newValue in
                if newValue == .deleted {
                    self.showingEventView = false
                }
            }
            
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
#endif
    } // var body
} // struct ASALinkedEventCell

//struct ASALinkedEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASALinkedEventCell()
//    }
//}

