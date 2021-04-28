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
    var row:  ASARow
    
    #if os(watchOS)
    let labelColor          = Color.white
    let secondaryLabelColor = Color(UIColor.lightGray)
    #else
    var labelColor          = Color(UIColor.label)
    var secondaryLabelColor = Color(UIColor.secondaryLabel)
    #endif
    
    var formatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter
    }()
    
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
            
            if event.isEKEvent || event.calendarCode == .Gregorian {
                let fudge = event.startDate == event.endDate ? 0.0 : 1.0
                let intervalString = formatter.string(from: event.startDate, to: event.endDate - fudge)
                Text(intervalString)
            }
            
            if event.timeZone != nil {
                let timeZone = event.timeZone!
                let now = Date()
                HStack {
                    Text(verbatim:  timeZone.abbreviation(for:  now) ?? "")
                    Text("•")
                    Text(verbatim:  timeZone.localizedName(for: now))
                } // HStack
            }
        } // List
        .foregroundColor(labelColor)
    } // body
} // struct ASAEventDetailView
    

struct ASEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventDetailView(event: ASAEvent(eventIdentifier: "Foo", title: "Foo", location: "Fooland", startDate: Date(), endDate: Date(), isAllDay: true, timeZone: TimeZone.current, color: .blue, uuid: UUID(), calendarTitleWithLocation: "Foo • Fooland", calendarTitleWithoutLocation: "Foo", isEKEvent: false, calendarCode: .Gregorian, locationData: ASALocation.NullIsland), row: ASARow.generic)
    }
}
