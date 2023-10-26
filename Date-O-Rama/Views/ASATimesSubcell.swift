//
//  ASATimesSubcell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATimesSubcell:  View {
    var event:  ASAEventCompatible
    var clock:  ASAClock
    
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
    
    var timeWidth:  CGFloat {
        get {
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
        } // get
    } // var timeWidth
    let timeFontSize = Font.subheadlineMonospacedDigit
    
    var isForClock: Bool
    var isPrimaryClock: Bool
    var eventIsTodayOnly: Bool
    var startDateString: String?
    var endDateString: String
    var isSecondary: Bool
    
    fileprivate func startDateView() -> ASATimeText {
        return ASATimeText(verbatim: startDateString!, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.startDate, isForClock: isForClock)
    }
    
    fileprivate func endDateView() -> ASATimeText {
        return ASATimeText(verbatim: endDateString, timeWidth:  timeWidth, timeFontSize:  timeFontSize, cutoffDate:  event.endDate ?? event.startDate, isForClock: isForClock)
    }
    
    var body: some View {
        let shouldShowEndDate = (startDateString != endDateString)

        if compact {
            VStack(alignment: .leading) {
                if startDateString != nil {
                    startDateView()
                }
                
                if shouldShowEndDate {
                    endDateView()
                }
            } // VStack
        } else {

            let string = shouldShowEndDate ? ((isSecondary ? "(" : "") + (startDateString ?? "") + (startDateString != nil ? "—" : "") + endDateString + (isSecondary ? ")" : "")) : startDateString
            let cutoffDate = event.endDate ?? event.startDate!
            let pastCutoffDate: Bool = cutoffDate < Date()
            let foregroundColor: Color = pastCutoffDate ? .secondary : .primary
            Text(verbatim:  string ?? "")
                .font(timeFontSize)
                .foregroundColor(foregroundColor)
                .modifier(ASAScalable(lineLimit: 1))
                .multilineTextAlignment(.leading)
        }
    } // var body
} // struct ASATimesSubcell

//struct ASATimesSubcell_Previews: PreviewProvider {
//    static var previews: some View {
//        ASATimesSubcell()
//    }
//}
