//
//  ASAUserData.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-02.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation
import UIKit

let storageKey = "group.com.adelsoft.DoubleDate"

final class ASAUserData:  ObservableObject {
    
    static let userDefaults = UserDefaults.init(suiteName: storageKey)!
    
    private static var sharedUserData: ASAUserData = {
        let userData = ASAUserData()
        
        return userData
    }()
    
    class func shared() -> ASAUserData {
        return sharedUserData
    } // class func shared() -> ASAUserData
    
    @Published var mainRows:  Array<ASARow>
    @Published var internalEventCalendars:  Array<ASAInternalEventCalendar>
    
    @Published var threeLineLargeRows:  Array<ASARow>
    @Published var twoLineSmallRows:    Array<ASARow>
    @Published var twoLineLargeRows:    Array<ASARow>
    @Published var oneLineLargeRows:    Array<ASARow>
    @Published var oneLineSmallRows:    Array<ASARow>

    
    private func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
        var rows = ASAUserData.rowArray(key: key)
        self.internalEventCalendars = ASAUserData.internalEventCalendarArray()
        let coder = CLGeocoder();
        for row in rows {
            if row.location != nil {
                coder.reverseGeocodeLocation(row.location!) { (placemarks, error) in
                    let place = placemarks?.last;
                    
                    if place != nil {
                        row.placeName = place?.name
                        row.locality = place?.locality
                        row.country = place?.country
                        row.ISOCountryCode = place?.isoCountryCode
                    }
                    //                    debugPrint(#file, #function, row.location as Any, place as Any)
                }
            }
        } // for row in rows
        
        while rows.count < key.minimumNumberOfRows() {
            rows.append(ASARow.generic())
        } // while rows.count < key.minimumNumberOfRows()
        
        return rows
    }
        
    init() {
//        self.mainRows = ASAUserData.rowArray(key: .app)
        self.internalEventCalendars = ASAUserData.internalEventCalendarArray()
//        let coder = CLGeocoder();
//        for row in self.mainRows {
//            if row.location != nil {
//                coder.reverseGeocodeLocation(row.location!) { (placemarks, error) in
//                    let place = placemarks?.last;
//
//                    if place != nil {
//                        row.placeName = place?.name
//                        row.locality = place?.locality
//                        row.country = place?.country
//                        row.ISOCountryCode = place?.isoCountryCode
//                    }
//                    //                    debugPrint(#file, #function, row.location as Any, place as Any)
//                }
//            }
//        } // for row in self.mainRows
        mainRows             = []
        threeLineLargeRows     = []
        twoLineSmallRows     = []
        twoLineLargeRows       = []
        oneLineLargeRows = []
        oneLineSmallRows      = []
        
        self.mainRows           = self.rowArray(key: .app)
        self.threeLineLargeRows = self.rowArray(key: .threeLineLarge)
        self.twoLineSmallRows   = self.rowArray(key: .twoLineSmall)
        self.twoLineLargeRows   = self.rowArray(key: .twoLineLarge)
        self.oneLineLargeRows   = self.rowArray(key: .oneLineLarge)
        self.oneLineSmallRows   = self.rowArray(key: .oneLineSmall)
    } // init()
    
    public func savePreferences() {
        self.saveRowArray(rowArray: self.mainRows, key: .app)
        self.saveRowArray(rowArray: self.threeLineLargeRows, key: .threeLineLarge)
        self.saveRowArray(rowArray: self.twoLineLargeRows, key: .twoLineLarge)
        self.saveRowArray(rowArray: self.twoLineSmallRows, key: .twoLineSmall)
        self.saveRowArray(rowArray: self.oneLineLargeRows, key: .oneLineLarge)
        self.saveRowArray(rowArray: self.oneLineSmallRows, key: .oneLineSmall)

        self.saveInternalEventCalendarArray(internalEventCalendarArray: self.internalEventCalendars)
    } // func savePreferences()
    
    
    // MARK: -
    
    public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey) {
        //        debugPrint(#file, #function, rowArray)
        var temp:  Array<Dictionary<String, Any>> = []
        for row in rowArray {
            let dictionary = row.dictionary()
            temp.append(dictionary)
        }
        
        ASAUserData.self.userDefaults.set(temp, forKey: key.rawValue)
        ASAUserData.self.userDefaults.synchronize()
    } // public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey)
    
    class func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
        //        debugPrint(#file, #function, key)
        
        let temp = self.userDefaults.array(forKey: key.rawValue)
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
    } // public func rowArray(key:  ASARowArrayKey) -> Array<ASARow>
    
    func saveInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>) {
        var temp:  Array<Dictionary<String, Any>> = []
        for eventCalendar in self.internalEventCalendars {
            let dictionary = eventCalendar.dictionary()
            temp.append(dictionary)
        } //for eventCalendar in self.internalEventCalendars
        
        ASAUserData.self.userDefaults.set(temp, forKey: INTERNAL_EVENT_CALENDARS_KEY)
        ASAUserData.self.userDefaults.synchronize()
    } // func saveInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>)
    
    class func internalEventCalendarArray() -> Array<ASAInternalEventCalendar> {
        let temp = self.userDefaults.array(forKey: INTERNAL_EVENT_CALENDARS_KEY)
        var tempArray:  Array<ASAInternalEventCalendar> = []
        
        if temp != nil {
            for dictionary in temp! {
                let eventCalendar = ASAInternalEventCalendar.newInternalEventCalendar(dictionary: dictionary as! Dictionary<String, Any>)
                if eventCalendar != nil {
                    tempArray.append(eventCalendar!)
                }
            } // for dictionary in temp!
        }
        
        return tempArray
    } // class func internalEventCalendarArray() -> Array<ASAInternalEventCalendar>
    
} // class ASAUserDate
