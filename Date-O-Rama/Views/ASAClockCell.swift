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
    @EnvironmentObject var userData:  ASAModel
    
    var processedClock:  ASAProcessedClock
    @Binding var now:  Date
    
    var shouldShowTime:  Bool
    var shouldShowMiniCalendar:  Bool
    
    var isForComplications:  Bool
    
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    enum DetailType {
        case none
        case clockDetail
        case newEvent
    }
    
    @State private var showingDetailView: Bool = false
    @State private var detailType: DetailType = .none
    
    let DEFAULT_DAYS_PER_WEEK = 7
    
#if os(watchOS)
    let compact = true
#else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
    } // var compact
#endif
    
#if os(watchOS)
#else
    @State private var action:  EKEventEditViewAction? = nil
    @ObservedObject var eventManager = ASAEKEventManager.shared
#endif
    
    var body: some View {
        let canSplitTimeFromDate = clock.calendar.canSplitTimeFromDate
        
#if os(watchOS)
        let MINIMUM_HEIGHT: CGFloat? = nil
#else
        let MINIMUM_HEIGHT: CGFloat? = 40.0
#endif
        
        VStack(spacing: 0.0) {
            HStack {
                VStack(alignment: .leading) {
                    ASAClockCellText(string:  processedClock.calendarString, font:  .subheadlineMonospacedDigit, lineLimit:  1)
                    
                    if canSplitTimeFromDate {
                        let LINE_LIMIT = 2
                        ASAClockCellText(string:  processedClock.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  LINE_LIMIT)
                        if shouldShowTime {
                            let timeString: String = processedClock.timeString ?? ""
                            ASAClockCellText(string: timeString, font:  Font.headlineMonospacedDigit, lineLimit:  2)
                        }
                    } else {
                        ASAClockCellText(string:  processedClock.dateString, font:  Font.headlineMonospacedDigit, lineLimit:  1)
                    }
                    
                    if processedClock.supportsMonths && shouldShowMiniCalendar && compact {
                        // Precompute weekday items and cell items for the mini calendar
                        let daysPerWeek = processedClock.daysPerWeek ?? DEFAULT_DAYS_PER_WEEK
                        let weekdayItems = processedClock.miniCalendarWeekdayItems ?? []
                        let dayItems = processedClock.miniCalendarDayItems ?? []
                        let characterDirection = processedClock.characterDirection

                        ASAMiniCalendarView(
                            daysPerWeek: daysPerWeek,
                            characterDirection: characterDirection,
                            weekdayItems: weekdayItems,
                            dayItems: dayItems
                        )
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
                    NavigationLink(destination:  ASAWatchEventsList(processedClock:  processedClock, eventVisibility: $clock.eventVisibility, allDayEventVisibility: $clock.allDayEventVisibility, now: now, clock: clock, location: location)) {
                        ASACompactForwardChevronSymbol()
                    }
                }
#else
                Spacer()

                if processedClock.supportsMonths && shouldShowMiniCalendar && !compact {
                    // Precompute weekday items and cell items for the mini calendar
                    let daysPerWeek = processedClock.daysPerWeek ?? DEFAULT_DAYS_PER_WEEK
                    let weekdayItems = processedClock.miniCalendarWeekdayItems ?? []
                    let dayItems = processedClock.miniCalendarDayItems ?? []
                    let characterDirection = processedClock.characterDirection

                    ASAMiniCalendarView(
                        daysPerWeek: daysPerWeek,
                        characterDirection: characterDirection,
                        weekdayItems: weekdayItems,
                        dayItems: dayItems
                    )
                }
                
                Spacer()
                    .frame(width: 32.0)
                
                if isForComplications {
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            detailType = .clockDetail
                            showingDetailView = true
                        }) {
                            ASAGetInfoLabel()
                        }
                    } label: {
                        ASAClockMenuSymbol()
                    }
                    .sheet(isPresented: $showingDetailView, onDismiss: {}) {
                        NavigationStack {
                            ASAClockDetailView(selectedClock: clock, location: location, usesDeviceLocation: processedClock.usesDeviceLocation, now: self.now, shouldShowTime: false, deletable: false, forAppleWatch: true, tempLocation: location)
                                .toolbar {
                                    ASACloseButton(action: {
                                        showingDetailView = false
                                        detailType = .none
                                    })
                                }
                        }
                        .onReceive(
                            clock.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                userData.savePreferences(code: .complications)
                            }
                    }
                } else {
                    Menu {
                        Button(action: {
                            detailType = .clockDetail
                            showingDetailView = true
                        }) {
                            ASAGetInfoLabel()
                        }
                        
                        let numberOfDateEvents = processedClock.dateEvents.count
                        let numberOfTimeEvents = processedClock.timeEvents.count
                        if numberOfDateEvents > 0 {
                            Menu {
                                ASAClockAllDayEventVisibilityForEach(allDayEventVisibility: $clock.allDayEventVisibility)
                            } label: {
                                Text("Show All-Day Events")
                            }
                        }
                        if numberOfTimeEvents > 0 {
                            
                            Menu {
                                ASAClockEventVisibilityForEach(eventVisibility: $clock.eventVisibility)
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
                        ASAClockMenuSymbol()
                    }
                    .onReceive(
                        clock.objectWillChange) { _ in
                            // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                            DispatchQueue.main.async {
                                userData.savePreferences(code: isForComplications ? .complications : .clocks)
                            }
                        }
                        .sheet(isPresented: $showingDetailView, onDismiss: {
                            //                        debugPrint("❎ Clock cell detail view was dismissed.")
                        }, content: {
                            ASAClockCellDetailView(processedClock: processedClock, now: $now, showingDetailView: $showingDetailView, detailType: Binding(get: { () -> ASAClockCell.DetailType in
                                return self.detailType
                            }, set: { newValue in
                                self.detailType = newValue
                            }), clock: clock, location: location).environmentObject(userData)
                        })
                }
#endif
            } // HStack
            
#if os(watchOS)
#else
            if !isForComplications {
                ASAClockEventsSubcell(processedClock: processedClock, now: $now, eventVisibility: $clock.eventVisibility, allDayEventVisibility: $clock.allDayEventVisibility, clock: clock, location: location)
            }
#endif
        } // VStack
        .frame(minHeight:  MINIMUM_HEIGHT)
    } // var body
} // struct ASAClockCell


