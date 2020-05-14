//
//  ASAConfiguration.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2017-12-24.
//  Copyright © 2017 Adelsoft. All rights reserved.
//

import UIKit

//let ASAMessageKeyType = "type"
//let ASAMessageKeyRequestComplicationData = "requestComplicationData"
//let ASAMessageKeyUpdateComplicationData = "updateComplicationData"
//
//public let localeSubkey = "Locale"
//public let calendarSubkey = "Calendar"
//public let majorDateFormatSubkey = "MajorDateFormat"
//public let geekFormatSubkey = "GeekFormat"
//
//public let shortDateFormatKey  = "short"
//public let mediumDateFormatKey = "medium"
//public let longDateFormatKey   = "long"
//public let fullDateFormatKey   = "full"
//public let localizedLDMLMajorDateFormatKey = "localizedLDML"
//public let rawLDMLMajorDateFormatKey = "rawLDML"

let storageKey = "group.com.adelsoft.DoubleDate"

let defaults =
    UserDefaults.init(suiteName: storageKey)

class ASAConfiguration: NSObject {
//    public static func configureDefaults() -> Void {
////        debugPrint(#file, #function)
//        let defaultSettings = [:] as [String : Any]
//
//        defaults?.register(defaults: defaultSettings)
//    } // public func configureDefaults()
    
    // MARK: -
    
    public class func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey) {
//        debugPrint(#file, #function, rowArray)
        var temp:  Array<Dictionary<String, Any>> = []
        for row in rowArray {
            let dictionary = row.dictionary()
            temp.append(dictionary)
        }
        
        defaults?.set(temp, forKey: key.rawValue)
        defaults?.synchronize()
    } // public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey)
    
    public class func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
//        debugPrint(#file, #function, key)
        
        let temp = defaults?.array(forKey: key.rawValue)
        var tempArray:  Array<ASARow> = []
        
        if temp != nil {
            for dictionary in temp! {
                let row = ASARow.newRow(dictionary: dictionary as! Dictionary<String, Any>)
                tempArray.append(row)
            } // for dictionary in temp!
        }
        
        let numberOfRows = tempArray.count
        let minimumNumberOfRows = key.minimumNumberOfRows()
        if numberOfRows < minimumNumberOfRows {
            
            tempArray += Array.init(repeatElement(ASARow.generic(), count: minimumNumberOfRows - numberOfRows))
        }
        
//        debugPrint(#file, #function, tempArray)
        return tempArray
    } // public func rowArray(key:  ASARowArrayKey) -> Array<ASARow>?
    
} // class ASAConfiguration: NSObject
