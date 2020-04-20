//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit

struct ASADetail {
    var name:  String
    var geekCode:  String
} // struct ASADetail

//MARK: -

class ASARow: NSObject, ObservableObject, Identifiable {
    let genericISOGeekFormat = "yyyy-MM-dd"
    
    var uid = UUID()
    @Published var dummy = false
    @Published var calendarCode:  ASACalendarCode = .Gregorian {
        didSet {
            self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()

            if self.calendarCode.usesDateFormatter() {
                // Need to use a DateFormatter
                dateFormatter.timeStyle = .none
                dateFormatter.timeZone = .current
                dateFormatter.calendar = Calendar(identifier: calendarIdentifier!)
            } else if self.calendarCode.ISO8601AppleCalendar() {
                // Need to use an ISO8601DateFormatter
                ISODateFormatter.timeZone = TimeZone.current
                self.dateGeekFormat = self.genericISOGeekFormat
                self.majorDateFormat = .localizedLDML
            }
        } // didset
    } // var calendarCode:  String
    
    @Published var localeIdentifier:  String = Locale.current.identifier {
        didSet {
            if self.localeIdentifier == "" {
                self.dateFormatter.locale = Locale.current
            } else {
                self.dateFormatter.locale = Locale(identifier: self.localeIdentifier)
            }
        } // didSet
    } // var localeIdentifier:  String
    
    @Published var majorDateFormat:  ASAMajorFormat = .full {
        didSet {
            if calendarCode.usesDateFormatter() {
                dateFormatter.dateStyle = .full
                
                switch self.majorDateFormat {
                case .full:
                    dateFormatter.dateStyle = .full
                    self.dateGeekFormat = "eee, d MMM y"
                    
                case .long:
                    dateFormatter.dateStyle = .long
                    self.dateGeekFormat = "eee, d MMM y"
                    
                case .medium:
                    dateFormatter.dateStyle = .medium
                    self.dateGeekFormat = "eee, d MMM y"

                case .short:
                    dateFormatter.dateStyle = .short
                    self.dateGeekFormat = "eee, d MMM y"

                default:
                    dateFormatter.dateStyle = .full
                    if self.dateGeekFormat.isEmpty {
                        self.dateGeekFormat = "eee, d MMM y"
                    }
               } // switch newValue
            } else if calendarCode.ISO8601AppleCalendar() {
                switch calendarCode {
                case ASACalendarCode.ISO8601:
                    self.dateGeekFormat = self.genericISOGeekFormat
                    ISODateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
                                        
                default:
                    ISODateFormatter.formatOptions = []
                }
            }
        } // didset
    } // var majorDateFormat
    @Published var dateGeekFormat:  String = "eMMMdy"
    
    var calendarIdentifier:  Calendar.Identifier?
    
    lazy var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()
    
    
    // MARK: -
    
    public func dictionary() -> Dictionary<String, String?> {
        let result = [
                "locale":  localeIdentifier,
                "calendar":  calendarCode.rawValue,
                "majorDateFormat":  majorDateFormat.rawValue ,
                "geekFormat":  dateGeekFormat
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
            newRow.majorDateFormat = ASAMajorFormat(rawValue: majorDateFormat!!)!
        }
        
        let geekFormat = dictionary["geekFormat"]
        if geekFormat != nil {
            newRow.dateGeekFormat = geekFormat!!
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
    
    class func test() -> ASARow {
        let temp = ASARow()
        temp.calendarCode = ASACalendarCode.Gregorian
        temp.localeIdentifier = "en_US"
        temp.majorDateFormat = .localizedLDML
        temp.dateGeekFormat = "eeeyMMMd"
        
        return temp
    } // func generic() -> ASARow
    
    class func dummy() -> ASARow {
        let temp = ASARow()
        temp.dummy = true
        return temp
    } // func dummy() -> ASARow
    
    func copy() -> ASARow {
        let tempRow = ASARow()
        tempRow.calendarCode = self.calendarCode
        tempRow.localeIdentifier = self.localeIdentifier
        tempRow.majorDateFormat = self.majorDateFormat
        tempRow.dateGeekFormat = self.dateGeekFormat
        return tempRow
    } // func copy() -> ASARow
    
    
    //MARK: -
    
    public func dateString(now:  Date) -> String {
        if self.calendarCode == ASACalendarCode.None {
            return ""
        }
        
        var dateString:  String
        
        // FOR TESTING PURPOSES
//        self.dateFormatter.timeStyle = .medium
        // END TESTING
        
        if self.calendarCode.ISO8601AppleCalendar() {
            let options = self.dateGeekFormat.chop()
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
        
//        if self.majorDateFormat == .rawLDML {
//            self.dateFormatter.dateFormat = self.geekFormat
//            return self.dateFormatter.string(from: now)
//        }
        
        if self.majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:self.dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
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
    } // func dateString(now:  Date) -> String
    
    public func dateString(now:  Date, LDMLString:  String) -> String {
        if self.calendarCode == .ISO8601 {
            self.dateFormatter.locale = Locale(identifier: "en_US")
        }
        
        self.dateFormatter.dateFormat = LDMLString
        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateString(now:  Date, LDMLString:  String) -> String
    
    
    // MARK: -
    
    public func details() -> Array<ASADetail> {
        if self.calendarCode == .ISO8601 {
            return [
                ASADetail(name: "HEADER_y", geekCode: "yyyy"),
                ASADetail(name: "HEADER_M", geekCode: "MM"),
                ASADetail(name: "HEADER_d", geekCode: "dd"),
                ASADetail(name: "HEADER_Y", geekCode: "Y"),
                ASADetail(name: "HEADER_w", geekCode: "ww"),
                ASADetail(name: "HEADER_E", geekCode: "e"),
                ASADetail(name: "HEADER_g", geekCode: "g")
            ]
        } else {
            return [
                ASADetail(name: "HEADER_G", geekCode: "GGGG"),
                ASADetail(name: "HEADER_y", geekCode: "y"),
                ASADetail(name: "HEADER_M", geekCode: "MMMM"),
                ASADetail(name: "HEADER_d", geekCode: "d"),
                ASADetail(name: "HEADER_E", geekCode: "eeee"),
                ASADetail(name: "HEADER_Q", geekCode: "QQQQ"),
                ASADetail(name: "HEADER_Y", geekCode: "Y"),
                ASADetail(name: "HEADER_w", geekCode: "w"),
                ASADetail(name: "HEADER_W", geekCode: "W"),
                ASADetail(name: "HEADER_F", geekCode: "F"),
                ASADetail(name: "HEADER_D", geekCode: "D"),
                ASADetail(name: "HEADER_U", geekCode: "UUUU"),
                ASADetail(name: "HEADER_r", geekCode: "r"),
                ASADetail(name: "HEADER_g", geekCode: "g")
            ]
        }
    } // public func details() -> Array<ASADetail>
    
    public func supportsLocales() -> Bool {
        if self.calendarCode == .ISO8601 {
            return false
        } else {
            return true
        }
    } // func supportsLocales() -> Bool
} // class ASARow: NSObject
