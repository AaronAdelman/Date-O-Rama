//
//  ASAEventDetailDispatchView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI
#if os(watchOS)
#else
import EventKitUI
#endif

struct ASAEventDetailDispatchView: View {
    var event: ASAEventCompatible
    var clock:  ASAClock
    @Binding var now:  Date
    var shouldShowSecondaryDates: Bool
    var rangeStart: Date
    var rangeEnd: Date

#if os(watchOS)
#else
@Binding var action:  EKEventEditViewAction?
#endif

    var body: some View {
        if event is ASAMultiEvent {
            ASAMultiEventView(multiEvent: event as! ASAMultiEvent, now: $now, primaryClock: clock, shouldShowSecondaryDates: shouldShowSecondaryDates, rangeStart: rangeStart, rangeEnd: rangeEnd)
        } else {
#if os(watchOS)
            ASAEventDetailView(event: event, row: clock)
#else
            ASAEventDetailView(event: event, row: clock, action: $action)
#endif
        }
        
    }
}

//struct ASAEventDetailDispatchView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventDetailDispatchView()
//    }
//}
