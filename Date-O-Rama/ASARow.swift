//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit

//MARK: -

class ASARow: NSObject {    
    var secretCalendarCode:  ASACalendarCode = .None
    
    public var calendarCode:  ASACalendarCode {
        set {
            self.calendarIdentifier = equivalentCalendarIdentifier(calendarCode: newValue)
            
            if newValue.usesDateFormatter() {
                // Need to use a DateFormatter
                dateFormatter.timeStyle = .none
                dateFormatter.timeZone = .current
                dateFormatter.calendar = Calendar(identifier: calendarIdentifier!)
                
            } else if newValue.ISO8601AppleCalendar() {
                // Need to use an ISO8601DateFormatter
                ISODateFormatter.timeZone = TimeZone.current
            }
            
            secretCalendarCode = newValue
        } // set
        
        get {
            return secretCalendarCode
        } // get
    } // public var calendarCode:  String
    
    var secretLocaleIdentifier:  String = ""
    public var localeIdentifier:  String {
        set {
            if newValue == "" {
                self.dateFormatter.locale = Locale.current
            } else {
                self.dateFormatter.locale = Locale(identifier: newValue)
            }
            
            secretLocaleIdentifier = newValue
        }
        
        get {
            return secretLocaleIdentifier
        }
    } // public var localeIdentifier:  String
    
    var secretMajorDateFormat:  ASAMajorDateFormat = .long
    public var majorDateFormat:  ASAMajorDateFormat {
        set {
            if calendarCode.usesDateFormatter() {
                dateFormatter.dateStyle = .full
                
                switch newValue {
                case .full:
                    dateFormatter.dateStyle = .full
                    self.geekFormat = "eee, d MMM y"
                    
                case .long:
                    dateFormatter.dateStyle = .long
                    self.geekFormat = "eee, d MMM y"
                    
                case .medium:
                    dateFormatter.dateStyle = .medium
                    self.geekFormat = "eee, d MMM y"

                case .short:
                    dateFormatter.dateStyle = .short
                    self.geekFormat = "eee, d MMM y"

                default:
                    dateFormatter.dateStyle = .full
                    if self.geekFormat.isEmpty {
                        self.geekFormat = "eee, d MMM y"
                    }
               } // switch newValue
            } else if calendarCode.ISO8601AppleCalendar() {
                switch calendarCode {
                case ASACalendarCode.ISO8601:
                    self.geekFormat = "yyyy-MM-dd"
                    ISODateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
                                        
                default:
                    ISODateFormatter.formatOptions = []
                }
            }
            
            secretMajorDateFormat = newValue
        } // set
        
        get {
            return secretMajorDateFormat
        } // get
    }
    public var geekFormat:  String = "eMMMdy"
    
    var calendarIdentifier:  Calendar.Identifier?
    
    lazy var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()
    
    
    // MARK: -
    
    func equivalentCalendarIdentifier(calendarCode:  ASACalendarCode) -> Calendar.Identifier {
        var calendarIdentifier:  Calendar.Identifier
        switch calendarCode {
        case ASACalendarCode.Buddhist:
            calendarIdentifier = .buddhist
            
        case ASACalendarCode.Chinese:
            calendarIdentifier = .chinese
            
        case ASACalendarCode.Coptic:
            calendarIdentifier = .coptic
            
        case ASACalendarCode.EthiopicAmeteAlem:
            calendarIdentifier = .ethiopicAmeteAlem
            
        case ASACalendarCode.EthiopicAmeteMihret:
            calendarIdentifier = .ethiopicAmeteMihret
            
        case ASACalendarCode.Gregorian:
            calendarIdentifier = .gregorian
            
        case ASACalendarCode.Hebrew:
            calendarIdentifier = .hebrew
            
        case ASACalendarCode.Indian:
            calendarIdentifier = .indian
            
        case ASACalendarCode.Islamic:
            calendarIdentifier = .islamic
            
        case ASACalendarCode.IslamicCivil:
            calendarIdentifier = .islamicCivil
            
        case ASACalendarCode.IslamicTabular:
            calendarIdentifier = .islamicTabular
            
        case ASACalendarCode.IslamicUmmAlQura:
            calendarIdentifier = .islamicUmmAlQura
            
        case ASACalendarCode.ISO8601:
            calendarIdentifier = .gregorian
            
        case ASACalendarCode.Japanese:
            calendarIdentifier = .japanese
            
        case ASACalendarCode.Persian:
            calendarIdentifier = .persian
            
        case ASACalendarCode.RepublicOfChina:
            calendarIdentifier = .republicOfChina
            
        default:
            calendarIdentifier = .gregorian
        } // switch calendarCode
        
        return calendarIdentifier
    } // func calendarIdentifier(calendarCode:  String) -> Calendar.Identifier
    
