//
//  ASAConfiguration.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2017-12-24.
//  Copyright © 2017 Adelsoft. All rights reserved.
//

import UIKit

let ASAMessageKeyType = "type"
let ASAMessageKeyRequestComplicationData = "requestComplicationData"
let ASAMessageKeyUpdateComplicationData = "updateComplicationData"

public let localeSubkey = "Locale"
public let calendarSubkey = "Calendar"
public let majorDateFormatSubkey = "MajorDateFormat"
public let geekFormatSubkey = "GeekFormat"

enum ASAMajorDateFormat:  String {
    case short         = "short"
    case medium        = "medium"
    case long          = "long"
    case full          = "full"
    case localizedLDML = "loc"
    case rawLDML       = "raw"
} // enum ASAMajorDateFormat:  String

public let shortDateFormatKey  = "short"
public let mediumDateFormatKey = "medium"
public let longDateFormatKey   = "long"
public let fullDateFormatKey   = "full"
public let localizedLDMLMajorDateFormatKey = "localizedLDML"
public let rawLDMLMajorDateFormatKey = "rawLDML"

let storageKey = "group.com.adelsoft.DoubleDate"

let defaults =
    UserDefaults.init(suiteName: storageKey)

class ASAConfiguration: NSObject {
    public static let calendarCodes = [
        ASACalendarCode.Gregorian,
        ASACalendarCode.Buddhist,
        ASACalendarCode.Chinese,
        ASACalendarCode.Coptic,
        ASACalendarCode.EthiopicAmeteAlem,
        ASACalendarCode.EthiopicAmeteMihret,
        ASACalendarCode.Hebrew,
        ASACalendarCode.Indian,
        ASACalendarCode.Islamic,
        ASACalendarCode.IslamicCivil,
        ASACalendarCode.IslamicTabular,
        ASACalendarCode.IslamicUmmAlQura,
        ASACalendarCode.ISO8601,
        ASACalendarCode.Japanese,
        ASACalendarCode.Persian,
        ASACalendarCode.RepublicOfChina
     ]
    
    public static func configureDefaults() -> Void {
        let defaultSettings = [:] as [String : Any]
        
        defaults?.register(defaults: defaultSettings)
    } // public func configureDefaults()
    
    // MARK: -
    
    public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey) {
        var temp:  Array<Dictionary<String, String?>> = []
        for row in rowArray {
            let dictionary = row.dictionary()
            temp.append(dictionary)
        }
        
        defaults?.set(temp, forKey: key.rawValue)
        defaults?.synchronize()
    } // public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey)
    
    public func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
        let temp = defaults?.array(forKey: key.rawValue)
        var tempArray:  Array<ASARow> = []
        
        if temp != nil {
            for dictionary in temp! {
                let row = ASARow.newRow(dictionary: dictionary as! Dictionary<String, String?>)
                tempArray.append(row)
            } // for dictionary in temp!
        }
        
        let numberOfRows = tempArray.count
        let minimumNumberOfRows = key.minimumNumberOfRows()
        if numberOfRows < minimumNumberOfRows {
            
            tempArray += Array.init(repeatElement(ASARow.generic(), count: minimumNumberOfRows - numberOfRows))
        }
        
        return tempArray
    } // public func rowArray(key:  ASARowArrayKey) -> Array<ASARow>?
    
} // class ASAConfiguration: NSObject