#if os(watchOS)
#else
struct ASAClockCellDetailView: View {
    @EnvironmentObject var userData:  ASAModel
    
    var processedClock:  ASAProcessedClock
    @Binding var now:  Date
    @Binding var showingDetailView: Bool
    @Binding var detailType: ASAClockCell.DetailType
    
    @State private var action:  EKEventEditViewAction? = nil
    @ObservedObject var eventManager = ASAEKEventManager.shared
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    var body: some View {
        if detailType == .clockDetail {

            NavigationStack {
                ASAClockDetailView(selectedClock: clock, location: location, usesDeviceLocation: processedClock.usesDeviceLocation, now: self.now, shouldShowTime: true, deletable: true, forAppleWatch: false, tempLocation: location)
                    .toolbar {
                        ASACloseButton(action: {
                            showingDetailView = false
                            detailType = .none
                        })
                    }
                    .onReceive(clock.objectWillChange) { _ in
                        // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                        userData.savePreferences(code: .clocks)
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
    @Binding var allDayEventVisibility: ASAClockCellDateEventVisibility
    
    var body: some View {
        ForEach(ASAClockCellDateEventVisibility.allCases, id: \.self) {
            visibility
            in
            Button(action: {
                allDayEventVisibility = visibility
            }) {
                ASAClockMenuVisibilityLabel(text: visibility.text, shouldShowCheckmark: visibility == allDayEventVisibility)
            }
        } // ForEach
    } // var body
} // struct ASAClockAllDayEventVisibilityForEach

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
    var clock: ASAClock
    var location: ASALocation
    
    var body: some View {
#if os(watchOS)
        EmptyView()
#else
        let VERTICAL_INSET: CGFloat   = 0.0
        let HORIZONTAL_INSET: CGFloat = 8.0
        let numberOfDateEvents: Int = processedClock.dateEvents.count
        if numberOfDateEvents > 0 {
            let dateEvents = processedClock.dateEvents.trimmed(dateEventVisibility: allDayEventVisibility, now: now)
            ASAClockEventsForEach(processedClock: processedClock, events: dateEvents, now: $now, clock: clock, location: location)
                .listRowInsets(EdgeInsets(top: VERTICAL_INSET, leading: HORIZONTAL_INSET, bottom: VERTICAL_INSET, trailing: HORIZONTAL_INSET))
        }
        let numberOfTimeEvents: Int = processedClock.timeEvents.count
        if numberOfTimeEvents > 0 {
            let timeEvents = processedClock.timeEvents.trimmed(timeEventVisibility: eventVisibility, now: now)
            ASAClockEventsForEach(processedClock: processedClock, events: timeEvents, now: $now, clock: clock, location: location)
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
    var clock:  ASAClock
    var location: ASALocation
    
    var body: some View {
        let rangeStart: Date = processedClock.startOfDay
        let rangeEnd: Date   = processedClock.startOfNextDay
        let bodyLineHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight
        let linkedEventCellHeight: CGFloat = bodyLineHeight * 1.5
        
        ForEach(events, id: \.eventIdentifier) {
            event
            in
            
            let eventIsTodayOnly   = event.isOnlyForRange(rangeStart: rangeStart, rangeEnd: rangeEnd)
            let usesDeviceLocation = processedClock.usesDeviceLocation
            let (startDateString, endDateString) = (event.startDateString == nil && event.endDateString == nil) ? clock.startAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location) : (event.startDateString, event.endDateString)
            
            ASALinkedEventCell(event: event, primaryClock: clock, now: now, location: location, usesDeviceLocation: usesDeviceLocation, isForClock: true, eventIsTodayOnly: eventIsTodayOnly, startDateString: startDateString, endDateString: endDateString!)
                .frame(height: linkedEventCellHeight)
        } // ForEach
    } // var body
} // struct ASAClockEventsForEach


// MARK:  -

//struct ASAClockCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASAClockCell(processedClock: ASAProcessedClock(clock: ASAClock.generic, now: Date(), isForComplications: false, location: .nullIsland, usesDeviceLocation: false), now: .constant(Date()), shouldShowTime: true, shouldShowMiniCalendar: true, isForComplications: false, indexIsOdd: true, eventVisibility: .all, clock: ASAClock.generic, location: ASALocation.earthUniversal)
//    }
//} // struct ASAClockCell_Previews




