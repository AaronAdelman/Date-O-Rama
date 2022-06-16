//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit
#if os(watchOS)
#else
import EventKitUI
#endif

// MARK:  -

struct ASAClockCell: View {
    var processedClock:  ASAProcessedClock
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    
    var isForComplications:  Bool
    
    var indexIsOdd: Bool
    
    @State var eventVisibility: ASAClockCellTimeEventVisibility = .defaultValue
    @State var allDayEventVisibility: ASAClockCellDateEventVisibility = .defaultValue
    
    var body: some View {
#if os(watchOS)
        ASAClockCellBody(processedRow: processedClock, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications:  isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
#else
        let MINIMUM_HEIGHT: CGFloat = 40.0
        
        if isForComplications {
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedClock, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications:  true, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .colorScheme(.dark)
            }
        } else {
            let backgroundColor = indexIsOdd ? Color("oddBackground") : Color("evenBackground")
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedClock, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications: isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
                    .frame(minHeight:  MINIMUM_HEIGHT)
            }
            .listRowBackground(backgroundColor
                                .ignoresSafeArea(edges: .all)
            )
        }
#endif
    } // var body
} // struct ASAClockCell


// MARK: -

enum ASAClockCellBodyDetailType {
    case none
    case clockDetail
    case newEvent
}

struct ASAClockCellBody:  View {
    var processedRow:  ASAProcessedClock
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    var canSplitTimeFromDate:  Bool
    
    var isForComplications:  Bool
    
    @Binding var eventVisibility: ASAClockCellTimeEventVisibility
    @Binding var allDayEventVisibility: ASAClockCellDateEventVisibility
    
    @State var showingDetailView: Bool = false
    @State var detailType = ASAClockCellBodyDetailType.none

#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        get {
            return self.sizeClass == .compact
        } // get
    } // var compact
    
    @State private var action:  EKEventEditViewAction? = nil
    @ObservedObject var eventManager = ASAEKEventManager.shared
