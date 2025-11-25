//
//  ASAFrenchRepublicanCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

public class ASAFrenchRepublicanCalendar: ASABoothCalendar, ASACalendarWithBlankMonths {
    
    override var daysPerWeek: Int { return 10 }
    
    override var numberOfMonthsInYear: Int { return FrenchRepublicanCalendar.numberOfMonthsInYear }
    
    override var maximumNumberOfWeeksInYear: Int { return 37 }
 
    override var maximumNumberOfWeeksInMonth: Int { return 4 }
    
    override var maximumNumberOfDaysInMonth: Int { return 30 }
    
    override var maximumHour: Int { return 10 }

    override var maximumMinute: Int { return 100 }

    override var maximumSecond: Int { return 100 }
    
    override func daysInMonth(era: Int, year: Int, month: Int) -> Int {
        return FrenchRepublicanCalendar.numberOfDaysIn(month: month, year: year)

    } // func daysInMonth(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int
    
    override func isLeapMonth(era: Int, year: Int, month: Int) -> Bool {
        return month == 13 && isLeapYear(calendarCode: .frenchRepublican, era: era, year: year)
    } // func isLeapMonth(era: Int, year: Int, month: Int) -> Bool
    
    override func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool {
        return FrenchRepublicanCalendar.isLeapYear(year)
    } // func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool
    
    override func dayOfWeek(dateAsJulianDate: Double, month: Int, day: Int) -> Int {
        if month == 13 {
            return 0
        } else {
            let temp: Int = day % 10
            return temp == 0 ? 10 : temp
        }
    }
    
    override func julianDateFrom(era: Int, year: Int, month: Int, day: Int) -> JulianDate {
        return FrenchRepublicanCalendar.julianDateFrom(year: year, month: month, day: day)
    }
    
    override func boothYMD(gregorianComponents: DateComponents) -> (year: Int, month: Int, day: Int) {
        let temp = GregorianCalendar.convert(year: gregorianComponents.year!, month: gregorianComponents.month!, day: gregorianComponents.day!, to: FrenchRepublicanCalendar.self)
        return (temp.year, temp.month, temp.day)
    }
    
    override var secondsInMinute: Int {100}
    override var minutesInHour: Int {100}
    override var isoSecondsInCalendarSeconds: Double {0.864}

    override func gregorianTimeToCalendarTime(hour: Int, minute: Int, second: Int, nanosecond: Int) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        // SI seconds since midnight
        let gregSeconds =
            Double(hour * 3600 + minute * 60 + second) +
            Double(nanosecond) / 1_000_000_000.0

        // Decimal seconds (100000 per day)
        let decTotal = gregSeconds * (100000.0 / 86400.0)

        // Split into integer + fractional parts
        let decTotalInt = floor(decTotal)
        let decFraction = decTotal - decTotalInt

        // Extract hour, minute, second
        let calendarHour = Int(decTotalInt / 10000.0)
        let remAfterHour = decTotalInt - Double(calendarHour * 10000)

        let calendarMinute = Int(remAfterHour / 100.0)
        let calendarSecond = Int(remAfterHour - Double(calendarMinute * 100))

        // FRC fractional part → FRC nanoseconds
        let calendarNanoseconds = Int((decFraction * 1_000_000_000.0).rounded())
        
        assert(calendarHour < 10)
        assert(calendarMinute < 100)
        assert(calendarSecond < 100)
        return (hour: calendarHour,
                minute: calendarMinute,
                second: calendarSecond,
                nanosecond: calendarNanoseconds)
    }

    
    // MARK:  - ASACalendarWithWeeks
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["יום ראשון", "יום שני", "יום שלישי", "יום רביעי", "יום חמישי", "יום שישי", "יום שביעי", "יום שמיני", "יום תשעי", "יום עשירי"]

        case "ar":
            return ["بريميد", "توديدي", "تريدي", "كارتيدي", "كارتيدي", "سكستيدي", "ستيدي", "أوكتيدي", "نونيدي", "ديكادي"]

        default:
            return ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["יום א׳", "יום ב׳", "יום ג׳", "יום ד׳", "יום ה׳", "יום ו׳", "יום ז׳", "יום ח׳", "יום ט׳", "יום י׳"]
            
        case "ar":
            return ["بريميد", "توديدي", "تريدي", "كارتيدي", "كارتيدي", "سكستيدي", "ستيدي", "أوكتيدي", "نونيدي", "ديكادي"]

            
        default:
            return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["א׳", "ב׳", "ג׳", "ד׳", "ה׳", "ו׳", "ז׳", "ח׳", "ט׳", "י׳"]
            
        default:
            return self.weekdaySymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
        } // switch localeIdentifier.localeLanguageCode
    }
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func weekendDays(for regionCode: String?) -> Array<Int> {
        [5, 10]
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK:  - ASACalendarWithMonths
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["ונדמייר", "בּרויּמֶר", "פרִימֶר", "ניבוז", "פּלויּביוז", "ונטוז", "ז׳רמינאל", "פלוראל", "פּרריאל", "מסידור", "תרמידור", "פרוקטידור", "עיבור השנה"]
            
        case "ar":
            return ["فنديميير", "برومير", "فريمير", "نيفوز", "بلوفيوز", "فنتوز", "جرمينال", "فلوريال", "بريريال", "ميسيدور", "تيرميدور", "فروكتيدور", "الأيام الستة في نهاية السنة"]

        default:
            return ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottides"]
        } // case localeIdentifier.localeLanguageCode
    }
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["ונד׳", "בּרו׳", "פרִי׳", "ניב׳", "פּלו׳", "ונט׳", "ז׳רמ׳", "פלו׳", "פּרר׳", "מסי׳", "תרמ׳", "פרו׳", "עה״ש"]

        default:
            return ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss.cu"]
        } // case localeIdentifier.localeLanguageCode
    }
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    }
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.monthSymbols(localeIdentifier: localeIdentifier)
    }
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.shortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithQuarters
    
    override func quarterSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["סתיו", "חורף", "אביב", "קיץ", "עיבור השנה"]
          
        case "ar":
            return ["الخريف", "الشتاء", "الربيع", "الصيف", "الأيام الستة في نهاية السنة"]

        case "en":
            return ["Autumn", "Winter", "Spring", "Summer", "Sansculottides"]
        
        default:
        return ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    override func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4", "Q5"]
    }
    
    override func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.quarterSymbols(localeIdentifier: localeIdentifier)    }
    
    override func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithEras
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return [""]
    }
    
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return [""]
    }

     
    // MARK:  - ASACalendarWithBlankMonths
    
    var blankMonths: Array<Int> = [13]
    
    var blankWeekdaySymbol: String = "∅"
    
} // class ASAFrenchRepublicanCalendar
