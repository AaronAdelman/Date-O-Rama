//
//  ASACalendarChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

let ALL_CALENDARS        = 0
let APPLE_CALENDARS      = 1
let SOLAR_CALENDARS      = 2
let LUNISOLAR_CALENDARS  = 3
let LUNAR_CALENDARS      = 4
let JULIAN_DAY_CALENDARS = 5

fileprivate extension Int {
    var calendarCategoryText:  String {
        get {
            switch self {
            case ALL_CALENDARS:
                return NSLocalizedString("All calendars", comment: "")

            case APPLE_CALENDARS:
                return NSLocalizedString("Apple calendars", comment: "")

            case SOLAR_CALENDARS:
                return NSLocalizedString("Solar calendars", comment: "")

            case LUNISOLAR_CALENDARS:
                return NSLocalizedString("Lunisolar calendars", comment: "")

            case LUNAR_CALENDARS:
                return NSLocalizedString("Lunar calendars", comment: "")

            case JULIAN_DAY_CALENDARS:
                return NSLocalizedString("Julian day calendars", comment: "")

            default:
                return ""
            }
        } // get
    } // var calendarCategoryText:  String
} // extension Int

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
        .FrenchRepublican,
        .FrenchRepublicanRomme,
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
        .Japanese,
        .Julian,
        .JulianDay,
        .LilianDate,
        .ModifiedJulianDay,
        .Persian,
        .RataDie,
        .ReducedJulianDay,
        .RepublicOfChina,
        .TruncatedJulianDay
    ]
    
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    var usesDeviceLocation: Bool
    @State var tempCalendarCode:  ASACalendarCode

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false

    @State var selection = 0 // All calendars
    
    func calendarCodes(option:  Int) -> Array<ASACalendarCode> {
        let rawResult: [ASACalendarCode] = self.calendarCodes.filter {
            switch selection {
            case ALL_CALENDARS:
                return true
                
            case APPLE_CALENDARS:
                return $0.isAppleCalendar
//                    || $0.isISO8601Calendar
                
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
        let result = rawResult.sorted() {
            $0.localizedName < $1.localizedName
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
        .navigationBarItems(trailing:
                                Button("Cancel", action: {
                                    self.didCancel = true
                                    self.presentationMode.wrappedValue.dismiss()
                                })
        )
        .onAppear() {
            self.tempCalendarCode = self.clock.calendar.calendarCode
        }
        .onDisappear() {
            if !self.didCancel {
                self.clock.calendar = ASACalendarFactory.calendar(code: self.tempCalendarCode)!
                self.clock.enforceSelfConsistency(location: location, usesDeviceLocation: usesDeviceLocation)
            }
        }
    }
}


struct ASACalendarCell: View {
    let calendarCode: ASACalendarCode

    @Binding var selectedCalendarCode: ASACalendarCode
    
    var body: some View {
        HStack {
            Text(verbatim: calendarCode.localizedName)
            Spacer()
            if self.calendarCode == self.selectedCalendarCode {
                ASACheckmarkSymbol()
            }
        }
    } // var body
} // struct ASACalendarCell

struct ASACalendarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarChooserView(clock: ASAClock.generic, location: .NullIsland, usesDeviceLocation: false, tempCalendarCode: .Gregorian)
    }
}
