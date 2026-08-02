//
//  ASATimesSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

fileprivate let PRIMARY_COLOR   = Color.white
fileprivate let SECONDARY_COLOR = Color(red: 0.75, green: 0.75, blue: 0.75)


struct ASATimesSubcell:  View {
    var event:  ASAEventCompatible
    var clock:  ASAClock
    
#if os(watchOS)
let compact = true
#else
@Environment(\.horizontalSizeClass) var sizeClass
var compact:  Bool {
    return self.sizeClass == .compact
} // var compact
#endif
    
    var timeWidth:  CGFloat {
            #if os(watchOS)
            return 90.0
            #else
            if self.isForClock {
                return 82.5
            }
            
            if compact {
                return  90.00
            } else {
                return 120.00
            }
            #endif
    } // var timeWidth
    let timeFontSize = Font.subheadlineMonospacedDigit
    
    var isForClock: Bool
    var isPrimaryClock: Bool
    var eventIsTodayOnly: Bool
    var startDateString: String?
    var endDateString: String
    var isSecondary: Bool
    
    var body: some View {
        let shouldShowEndDate = (startDateString != endDateString)

        if compact {
            VStack(alignment: .leading) {
                if startDateString != nil {
                    let pastCutoffDate: Bool = event.startDate < Date()
                    let foregroundStyle: Color = pastCutoffDate ? SECONDARY_COLOR : PRIMARY_COLOR
                    
                    ASATimeText(verbatim: startDateString!, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, isForClock: isForClock)
                        .foregroundStyle(foregroundStyle)
                }
                
                if shouldShowEndDate {
                    let pastCutoffDate: Bool = event.endDate < Date()
                    let foregroundStyle: Color = pastCutoffDate ? SECONDARY_COLOR : PRIMARY_COLOR
                    
                    ASATimeText(verbatim: endDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate ?? event.startDate, isForClock: isForClock)
                        .foregroundStyle(foregroundStyle)
                }
            } // VStack
        } else {
            let string = shouldShowEndDate ? ((isSecondary ? "(" : "") + (startDateString ?? "") + (startDateString != nil ? "—" : "") + endDateString + (isSecondary ? ")" : "")) : startDateString
            let cutoffDate = event.endDate ?? event.startDate!
            let pastCutoffDate: Bool = cutoffDate < Date()
            let foregroundStyle: Color = pastCutoffDate ? SECONDARY_COLOR : PRIMARY_COLOR
            Text(verbatim:  string ?? "")
                .font(timeFontSize)
                .foregroundStyle(foregroundStyle)
                .modifier(ASAScalable(lineLimit: 1))
                .multilineTextAlignment(.leading)
        }
    } // var body
} // struct ASATimesSubcell


struct ASATimeText:  View {
    var verbatim:  String
    var timeWidth:  CGFloat
    var timeFontSize:  Font
    var cutoffDate:  Date
    var isForClock:  Bool
    
    #if os(watchOS)
    let compact = true
    #else
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
    } // var compact
    #endif
    
    var body:  some View {
        let pastCutoffDate: Bool = cutoffDate < Date()
        let foregroundStyle: Color = pastCutoffDate ? SECONDARY_COLOR : PRIMARY_COLOR
        
        #if os(watchOS)
        Text(verbatim:  verbatim)
            .font(timeFontSize)
            .foregroundStyle(foregroundStyle)
            .modifier(ASAScalable(lineLimit: 1))
        #else
        if compact {
        Text(verbatim:  verbatim)
            .frame(width:  timeWidth)
            .font(timeFontSize)
            .foregroundStyle(foregroundStyle)
            .modifier(ASAScalable(lineLimit: 2))
            .multilineTextAlignment(.leading)
        } else {
            Text(verbatim:  verbatim)
                .font(timeFontSize)
                .foregroundStyle(foregroundStyle)
                .modifier(ASAScalable(lineLimit: 2))
                .multilineTextAlignment(.leading)
        }
        #endif
    } // var body
} // struct ASATimesText

//struct ASATimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimesSubcell()
//    }
//}