#endif
    
    fileprivate func shouldShowMiniClock() -> Bool {
        return !compact && shouldShowTime && processedRow.hasValidTime
    } //func shouldShowMiniClock() -> Bool
    
    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.clock.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                VStack(alignment: .leading) {
                    if shouldShowCalendar {
                        ASAClockCellText(string:  processedRow.calendarString, font:  .subheadlineMonospacedDigit, lineLimit:  1)
                    }
                    
                    if canSplitTimeFromDate {
                        if shouldShowFormattedDate {
#if os(watchOS)
                            let LINE_LIMIT = 1
#else
                            let LINE_LIMIT = 2
#endif
                            ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  LINE_LIMIT)
                        }
                        if shouldShowTime {
                            HStack {
                                if !shouldShowPlaceName && processedRow.usesDeviceLocation {
                                    ASALocationSymbol()
                                }
                                
                                let timeString: String = processedRow.timeString ?? ""
                                let string = (processedRow.supportsTimeZones && shouldShowTimeZone) ? timeString + " · " + processedRow.timeZoneString : timeString
                                ASAClockCellText(string:  string, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                            }
                        }
                    } else {
                        HStack {
                            if !shouldShowPlaceName && processedRow.usesDeviceLocation {
                                ASALocationSymbol()
                            }
                            
                            if shouldShowFormattedDate {
                                ASAClockCellText(string:  processedRow.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                            }
                        }
                    }
                    
                    ASAPlaceSubcell(processedRow:  processedRow, shouldShowPlaceName:  shouldShowPlaceName
                    )
                    
#if os(watchOS)
#else
                    if !isForComplications {
                        let numberOfAllDayEvents = processedRow.dateEvents.count
                        let numberOfNonAllDayEvents: Int = processedRow.timeEvents.count
                        let numberOfEvents = numberOfAllDayEvents + numberOfNonAllDayEvents
                        if numberOfEvents > 0 {
                            let SMALL_FONT: Font = .callout
                            HStack {
                                Image(systemName: "calendar")
                                Text("\(numberOfAllDayEvents)").font(SMALL_FONT)
                                Image(systemName: "calendar.day.timeline.leading")
                                Text("\(numberOfNonAllDayEvents)").font(SMALL_FONT)
                            } // HStack
                        }
                    }
#endif
                } // VStack
                
#if os(watchOS)
                if processedRow.dateEvents.count > 0 || processedRow.timeEvents.count > 0 {
                    NavigationLink(destination:  ASAWatchEventsList(processedRow:  processedRow, now: now)) {
                        ASACompactForwardChevronSymbol()
                    }
                }
#else
                if processedRow.supportsTimes {
                    if processedRow.supportsMonths && shouldShowMiniCalendar {
                        Spacer()
                        
                        ASAMiniCalendarView(daysPerWeek:  processedRow.daysPerWeek ?? 7, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier, weekdaySymbols: processedRow.veryShortStandaloneWeekdaySymbols ?? [], weekendDays: processedRow.weekendDays ?? [], numberFormat: processedRow.miniCalendarNumberFormat, monthIsBlank: processedRow.monthIsBlank, blankWeekdaySymbol: processedRow.blankWeekdaySymbol)
                    }
                    
                    if shouldShowMiniClock() {
                        Spacer()
                        
                        ASAMiniClockView(processedRow:  processedRow, numberFormatter: numberFormatter())
                    }
                }
                
                Spacer()
                    .frame(width: 32.0)
                
                let ARROW_SYMBOL_NAME = "arrow.down.circle.fill"
                
                if isForComplications {
                    Menu {
                        Button(action: {
                            detailType = .clockDetail
                            showingDetailView = true
                        }) {
                            ASAClockMenuDetailLabel()
                        }
                    } label: {
                        Image(systemName: ARROW_SYMBOL_NAME)
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        VStack {
                            HStack {
                                Button(action: {
                                    showingDetailView = false
                                    detailType = .none
                                }) {
                                    ASACloseBoxImage()
                                }
                                Spacer()
                            } // HStack
                            ASAClockDetailView(selectedRow: processedRow.clock, now: self.now, shouldShowTime: false, deletable: false, forAppleWatch: true)
                                .onReceive(processedRow.clock.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    ASAUserData.shared.savePreferences(code: .complications)
                                }
                        }
                    })
                } else {
                    Menu {
                        Button(action: {
                            detailType = .clockDetail
                            showingDetailView = true
                        }) {
                            ASAClockMenuDetailLabel()
                        }
                        
                        let numberOfDateEvents = processedRow.dateEvents.count
                        let numberOfTimeEvents = processedRow.timeEvents.count
                        if numberOfDateEvents > 0 {
                            Menu {
                                ASAClockAllDayEventVisibilityForEach(eventVisibility: $allDayEventVisibility)
                            } label: {
                                Text("Show All-Day Events")
                            }
                        }
                        if numberOfTimeEvents > 0 {
                            
                            Menu {
                                ASAClockEventVisibilityForEach(eventVisibility: $eventVisibility)
                            } label: {
                                Text("Show Events")
                            }
                        }
                        
                        if processedRow.clock.supportsExternalEvents {
                            Button(action:
                                    {
                                detailType = .newEvent
                                showingDetailView = true                                }, label:  {
                                    ASANewExternalEventButtonLabel()            .foregroundColor(.accentColor)
                                })
                        }
                    } label: {
                        Image(systemName: ARROW_SYMBOL_NAME)
                            .font(.title)
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        if detailType == .clockDetail {
                            VStack {
                                HStack {
                                    Button(action: {
                                        showingDetailView = false
                                        detailType = .none
                                    }) {
                                        ASACloseBoxImage()
                                    }
                                    Spacer()
                                } // HStack
                                ASAClockDetailView(selectedRow: processedRow.clock, now: self.now, shouldShowTime: true, deletable: true, forAppleWatch: false)
                                    .onReceive(processedRow.clock.objectWillChange) { _ in
                                        // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                        ASAUserData.shared.savePreferences(code: .clocks)
                                    }
                            }
                        } else if detailType == .newEvent {
                            ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore)
                        } else {
                            EmptyView()
                        }
                        
                    })
                }
#endif
            } // HStack
            
#if os(watchOS)
#else
            if !isForComplications {
                ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
            }
#endif
        } // VStack
    } // var body
} // struct ASAClockCellBody


struct ASAClockEventVisibilityForEach: View {
    @Binding var eventVisibility: ASAClockCellTimeEventVisibility
    
    var body: some View {
        ForEach(ASAClockCellTimeEventVisibility.allCases, id: \.self) {
            visibility
            in
            Button(action: {
                eventVisibility = visibility
            }) {
                ASAClockMenuVisibilityLabel(text: visibility.text, shouldShowCheckmark: visibility == eventVisibility)
            }
        } // ForEach
    } // var body
} // struct ASAClockEventVisibilityForEach


