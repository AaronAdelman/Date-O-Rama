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
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    
    var isForComplications:  Bool
    
    var indexIsOdd: Bool
    
    @State var eventVisibility: ASAClockCellTimeEventVisibility = .defaultValue
    @State var allDayEventVisibility: ASAClockCellDateEventVisibility = .defaultValue
    
    var body: some View {
#if os(watchOS)
        ASAClockCellBody(processedClock: processedClock, now: $now, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications:  isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
#else
        let MINIMUM_HEIGHT: CGFloat = 40.0
        
        if isForComplications {
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedClock: processedClock, now: $now, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar, canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications:  true, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
                    .frame(minHeight:  MINIMUM_HEIGHT)
                    .colorScheme(.dark)
            }
        } else {
            let backgroundColor = indexIsOdd ? Color("oddBackground") : Color("evenBackground")
            HStack(alignment: .firstTextBaseline) {
                ASAClockCellBody(processedClock: processedClock, now: $now, shouldShowTime: shouldShowTime, shouldShowMiniCalendar: shouldShowMiniCalendar,  canSplitTimeFromDate: processedClock.canSplitTimeFromDate, isForComplications: isForComplications, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
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
    var processedClock:  ASAProcessedClock
    @Binding var now:  Date
    
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
        return !compact && shouldShowTime && processedClock.hasValidTime
    } //func shouldShowMiniClock() -> Bool
    
    fileprivate func numberFormatter() -> NumberFormatter {
        let temp = NumberFormatter()
        temp.locale = Locale(identifier: processedClock.clock.localeIdentifier)
        return temp
    } // func numberFormatter() -> NumberFormatter
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                VStack(alignment: .leading) {
                    ASAClockCellText(string:  processedClock.calendarString, font:  .subheadlineMonospacedDigit, lineLimit:  1)
                    
                    if canSplitTimeFromDate {
                        //#if os(watchOS)
                        //                        let LINE_LIMIT = 1
                        //#else
                        let LINE_LIMIT = 2
                        //#endif
                        ASAClockCellText(string:  processedClock.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  LINE_LIMIT)
                        if shouldShowTime {
                            HStack {
                                //                                if processedClock.usesDeviceLocation {
                                //                                    ASALocationSymbol()
                                //                                }
                                
                                let timeString: String = processedClock.timeString ?? ""
//                                let string = processedClock.supportsTimeZones ? timeString + " · " + processedClock.timeZoneString : timeString
//                                ASAClockCellText(string:  string, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                                ASAClockCellText(string: timeString, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                            }
                        }
                    } else {
                        HStack {
                            //                            if processedClock.usesDeviceLocation {
                            //                                ASALocationSymbol()
                            //                            }
                            
                            ASAClockCellText(string:  processedClock.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                        }
                    }
                    
#if os(watchOS)
#else
                    if !isForComplications {
                        let numberOfAllDayEvents = processedClock.dateEvents.count
                        let numberOfNonAllDayEvents: Int = processedClock.timeEvents.count
                        let numberOfEvents = numberOfAllDayEvents + numberOfNonAllDayEvents
                        if numberOfEvents > 0 {
                            let SMALL_FONT: Font = .callout
                            HStack {
                                Image(systemName: "calendar")
                                    .symbolRenderingMode(.multicolor)
                                Text("\(numberOfAllDayEvents)").font(SMALL_FONT)
                                Image(systemName: "calendar.day.timeline.leading")
                                    .symbolRenderingMode(.multicolor)
                                Text("\(numberOfNonAllDayEvents)").font(SMALL_FONT)
                            } // HStack
                        }
                    }
#endif
                } // VStack
                
#if os(watchOS)
                if processedClock.dateEvents.count > 0 || processedClock.timeEvents.count > 0 {
                    NavigationLink(destination:  ASAWatchEventsList(processedClock:  processedClock, now: now)) {
                        ASACompactForwardChevronSymbol()
                    }
                }
#else
                if processedClock.supportsTimes {
                    if processedClock.supportsMonths && shouldShowMiniCalendar {
                        Spacer()
                        
                        ASAMiniCalendarView(daysPerWeek:  processedClock.daysPerWeek ?? 7, day:  processedClock.day, weekday:  processedClock.weekday, daysInMonth:  processedClock.daysInMonth, numberFormatter:  numberFormatter(), localeIdentifier: processedClock.localeIdentifier, weekdaySymbols: processedClock.veryShortStandaloneWeekdaySymbols ?? [], weekendDays: processedClock.weekendDays ?? [], numberFormat: processedClock.miniCalendarNumberFormat, monthIsBlank: processedClock.monthIsBlank, blankWeekdaySymbol: processedClock.blankWeekdaySymbol)
                    }
                    
                    if shouldShowMiniClock() {
                        Spacer()
                        
                        ASAMiniClockView(processedClock:  processedClock, numberFormatter: numberFormatter())
                    }
                }
                
                Spacer()
                    .frame(width: 32.0)
                
                let ARROW_SYMBOL_NAME = "arrow.down.circle.fill"
                
                if isForComplications {
                    Spacer()
                    
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
                            ASAClockDetailView(selectedClock: processedClock.clock, location: processedClock.location, usesDeviceLocation: processedClock.usesDeviceLocation, now: self.now, shouldShowTime: false, deletable: false, forAppleWatch: true, tempLocation: processedClock.location)
                                .onReceive(processedClock.clock.objectWillChange) { _ in
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
                        
                        let numberOfDateEvents = processedClock.dateEvents.count
                        let numberOfTimeEvents = processedClock.timeEvents.count
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
                        
                        if processedClock.supportsExternalEvents {
                            Button(action:
                                    {
                                detailType = .newEvent
                                showingDetailView = true
                            }, label:  {
                                HStack {
                                    Image(systemName: "rectangle.badge.plus")
                                        .symbolRenderingMode(.multicolor)
                                    Text(NSLocalizedString("Add external event", comment: ""))
                                } // HStack
                                .foregroundColor(.accentColor)
                            })
                        }
                    } label: {
                        Image(systemName: ARROW_SYMBOL_NAME)
                            .font(.title)
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}, content: {
                        ASAClockCellMenuView(processedClock: processedClock, now: $now, showingDetailView: $showingDetailView, detailType: $detailType)
                    })
                }
#endif
            } // HStack
            
#if os(watchOS)
#else
            if !isForComplications {
                ASAClockEventsSubcell(processedClock: processedClock, now: $now, eventVisibility: $eventVisibility, allDayEventVisibility: $allDayEventVisibility)
            }
#endif
        } // VStack
    } // var body
} // struct ASAClockCellBody


