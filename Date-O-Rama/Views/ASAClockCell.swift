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
    var processedRow:  ASAProcessedRow
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
    @State var eventVisibility: ASAClockCellEventVisibility = .next
    
    var body: some View {
#if os(watchOS)
        ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications:  isForComplications, eventVisibility: $eventVisibility, showingDetailView: $showingDetailView)
#else
        let MINIMUM_HEIGHT: CGFloat = 40.0
        
        if isForComplications {
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications:  true, eventVisibility: $eventVisibility, showingDetailView: $showingDetailView)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .colorScheme(.dark)
            }
        } else {
            let backgroundColor = indexIsOdd ? Color("oddBackground") : Color("evenBackground")
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedRow: processedRow, now: $now, shouldShowFormattedDate: shouldShowFormattedDate, shouldShowCalendar: shouldShowCalendar, shouldShowPlaceName: shouldShowPlaceName, shouldShowTimeZone: shouldShowTimeZone, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedRow.canSplitTimeFromDate, isForComplications: isForComplications, eventVisibility: $eventVisibility, showingDetailView: $showingDetailView)
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
    var processedRow:  ASAProcessedRow
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
        VStack {
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
                
                if isForComplications {
                    Menu {
                        Button(action: {
                            showingDetailView = true
                        }) {
                            Label("Details…", systemImage: "info.circle.fill")
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.down.fill")
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: false, deleteable: false, forAppleWatch: true)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                let userData = ASAUserData.shared
                                userData.objectWillChange.send()
                                userData.savePreferences(code: .complications)
                            }
                    })
                } else {
                    Menu {
                        Button(action: {
                            showingDetailView = true
                        }) {
                            Label("Details…", systemImage: "info.circle.fill")
                            }
                        
                        let numberOfEvents = processedRow.events.count
                        if numberOfEvents > 0 {
                            Divider()
                            
                            ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                                visibility
                                in
                                Button(action: {
                                    eventVisibility = visibility
                                }) {
                                    Label(visibility.showingText, systemImage: visibility == eventVisibility ? "checkmark" : "")
                                }
                            } // ForEach
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.down.fill")
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true, forAppleWatch: false)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                let userData = ASAUserData.shared
                                userData.objectWillChange.send()
                                userData.savePreferences(code: .clocks)
                            }
                    })
                }
#endif
            } // HStack
            
#if os(watchOS)
#else
            ASAClockEventsSubcell(processedRow: processedRow, now: $now, eventVisibility: $eventVisibility
                                  //                                  , indexIsOdd: false
            )
#endif
        } // VStack
    } // var body
} // struct ASAClockCellBody


// MARK:  -

struct ASAClockEventsSubcell: View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    @State private var showingEvents:  Bool = true
    @Binding var eventVisibility: ASAClockCellEventVisibility
    
//    var indexIsOdd: Bool
    
    var body: some View {
#if os(watchOS)
        EmptyView()
#else
//        let backgroundColor = indexIsOdd ? Color("oddBackground") : Color("evenBackground")
        
        let numberOfEvents = processedRow.events.count
//        let formatString : String = NSLocalizedString("n events today", comment: "")
//        let numberOfEventsString: String =  String.localizedStringWithFormat(formatString, numberOfEvents)
        if numberOfEvents > 0 {
//            NavigationLink(destination:             ASAClockCellEventVisibilityChooserView(selectedVisibility: $eventVisibility)) {
//                HStack {
//                    Image(systemName: "rectangle.stack")
//                    Text(numberOfEventsString)
//                    Spacer()
//                    Image(systemName: eventVisibility.symbolName)
//                    Text(eventVisibility.showingText)
//                } // HStack
//            }
//            .listRowBackground(backgroundColor
//                                .ignoresSafeArea(edges: .all)
//            )
            let VERTICAL_INSET: CGFloat   = 0.0
            let HORIZONTAL_INSET: CGFloat = 8.0
            ASAClockEventsForEach(processedRow: processedRow, visibility: eventVisibility, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
//                .listRowBackground(backgroundColor
//                                    .ignoresSafeArea(edges: .all)
//                )
        }
#endif
    } // var body
} // struct ASAClockEventsSubcell


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedRow:  ASAProcessedRow
    var visibility:  ASAClockCellEventVisibility
    @Binding var now:  Date
    
    static let genericRow = ASARow.generic
    
    var body: some View {
        let events:  Array<ASAEventCompatible> = {
            return processedRow.events.forVisibility(self.visibility, now: now)
        }()
        
        ForEach(events, id: \.eventIdentifier) {
            event
            in
            let primaryRow: ASARow = processedRow.row
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
        ASAClockCell(processedRow: ASAProcessedRow(row: ASARow.generic, now: Date()), now: .constant(Date()), shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: true)
    }
} // struct ASAClockCell_Previews
