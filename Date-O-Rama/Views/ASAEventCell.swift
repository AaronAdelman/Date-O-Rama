//
//  ASAEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

fileprivate let CALENDAR_TITLE_GRAY_LEVEL = 0.75
fileprivate let CALENDAR_TITLE_COLOR      = Color(red: CALENDAR_TITLE_GRAY_LEVEL, green: CALENDAR_TITLE_GRAY_LEVEL, blue: CALENDAR_TITLE_GRAY_LEVEL)

struct ASAEventCell:  View {
    var event:  ASAEventCompatible
    var primaryClock:  ASAClock
    var isForClock:  Bool
    var now:  Date
    var location: ASALocation
    
#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
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
        
    var body: some View {
        let eventSymbol = event.symbol
        let eventsViewShouldShowSecondaryDates = primaryClock.eventsShouldShowSecondaryDates
        
#if os(watchOS)
        HStack {
            ASAColorRectangle(colors: [event.color])
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if eventSymbol != nil {
                        ASAEventSymbolView(symbol: eventSymbol!, font: titleFont)
                    }
                    Text(event.title)
                        .font(titleFont)
                        .modifier(ASAScalable(lineLimit: 2))
                }
                if !event.isAllDay {
                    ASATimesSubcell(event: event, clock: self.primaryClock, isForClock: isForClock, isPrimaryClock:  true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: false)
                    
                    if eventsViewShouldShowSecondaryDates {
                        let (startDateString, endDateString) = (event.secondaryStartDateString == nil && event.secondaryEndDateString == nil) ? ASAEventCalendar.secondaryClock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location) : (event.secondaryStartDateString, event.secondaryEndDateString)
                        ASATimesSubcell(event: event, clock: ASAEventCalendar.secondaryClock, isForClock: isForClock, isPrimaryClock:  false, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString ?? startDateString!, isSecondary: true)
                    }
                }
            } // VStack
        } // HStack
#else
        HStack {
            if !eventIsTodayOnly || !event.isAllDay {
                ASATimesSubcell(event: event, clock: self.primaryClock, isForClock: isForClock, isPrimaryClock:  true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: false)
                
                if eventsViewShouldShowSecondaryDates && !event.isAllDay {
                    let (startDateString, endDateString) = ASAEventCalendar.secondaryClock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location)
                    
                    ASATimesSubcell(event: event, clock: ASAEventCalendar.secondaryClock, isForClock: isForClock, isPrimaryClock:  false, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString, isSecondary: true)
                }
            }
            
            ASAColorRectangle(colors: event.colors)
            
            if compact {
                if let symbol = eventSymbol {
                    ASAEventSymbolView(symbol: symbol, font: titleFont)
                }

                VStack(alignment: .leading) {
                    ASAEventTitleView(event: event, font: titleFont, compact: compact)
                    ASAEventCellCalendarTitle(event: event, isForClock: isForClock)
                } // VStack
            } else {
                if let symbol = eventSymbol {
                    ASAEventSymbolView(symbol: symbol, font: titleFont)
                }
                ASAEventTitleView(event: event, font: titleFont, compact: compact)
                
                ASADottedLine()
                
                ASAEventCellCalendarTitle(event: event, isForClock: isForClock)
                
                Spacer()
                    .frame(width: 32.0)
            }
        } // HStack
        .foregroundStyle(Color.white)
#endif
    } // var body
} // struct ASAEventCell


struct ASAEventSymbolView: View {
    let symbol: String
    let font: Font

    var body: some View {
        let LINE_LIMIT = 1
        
        let raw = symbol.trimmingCharacters(in: .whitespacesAndNewlines)

        if raw.hasPrefix("[[") && raw.hasSuffix("]]") {
            let start = raw.index(raw.startIndex, offsetBy: 2)
            let end = raw.index(raw.endIndex, offsetBy: -2)
            let sfName = String(raw[start..<end])
            return AnyView(
                Image(systemName: sfName)
                    .symbolRenderingMode(.multicolor)
                    .font(font)
                    .modifier(ASAScalable(lineLimit: LINE_LIMIT))
            )
        }

        let revisedSymbol: String = {
            let count = symbol.count
            if count <= 4{
                return symbol
            } else {
                let subSymbol: String = String(symbol.prefix(3))
                let extraCount = count - 3
                return String.localizedStringWithFormat("%@ + %d", subSymbol, extraCount)
            }
        }()
        
        return AnyView(
            Text(revisedSymbol)
                .font(font)
                .modifier(ASAScalable(lineLimit: LINE_LIMIT))
        )
    }
}

struct ASAEventTitleView: View {
    let event: ASAEventCompatible
    let font: Font
    let compact: Bool

    var body: some View {
        let LINE_LIMIT = compact ? 3 : 2

        let titleText: String = {
            let title: String = event.title ?? ""
            let location: String? = event.location
            if let location = location, !location.isEmpty {
                return String.localizedStringWithFormat(NSLocalizedString("%@ (%@)", comment: ""), title, location)
            }
            return title
        }()

        return Text(titleText)
            .font(font)
            .modifier(ASAScalable(lineLimit: LINE_LIMIT))
    }
}

struct ASADottedLine: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1.0, dash: [2.0]))
            .frame(minWidth: 0.0, idealWidth: 0.0, minHeight: 1.0, idealHeight: 1.0, maxHeight: 1.0, alignment: .center)
            .foregroundStyle(CALENDAR_TITLE_COLOR)
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
        return self.sizeClass == .compact
    } // var compact
#endif
    
    var body: some View {
        let title: String = isForClock ? event.calendarTitle : event.calendarTitleWithLocation

        Text(title).font(.subheadlineMonospacedDigit)
            .foregroundColor(CALENDAR_TITLE_COLOR)
            .modifier(ASAScalable(lineLimit: compact ? 2 : 1))
    }
}

//struct ASAEventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAEventCell()
//    }
//}

