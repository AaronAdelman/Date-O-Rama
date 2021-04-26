//
//  ASEventDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventDetailView: View {
    var event: ASAEventCompatible
    
    #if os(watchOS)
    let labelColor          = Color.white
    let secondaryLabelColor = Color(UIColor.lightGray)
    #else
    var labelColor          = Color(UIColor.label)
    var secondaryLabelColor = Color(UIColor.secondaryLabel)
    #endif
    
    var body: some View {
        List {
            Text(event.title)
                .font(.title)
            if event.location != nil {
                Text(event.location!)
            }
            HStack {
                ASAEventColorRectangle(color: event.color)
                Text(event.calendarTitleWithLocation)
            } // HStack
        } // List
    } // body
    } // struct ASAEventDetailView
    

struct ASEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventDetailView(event: ASAEvent(eventIdentifier: "Foo", title: "Foo", location: "Fooland", startDate: Date(), endDate: Date(), isAllDay: true, timeZone: TimeZone.current, color: .blue, uuid: UUID(), calendarTitleWithLocation: "Foo • Fooland", calendarTitleWithoutLocation: "Foo", isEKEvent: false, calendarCode: .Gregorian, locationData: ASALocation.NullIsland))
    }
}
