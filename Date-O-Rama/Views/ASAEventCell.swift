//
//  ASAEventCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-05.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventCell: View {
    var event:  ASAEvent
    
    func formattedStartDate() -> String {
        if event.startDate == nil {
            return "-"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        let tempResult = dateFormatter.string(from: event.startDate!)
        
        let now = Date()
        var parenthesizedTempResult = ""
        if TimeZone.autoupdatingCurrent.secondsFromGMT(for:now) != event.timeZone?.secondsFromGMT(for: now) && event.timeZone != nil {
            dateFormatter.timeZone = event.timeZone
            
            parenthesizedTempResult = String(format: NSLocalizedString("PARENTHESIZED_TIME_FORMAT", comment: ""), dateFormatter.string(from: event.startDate!))
        }
        
        let result = tempResult + parenthesizedTempResult
        
    return result
    }
    
    var textColor:  UIColor {
        get {
            return event.calendar.color.darker(by: 50.0)
        }
    }
    
    var body: some View {
        HStack {
            Text(event.title)
                .bold()
                .foregroundColor(Color(self.textColor))
            Spacer()
            Text(self.formattedStartDate())
                .bold()
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color(self.textColor))
        } // HStack
    }
}

struct ASAEventCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventCell(event: ASAEvent(title: "Foo", startDate: Date(), calendar: ASACalendarFactory.calendar(code: .HebrewGRA)!))
    }
}
