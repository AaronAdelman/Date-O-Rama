//
//  ASAClockCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit


// MARK:  -

struct ASAClockCell: View {
    var processedRow:  ASAProcessedClock
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool
    var shouldShowTimeZone:  Bool
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    
    var isForComplications:  Bool
    
    var indexIsOdd: Bool
    
    @State var showingDetailView: Bool = false
    @State var eventVisibility: ASAClockCellEventVisibility = .defaultValue
    @State var allDayEventVisibility: ASAClockCellAllDayEventVisibility = .defaultValue
    
    var body: some View {
#if os(watchOS)
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications:  isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility, showingDetailView: $showingDetailView)
#else
        let MINIMUM_HEIGHT: CGFloat = 40.0
        
        if isForComplications {
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications:  true, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility, showingDetailView: $showingDetailView)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .colorScheme(.dark)
            }
        } else {
            let backgroundColor = indexIsOdd ? Color("oddBackground") : Color("evenBackground")
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications: isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility, showingDetailView: $showingDetailView)
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
    
    @Binding var eventVisibility: ASAClockCellEventVisibility
    @Binding var allDayEventVisibility: ASAClockCellAllDayEventVisibility
    
    @Binding var showingDetailView: Bool
    
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
    
    fileprivate func shouldShowMiniClock() -> Bool {
        return !compact && shouldShowTime && processedRow.hasValidTime
    } //func shouldShowMiniClock() -> Bool
    
    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedRow.row.localeIdentifier)
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
                        let numberOfEvents = processedRow.events.count
                        if numberOfEvents > 0 {
                            let SMALL_FONT: Font = .callout
                            let numberOfAllDayEvents = processedRow.events.filter {
                                $0.isAllDay
                            }.count
                            let numberOfNonAllDayEvents: Int = numberOfEvents - numberOfAllDayEvents
                            HStack {
                                Image(systemName: "calendar")
                                Text("\(numberOfAllDayEvents)").font(SMALL_FONT)
                                Image(systemName: "rectangle")
                                Text("\(numberOfNonAllDayEvents)").font(SMALL_FONT)
                            } // HStack
                        }
                    }
#endif
                } // VStack
                
#if os(watchOS)
                if processedRow.events.count > 0 {
                    NavigationLink(destination:  ASAWatchEventsList(processedRow:  processedRow, now: now)) {
                        ASACompactForwardChevronSymbol()
                    }
                }
#else
                if processedRow.supportsTimes {
                    if processedRow.supportsMonths && shouldShowMiniCalendar {
                        Spacer()
                        
                        ASAMiniCalendarView(daysPerWeek:  processedRow.daysPerWeek ?? 1, day:  processedRow.day, weekday:  processedRow.weekday, daysInMonth:  processedRow.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedRow.localeIdentifier,
                                            weekdaySymbols: processedRow.veryShortStandaloneWeekdaySymbols, weekendDays: processedRow.weekendDays,
                                            numberFormat: processedRow.miniCalendarNumberFormat)
                    }
                    
                    if shouldShowMiniClock() {
                        Spacer()
                        
                        ASAMiniClockView(processedRow:  processedRow, numberFormatter: numberFormatter())
                    }
                }
                
                Spacer()
                
                let ARROW_SYMBOL_NAME = "arrow.down.circle.fill"
                
                if isForComplications {
                    Menu {
                        Button(action: {
                            showingDetailView = true
                        }) {
                            ASAClockMenuDetailLabel()
                        }
                    } label: {
                        Image(systemName: ARROW_SYMBOL_NAME)
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: false, deleteable: false, forAppleWatch: true)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                ASAUserData.shared.savePreferences(code: .complications)
                            }
                    })
                } else {
                    Menu {
                        Button(action: {
                            showingDetailView = true
                        }) {
                            ASAClockMenuDetailLabel()
                        }
                        
                        let numberOfEvents = processedRow.events.count
                        if numberOfEvents > 0 {
                            Menu {
                                ASAClockAllDayEventVisibilityForEach(eventVisibility: $allDayEventVisibility)
                            } label: {
                                Text("Show All-Day Events")
                            }
                                                    
                            Menu {
                                ASAClockEventVisibilityForEach(eventVisibility: $eventVisibility)
                            } label: {
                                Text("Show Events")
                            }
                        }
                    } label: {
                        Image(systemName: ARROW_SYMBOL_NAME)
                            .font(.title)
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                ASAUserData.shared.savePreferences(code: .clocks)
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
    @Binding var eventVisibility: ASAClockCellEventVisibility
    
    var body: some View {
        ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
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
    @Binding var eventVisibility: ASAClockCellAllDayEventVisibility
    
    var body: some View {
        ForEach(ASAClockCellAllDayEventVisibility.allCases, id: \.self) {
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
    @Binding var eventVisibility: ASAClockCellEventVisibility
    @Binding var allDayEventVisibility: ASAClockCellAllDayEventVisibility
    
    var body: some View {
#if os(watchOS)
        EmptyView()
#else
        let numberOfEvents = processedRow.events.count
        if numberOfEvents > 0 {
            let VERTICAL_INSET: CGFloat   = 0.0
            let HORIZONTAL_INSET: CGFloat = 8.0
            ASAClockEventsForEach(processedRow: processedRow, visibility: eventVisibility, allDayEventVisibility: allDayEventVisibility, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
#endif
    } // var body
} // struct ASAClockEventsSubcell


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedClock
    var visibility:  ASAClockCellEventVisibility
    var allDayEventVisibility: ASAClockCellAllDayEventVisibility
    @Binding var now:  Date
    
    static let genericRow = ASAClock.generic
    
    var body: some View {
        let events:  Array<ASAEventCompatible> = {
            return processedRow.events.trimmed(visibility: self.visibility, allDayEventVisibility: self.allDayEventVisibility, now: now)
        }()
        
        ForEach(events, id: \.eventIdentifier) {
            event
            in
            let primaryRow: ASAClock = processedRow.row
            let secondaryRow = ASAClockEventsForEach.genericRow
            let shouldShowSecondaryDates = processedRow.calendarCode != .Gregorian
            let rangeStart: Date = processedRow.startOfDay
            let rangeEnd: Date = processedRow.startOfNextDay
            
            ASALinkedEventCell(event: event, primaryRow: primaryRow, secondaryRow: secondaryRow, eventsViewShouldShowSecondaryDates: shouldShowSecondaryDates, now: $now, rangeStart: rangeStart, rangeEnd: rangeEnd, isForClock: true)
        } // ForEach
    } // var body
} // struct ASAClockEventsForEach


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedRow: ASAProcessedClock(clock: ASAClock.generic, now: Date(), isForComplications: false), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: true)
    }
} // struct ASAClockCell_Previews
