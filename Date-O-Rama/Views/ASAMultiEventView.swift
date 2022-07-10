//
//  ASAMultiEventView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAMultiEventView: View {
    var multiEvent: ASAMultiEvent
    @Binding var now:  Date
    var primaryClock: ASAClock
    var shouldShowSecondaryDates: Bool
    var rangeStart: Date
    var rangeEnd: Date
    var location: ASALocation
    var usesDeviceLocation: Bool

    var body: some View {
        List {
            ASAEventDetailsTitleSection(event: multiEvent)

            ASAEventsForEach(events: multiEvent.events, now: $now, primaryClock: primaryClock, shouldShowSecondaryDates: shouldShowSecondaryDates, rangeStart: rangeStart, rangeEnd: rangeEnd, location: location, usesDeviceLocation: usesDeviceLocation)
            
            Spacer()
                .frame(minHeight: 0.0)
        }
    }
}

//struct ASAMultiEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAMultiEventView()
//    }
//}