#if os(watchOS)
#else
struct ASAClockCellMenuView: View {
    var processedClock:  ASAProcessedClock
    @Binding var now:  Date
    @Binding var showingDetailView: Bool
    @Binding var detailType: ASAClockCellBodyDetailType
    
    @State private var action:  EKEventEditViewAction? = nil
    @ObservedObject var eventManager = ASAEKEventManager.shared
    
    var body: some View {
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
                ASAClockDetailView(selectedClock: processedClock.clock, location: processedClock.location, usesDeviceLocation: processedClock.usesDeviceLocation, now: self.now, shouldShowTime: true, deletable: true, forAppleWatch: false, tempLocation: processedClock.location)
                    .onReceive(processedClock.clock.objectWillChange) { _ in
                        // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                        ASAUserData.shared.savePreferences(code: .clocks)
                    }
            }
        } else if detailType == .newEvent {
            ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore)
        } else {
            EmptyView()
        }
    }
}
#endif


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
    var processedClock:  ASAProcessedClock
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
        let numberOfDateEvents: Int = processedClock.dateEvents.count
        if numberOfDateEvents > 0 {
            let dateEvents = processedClock.dateEvents.trimmed(dateEventVisibility: allDayEventVisibility, now: now)
            ASAClockEventsForEach(processedClock: processedClock, events: dateEvents, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
        let numberOfTimeEvents: Int = processedClock.timeEvents.count
        if numberOfTimeEvents > 0 {
            let timeEvents = processedClock.timeEvents.trimmed(timeEventVisibility: eventVisibility, now: now)
            ASAClockEventsForEach(processedClock: processedClock, events: timeEvents, now: $now)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
#endif
    } // var body
} // struct ASAClockEventsSubcell


// MARK:  -

struct ASAClockEventsForEach:  View {
    var processedClock:  ASAProcessedClock
    var events:  Array<ASAEventCompatible>
    @Binding var now:  Date
    
    var body: some View {
        let primaryClock: ASAClock = processedClock.clock
        let shouldShowSecondaryDates = processedClock.clock.eventsShouldShowSecondaryDates
        let rangeStart: Date = processedClock.startOfDay
        let rangeEnd: Date = processedClock.startOfNextDay
        
        ASAEventsForEach(events: events, now: $now, primaryClock: primaryClock, shouldShowSecondaryDates: shouldShowSecondaryDates, rangeStart: rangeStart, rangeEnd: rangeEnd, location: processedClock.location, usesDeviceLocation: processedClock.usesDeviceLocation)
    } // var body
} // struct ASAClockEventsForEach

struct ASAEventsForEach: View {
    var events:  Array<ASAEventCompatible>
    @Binding var now:  Date
    var primaryClock: ASAClock
    var shouldShowSecondaryDates: Bool
    var rangeStart: Date
    var rangeEnd: Date
    var location: ASALocation
    var usesDeviceLocation: Bool
    
    var body: some View {
        ForEach(events, id: \.eventIdentifier) {
            event
            in
            
            let eventIsTodayOnly = event.isOnlyForRange(rangeStart: rangeStart, rangeEnd: rangeEnd)
            let (startDateString, endDateString) = (event.startDateString == nil && event.endDateString == nil) ? self.primaryClock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location) : (event.startDateString, event.endDateString)
            
            ASALinkedEventCell(event: event, primaryClock: primaryClock, now: $now, rangeStart: rangeStart, rangeEnd: rangeEnd, location: location, usesDeviceLocation: usesDeviceLocation, isForClock: true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString!)
        } // ForEach
    }
}


// MARK:  -

struct ASAClockCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCell(processedClock: ASAProcessedClock(clock: ASAClock.generic, now: Date(), isForComplications: false, location: .NullIsland, usesDeviceLocation: false), now: .constant(Date()), shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: true)
    }
} // struct ASAClockCell_Previews
