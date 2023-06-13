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
    var location: ASALocation
    var usesDeviceLocation: Bool
    
#if os(watchOS)
#else
    @Binding var action:  EKEventEditViewAction?
#endif
    
    var body: some View {
#if os(watchOS)
        ASAEventDetailView(event: event, clock: clock, location: location, usesDeviceLocation: usesDeviceLocation)
#else
        ASAEventDetailView(event: event, clock: clock, location: location, usesDeviceLocation: usesDeviceLocation, action: $action)
#endif        
    }
}

//struct ASAEventDetailDispatchView_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventDetailDispatchView()
//    }
//}