struct ASAClockAllDayEventVisibilityForEach: View {
    @Binding var eventVisibility: ASAClockCellDateEventVisibility
    
    var body: some View {
        ForEach(ASAClockCellDateEventVisibility.allCases, id: \.self) {
            visibility
            in
            Button(action: {
                eventVisibility = visibility
            }) {
                ASAClockMenuVisibilityLabel(text: visibility.text, shouldShowCheckmark: visibility == eventVisibility)
            }
        } // ForEach
    } // var body
} // struct ASAClockAllDayEventVisibilityForEach


struct ASAClockMenuDetailLabel: View {
    var body: some View {
        Label("Details…", systemImage: "info.circle.fill")
    } // var body
} // struct ASAClockMenuDetailLabel


struct ASAClockMenuVisibilityLabel: View {
    var text: String
    var shouldShowCheckmark: Bool
    
    var body: some View {
        if shouldShowCheckmark {
            Label(text, systemImage: "checkmark")
        } else {
            Text(text)
        }
    } // var body
} // struct ASAClockMenuVisibilityLabel


// MARK:  -

struct ASAClockEventsSubcell: View {
    var processedRow:  ASAProcessedClock
    @Binding var now:  Date
    @State private var showingEvents:  Bool = true
    @Binding var eventVisibility: ASAClockCellTimeEventVisibility
    @Binding var allDayEventVisibility: ASAClockCellDateEventVisibility
    
    var body: some View {
#if os(watchOS)
        EmptyView()
#else
        let VERTICAL_INSET: CGFloat   = 0.0
        let HORIZONTAL_INSET: CGFloat = 8.0
        let numberOfDateEvents: Int = processedRow.dateEvents.count
        if numberOfDateEvents > 0 {
            let dateEvents = processedRow.dateEvents.trimmed(dateEventVisibility: allDayEventVisibility, now: now)
            ASAClockEventsForEach(processedRow: processedRow, events: dateEvents, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
        let numberOfTimeEvents: Int = processedRow.timeEvents.count
        if numberOfTimeEvents > 0 {
            let timeEvents = processedRow.timeEvents.trimmed(timeEventVisibility: eventVisibility, now: now)
            ASAClockEventsForEach(processedRow: processedRow, events: timeEvents, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
#endif
    } // var body
} // struct ASAClockEventsSubcell


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedClock
    var events:  Array<ASAEventCompatible>
    @Binding var now:  Date
    
    var body: some View {
        let primaryClock: ASAClock = processedRow.clock
        let shouldShowSecondaryDates = processedRow.calendarCode != .Gregorian
        let rangeStart: Date = processedRow.startOfDay
        let rangeEnd: Date = processedRow.startOfNextDay

        ASAEventsForEach(events: events, now: $now, primaryClock: primaryClock, shouldShowSecondaryDates: shouldShowSecondaryDates, rangeStart: rangeStart, rangeEnd: rangeEnd)
    } // var body
} // struct ASAClockEventsForEach

struct ASAEventsForEach: View {
    var events:  Array<ASAEventCompatible>
    @Binding var now:  Date
    var primaryClock: ASAClock
    var shouldShowSecondaryDates: Bool
    var rangeStart: Date
    var rangeEnd: Date

    var body: some View {
        let secondaryClock = ASAClock.generic

        ForEach(events, id: \.eventIdentifier) {
            event
            in
            
            let eventIsTodayOnly = event.isOnlyForRange(rangeStart: rangeStart, rangeEnd: rangeEnd)
            let (startDateString, endDateString) = self.primaryClock.startAndEndDateStrings(event: event, isPrimaryRow: true, eventIsTodayOnly: eventIsTodayOnly)

            ASALinkedEventCell(event: event, primaryRow: primaryClock, secondaryRow: secondaryClock, eventsViewShouldShowSecondaryDates: shouldShowSecondaryDates, now: $now, rangeStart: rangeStart, rangeEnd: rangeEnd, isForClock: true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString)
        } // ForEach
    }
}


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedClock: ASAProcessedClock(clock: ASAClock.generic, now: Date(), isForComplications: false), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: true)
    }
} // struct ASAClockCell_Previews
