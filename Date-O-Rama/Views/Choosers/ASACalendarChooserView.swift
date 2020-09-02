//
//  ASACalendarChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASACalendarChooserView: View {
    let calendarCodes:  Array<ASACalendarCode> = [
        .Gregorian,
        .Buddhist,
        .CCSDSJulianDay,
        .Chinese,
        .CNESJulianDay,
        .Coptic,
        .DublinJulianDay,
        .EthiopicAmeteAlem,
        .EthiopicAmeteMihret,
        .Hebrew,
        .HebrewGRA,
        .HebrewMA,
        .Indian,
        .Islamic,
        .IslamicSolar,
        .IslamicCivil,
        .IslamicCivilSolar,
        .IslamicTabular,
        .IslamicTabularSolar,
        .IslamicUmmAlQura,
        .IslamicUmmAlQuraSolar,
        .ISO8601,
        .Japanese,
        .JulianDay,
        .LilianDate,
        .ModifiedJulianDay,
        .Persian,
        .RataDie,
        .ReducedJulianDay,
        .RepublicOfChina,
        .TruncatedJulianDay
    ]
    
    @ObservedObject var row:  ASARow
    @State var tempCalendarCode:  ASACalendarCode

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    let ALL_CALENDARS        = 0
    let APPLE_CALENDARS      = 1
    let SOLAR_CALENDARS      = 2
    let LUNISOLAR_CALENDARS  = 3
    let LUNAR_CALENDARS      = 4
    let JULIAN_DAY_CALENDARS = 5

    @State var selection = 0 // All calendars
    
    func calendarCodes(option:  Int) -> Array<ASACalendarCode> {
        let rawResult: [ASACalendarCode] = self.calendarCodes.filter {
            switch selection {
            case ALL_CALENDARS:
                return true
                
            case APPLE_CALENDARS:
                return $0.isAppleCalendar() || $0.isISO8601Calendar()
                
            case SOLAR_CALENDARS:
                return $0.type == .solar
                
            case LUNISOLAR_CALENDARS:
                return $0.type == .lunisolar
                
            case LUNAR_CALENDARS:
                return $0.type == .lunar
                
            case JULIAN_DAY_CALENDARS:
                return $0.type == .JulianDay
                
            default:
                return false
            } // switch selection
        }
        let result = rawResult.sorted {
            $0.localizedName() < $1.localizedName()
        }
        return result
    } // func calendarCodes(option:  Int) -> Array<ASACalendarCode>

    var body: some View {
        List {
            Picker(selection: $selection, label:
                Text("Show calendars:")
                , content: {
                    Text("All calendars").tag(ALL_CALENDARS)
                    Text("Apple calendars").tag(APPLE_CALENDARS)
                    Text("Solar calendars").tag(SOLAR_CALENDARS)
                    Text("Lunisolar calendars").tag(LUNISOLAR_CALENDARS)
                    Text("Lunar calendars").tag(LUNAR_CALENDARS)
                    Text("Julian day calendars").tag(JULIAN_DAY_CALENDARS)
            })
            
            ForEach(self.calendarCodes(option: selection), id: \.self) {
                calendarCode
                in
                ASACalendarCell(calendarCode: calendarCode, selectedCalendarCode: self.$tempCalendarCode)
                    .onTapGesture {
                    self.tempCalendarCode = calendarCode
                }
            }
        }
//        .navigationBarTitle(Text(row.dateString(now: Date()) ))
        .navigationBarItems(trailing:
            Button("Cancel", action: {
                self.didCancel = true
                self.presentationMode.wrappedValue.dismiss()
            })
        )
            .onAppear() {
                self.tempCalendarCode = self.row.calendar.calendarCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.row.calendar = ASACalendarFactory.calendar(code: self.tempCalendarCode)!
                }
            }
        }
    }


struct ASACalendarCell: View {
    let calendarCode: ASACalendarCode

    @Binding var selectedCalendarCode: ASACalendarCode
    
    var body: some View {
        HStack {
            Text(verbatim: calendarCode.localizedName())
            Spacer()
            if self.calendarCode == self.selectedCalendarCode {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    } // var body
} // struct ASACalendarCell

struct ASACalendarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarChooserView(row: ASARow.test(), tempCalendarCode: .Gregorian)
    }
}