    public func dictionary() -> Dictionary<String, String?> {
        let result = [
                "locale":  localeIdentifier,
                "calendar":  calendarCode.rawValue,
                "majorDateFormat":  majorDateFormat.rawValue,
                "geekFormat":  geekFormat
        ]
        return result
    } // public func dictionary() -> Dictionary<String, String?>
    
    public class func newRow(dictionary:  Dictionary<String, String?>) -> ASARow {
        let newRow = ASARow()
        
        let localeIdentifier = dictionary["locale"]
        if localeIdentifier != nil {
            newRow.localeIdentifier = localeIdentifier!!
        }

        let calendarCode = dictionary["calendar"]
        if calendarCode != nil {
            newRow.calendarCode = ASACalendarCode(rawValue: calendarCode!!)!
        }
        
        let majorDateFormat = dictionary["majorDateFormat"]
        if majorDateFormat != nil {
            newRow.majorDateFormat = ASAMajorDateFormat(rawValue: majorDateFormat!!)!
        }
        
        let geekFormat = dictionary["geekFormat"]
        if geekFormat != nil {
            newRow.geekFormat = geekFormat!!
        }
        
        return newRow
    } // func newRowFromDictionary(dictionary:  Dictionary<String, String?>) -> ASARow
    
    class func generic() -> ASARow {
        let temp = ASARow()
        temp.calendarCode = ASACalendarCode.Gregorian
        temp.localeIdentifier = ""
        temp.majorDateFormat = .full
        
        return temp
    } // func generic() -> ASARow
    
    func copy() -> ASARow {
        let tempRow = ASARow()
        tempRow.calendarCode = self.calendarCode
        tempRow.localeIdentifier = self.localeIdentifier
        tempRow.majorDateFormat = self.majorDateFormat
        tempRow.geekFormat = self.geekFormat
        return tempRow
    } // func copy() -> ASARow
    
    //MARK: -
    
    public func dateString(now:  Date) -> String {
        if self.calendarCode == ASACalendarCode.None {
            return ""
        }
        
        var dateString:  String
        
        if self.calendarCode.ISO8601AppleCalendar() {
            let options = self.geekFormat.chop()
            var formatterOptions:  ISO8601DateFormatter.Options = []
            for o in options {
                switch o {
                case "yyyy":  formatterOptions.insert(.withYear)
                    
                case "MM":  formatterOptions.insert(.withMonth)
                    
                case "dd":  formatterOptions.insert(.withDay)
                    
                case "ww":  formatterOptions.insert(.withWeekOfYear)
                    
                case "-":  formatterOptions.insert(.withDashSeparatorInDate)
                    
                default:  do {}
                } // switch o
            }
            self.ISODateFormatter.formatOptions = formatterOptions
            dateString = self.ISODateFormatter.string(from: now)
            return dateString
        }
        
        if self.majorDateFormat == .rawLDML {
            self.dateFormatter.dateFormat = self.geekFormat
            return self.dateFormatter.string(from: now)
        }
        
        if self.majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:self.geekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            return self.dateFormatter.string(from: now)
        }
        
        if self.majorDateFormat == .full {
            self.dateFormatter.dateStyle = .full
            return self.dateFormatter.string(from: now)
        }
        
        if self.majorDateFormat == .long {
            self.dateFormatter.dateStyle = .long
            return self.dateFormatter.string(from: now)
        }
        
        if self.majorDateFormat == .medium {
            self.dateFormatter.dateStyle = .medium
            return self.dateFormatter.string(from: now)
        }
        
        if self.majorDateFormat == .short {
            self.dateFormatter.dateStyle = .short
            return self.dateFormatter.string(from: now)
        }
        
        return "Error!"
    } // public static func dateString(now:  Date) -> String

} // class ASARow: NSObject




