//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation

class ASARow: NSObject, ObservableObject, Identifiable {    
    var uid = UUID()
    @Published var dummy = false
    
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian)
        
    @Published var localeIdentifier:  String = Locale.current.identifier
    
    @Published var majorDateFormat:  ASAMajorFormat = .full {
        didSet {
            if dateGeekFormat.isEmpty {
                self.dateGeekFormat = self.calendar.defaultDateGeekCode(majorDateFormat: self.majorDateFormat)
            }
        } // didset
    } // var majorDateFormat
    @Published var dateGeekFormat:  String = "eMMMdy"
    
    
    // MARK: -
    
    public func dictionary() -> Dictionary<String, String?> {
        let result = [
            "locale":  localeIdentifier,
            //                "calendar":  calendarCode.rawValue,
            "calendar":  calendar.calendarCode.rawValue,
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
            let code = ASACalendarCode(rawValue: calendarCode!!) ?? ASACalendarCode.Gregorian
            newRow.calendar = ASACalendarFactory.calendar(code: code)!
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
        temp.calendar = ASAAppleCalendar(calendarCode: .Gregorian)
        temp.localeIdentifier = ""
        temp.majorDateFormat = .full
        
        return temp
    } // func generic() -> ASARow
    
    class func test() -> ASARow {
        let temp = ASARow()
        temp.calendar = ASAAppleCalendar(calendarCode: .Gregorian)
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
        tempRow.calendar = ASACalendarFactory.calendar(code: self.calendar.calendarCode)!
        tempRow.localeIdentifier = self.localeIdentifier
        tempRow.majorDateFormat = self.majorDateFormat
        tempRow.dateGeekFormat = self.dateGeekFormat
        return tempRow
    } // func copy() -> ASARow
    
    
    //MARK: -
    
    public func dateString(now:  Date, defaultLocation:  CLLocation) -> String {
        return self.calendar.dateString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: self.majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: .medium, timeGeekFormat: "HH:mm:ss", location: defaultLocation, timeZone: TimeZone.autoupdatingCurrent)
    } // func dateString(now:  Date) -> String
    
    public func dateString(now:  Date, LDMLString:  String, defaultLocation:  CLLocation) -> String {
        return self.calendar.dateString(now: now, localeIdentifier: self.localeIdentifier, LDMLString: LDMLString, location: defaultLocation, timeZone: TimeZone.autoupdatingCurrent)
    } // func dateString(now:  Date, LDMLString:  String) -> String
    
    
    // MARK: -
    
    public func details() -> Array<ASALDMLDetail> {
        return self.calendar.LDMLDetails()
    } // public func details() -> Array<ASADetail>
    
    public func supportsLocales() -> Bool {
        return self.calendar.supportsLocales()
    } // func supportsLocales() -> Bool
} // class ASARow: NSObject
