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
            
            let (startDateString, endDateString) = row.startAndEndDateStrings(event: event, isPrimaryRow: true, eventIsTodayOnly: false)
            if startDateString == endDateString {
                Text(startDateString)
            } else {
                Text(startDateString + "—" + endDateString)
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
            
            if event.url != nil {
                Link(destination: event.url!, label: {
                    Text(event.url!.absoluteString)
                        .underline()
                        .foregroundColor(.accentColor)
                })
            }
            
            if event.hasNotes {
                Text(event.notes!)
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
