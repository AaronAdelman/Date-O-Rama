//
//  ASAEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

fileprivate let secondaryClock = ASAClock.generic

struct ASAEventCell:  View {
    var event:  ASAEventCompatible
    var primaryClock:  ASAClock
//    var eventsViewShouldShowSecondaryDates: Bool
    var isForClock:  Bool
    @Binding var now:  Date
    var location: ASALocation
    
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
    
    var eventIsTodayOnly: Bool
    var startDateString: String?
    var endDateString: String
    
    var titleFont: Font {
        let duration = event.duration
#if os(watchOS)
        let basicFont: Font = .callout
#else
        let basicFont: Font = .body
#endif
        
        if duration > Date.SECONDS_PER_DAY * 27 {
            return basicFont.weight(.regular)
        }
        
        if duration > Date.SECONDS_PER_DAY && event.type != .oneDay {
            return basicFont.weight(.medium)
        }
        
        return basicFont.weight(.semibold)
    } // var titleFont
        
    fileprivate func eventSymbolView() -> ModifiedContent<Text, ASAScalable> {
        return Text(event.symbol!)
            .font(titleFont)
            .modifier(ASAScalable(lineLimit: 1))
    }
    
    fileprivate func eventTitleView() -> ModifiedContent<Text, ASAScalable> {
        let LINE_LIMIT = compact ? 3 : 2
        
        return Text(event.title)
            .font(titleFont)
            .modifier(ASAScalable(lineLimit: LINE_LIMIT))
    }
    
    fileprivate func eventLocationView(_ location: String?) -> ModifiedContent<Text, ASAScalable> {
        let LINE_LIMIT = compact ? 3 : 2
        
        return Text(location!)
            .font(.callout)
            .foregroundColor(.secondary)
            .modifier(ASAScalable(lineLimit: LINE_LIMIT))
    }
    
    var body: some View {
        let eventSymbol = event.symbol
        let eventsViewShouldShowSecondaryDates = primaryClock.calendar.calendarCode != .Gregorian
        
#if os(watchOS)
        HStack {
            ASAColorRectangle(colors: [event.color])
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if eventSymbol != nil {
                        Text(eventSymbol!)
                            .font(titleFont)
                            .modifier(ASAScalable(lineLimit: 2))
                    }
                    Text(event.title)
                        .font(titleFont)
                        .modifier(ASAScalable(lineLimit: 2))
                }
                if !event.isAllDay {
                    ASATimesSubcell(event: event, clock: self.primaryClock, isForClock: isForClock, isPrimaryClock:  true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: false)
                    
                    if eventsViewShouldShowSecondaryDates {
                        let (startDateString, endDateString) = secondaryClock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location)
                        ASATimesSubcell(event: event, clock: secondaryClock, isForClock: isForClock, isPrimaryClock:  false, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: true)
                    }
                }
            } // VStack
        } // HStack
#else
        HStack {
            ASATimesSubcell(event: event, clock: self.primaryClock, isForClock: isForClock, isPrimaryClock:  true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: false)
            
            if eventsViewShouldShowSecondaryDates {
                let (startDateString, endDateString) = secondaryClock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location)
                
                ASATimesSubcell(event: event, clock: secondaryClock, isForClock: isForClock, isPrimaryClock:  false, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: true)
            }
            
            ASAColorRectangle(colors: event.colors)
            
            if compact {
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .top) {
                        if eventSymbol != nil {
                            eventSymbolView()
                        }
                        eventTitleView()
                    }
                    
                    let location = event.location
                    if !(location?.isEmpty ?? true) {
                        eventLocationView(location)
                    }
                    
                    ASAEventCellCalendarTitle(event: event, isForClock: isForClock)
                } // VStack
            } else {
                HStack(alignment: .top) {     
                    if eventSymbol != nil {
                        eventSymbolView()
                    }
                    eventTitleView()
                }
                
                let location = event.location
                if !(location?.isEmpty ?? true) {
                    ASADottedLine()
                    
                    eventLocationView(location)
                }
                
                ASADottedLine()
                
                ASAEventCellCalendarTitle(event: event, isForClock: isForClock)
                
                Spacer()
                    .frame(width: 32.0)
            }
        } // HStack
#endif
    } // var body
} // struct ASAEventCell


struct ASADottedLine: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1.0, dash: [2.0]))
            .frame(minWidth: 0.0, idealWidth: 0.0, minHeight: 1.0, idealHeight: 1.0, maxHeight: 1.0, alignment: .center)
            .foregroundColor(.secondary)
    }
}


// MARK:  -

struct ASAEventCellCalendarTitle:  View {
    var event:  ASAEventCompatible
    var isForClock:  Bool

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
        let title: String = isForClock ? event.calendarTitleWithoutLocation : event.calendarTitleWithLocation
        Text(title).font(.subheadlineMonospacedDigit)
            .foregroundColor(.secondary)
            .modifier(ASAScalable(lineLimit: compact ? 2 : 1))
    }
}

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}
