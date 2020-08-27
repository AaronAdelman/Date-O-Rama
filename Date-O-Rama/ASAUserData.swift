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

//let storageKey = "group.com.adelsoft.DoubleDate"
let INTERNAL_EVENT_CALENDARS_KEY = "INTERNAL_EVENT_CALENDARS"

final class ASAUserData:  NSObject, ObservableObject, NSFilePresenter {
//    var description: String

//    static let userDefaults = UserDefaults.init(suiteName: storageKey)!
    
    private static var sharedUserData: ASAUserData = {
        let userData = ASAUserData()
        
        return userData
    }()
    
    class func shared() -> ASAUserData {
        return sharedUserData
    } // class func shared() -> ASAUserData
    
    @Published var mainRows:  Array<ASARow> = []
    @Published var internalEventCalendars:  Array<ASAInternalEventCalendar> = []
    
    @Published var threeLineLargeRows:  Array<ASARow> = []
    @Published var twoLineSmallRows:    Array<ASARow> = []
    @Published var twoLineLargeRows:    Array<ASARow> = []
    @Published var oneLineLargeRows:    Array<ASARow> = []
    @Published var oneLineSmallRows:    Array<ASARow> = []

    var containerURL:  URL?

    class func ubiquityContainerURL() -> URL? {
        let result: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        debugPrint(#file, #function, result as Any)
        return result
    }

    private class func checkForContainerExistence() -> URL? {
        // check for container existence
        if let url = ubiquityContainerURL() {
            let needToCreateContainer = !FileManager.default.fileExists(atPath: url.path)
            debugPrint(#file, #function, "Need to create container:", needToCreateContainer)
            if needToCreateContainer {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    debugPrint(#file, #function, "Container created")
                } catch {
                    debugPrint(#file, #function, error.localizedDescription)
                }
            }

            let documentsPath = url.path + "/Documents"
            let needToCreateDocuments = !FileManager.default.fileExists(atPath: documentsPath)
            debugPrint(#file, #function, "Need to create documents:", needToCreateDocuments)
            if needToCreateDocuments {
                do {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: documentsPath), withIntermediateDirectories: true, attributes: nil)
                    debugPrint(#file, #function, "Documents created")
                }  catch {
                    debugPrint(#file, #function, error.localizedDescription)
                }
            }

            let subpaths = FileManager.default.subpaths(atPath: url.path)
            debugPrint(#file, #function, "Subpaths:", subpaths as Any)

            return url
        } else {
            debugPrint(#file, #function, "Something else happened")
        }

        return nil
    } // func checkForContainerExistence()

    fileprivate func preferencesFilePath() -> String? {
        if self.containerURL == nil {
            return nil
        }

        let containerURLContents = FileManager.default.contents(atPath: self.containerURL!.path)
        debugPrint(#file, #function, "Container contents:", containerURLContents as Any)
        let documentsPath = self.containerURL!.path + "/Documents"
        let documentsContents = FileManager.default.contents(atPath: documentsPath)
        debugPrint(#file, #function, "Documents contents:", documentsContents as Any)

        let possibility1Path = self.containerURL!.path + "/Documents/Preferences.json"
        do {
        try FileManager.default.startDownloadingUbiquitousItem(at: URL(fileURLWithPath: possibility1Path))
        } catch {
            debugPrint(#file, #function, "startDownloadingUbiquitousItem error:", error)
        }
        let exists1 = FileManager.default.fileExists(atPath: possibility1Path)
        if exists1 {
            return possibility1Path
        }

//        let possibility2Path = self.containerURL!.path + "/Documents/.Preferences.json.icloud"
//        let exists2 = FileManager.default.fileExists(atPath: possibility2Path)
//        if exists2 {
//            return possibility2Path
//        }

        return possibility1Path
    }

    private func preferenceFileExists() -> Bool {
        if self.containerURL == nil {
            return false
        }

        let containerURLContents = FileManager.default.contents(atPath: self.containerURL!.path)
        debugPrint(#file, #function, "Container contents:", containerURLContents as Any)
        let documentsPath = self.containerURL!.path + "/Documents"
        let documentsContents = FileManager.default.contents(atPath: documentsPath)
        debugPrint(#file, #function, "Documents contents:", documentsContents as Any)


        let path = self.preferencesFilePath()
        if path == nil {
            return false
        }
        let result = FileManager.default.fileExists(atPath: path!)
        return result
    } // func preferenceFileExists() -> Bool
    
     func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
//        var rows = ASAUserData.rowArray(key: key)
////        self.internalEventCalendars = ASAUserData.internalEventCalendarArray()
//
//        while rows.count < key.minimumNumberOfRows() {
//            rows.append(ASARow.generic())
//        } // while rows.count < key.minimumNumberOfRows()
//
//        return rows

        switch key {
        case .app:
            return self.mainRows

        case .threeLineLarge:
            return self.threeLineLargeRows

        case .twoLineSmall:
            return self.twoLineSmallRows

        case .twoLineLarge:
            return self.twoLineLargeRows

        case .oneLineLarge:
            return self.oneLineLargeRows

        case .oneLineSmall:
            return self.oneLineSmallRows
        } // switch key
    } // func rowArray(key:  ASARowArrayKey) -> Array<ASARow>

    func emptyRowArray(key:  ASARowArrayKey) -> Array<ASARow> {
        var result:  Array<ASARow> = []
        for _ in 1...key.minimumNumberOfRows() {
            result.append(ASARow.generic())
        }
        return result
    } // func emptyRowArray(key:  ASARowArrayKey) -> Array<ASARow>

    fileprivate func loadPreferences() {
        if preferenceFileExists() {
            debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath()))” exists")
            let path = self.preferencesFilePath()
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
                debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                debugPrint(#file, #function, jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
                    //                    debugPrint(#file, #function, jsonResult)
                    self.mainRows = ASAUserData.rowArray(key: .app, dictionary: jsonResult)
                    self.threeLineLargeRows = ASAUserData.rowArray(key: .threeLineLarge, dictionary: jsonResult)
                    self.twoLineLargeRows = ASAUserData.rowArray(key: .twoLineLarge, dictionary: jsonResult)
                    self.twoLineSmallRows = ASAUserData.rowArray(key: .twoLineSmall, dictionary: jsonResult)
                    self.oneLineLargeRows = ASAUserData.rowArray(key: .oneLineLarge, dictionary: jsonResult)
                    self.oneLineSmallRows = ASAUserData.rowArray(key: .oneLineSmall, dictionary: jsonResult)

                    self.internalEventCalendars = ASAUserData.internalEventCalendarArray(dictionary: jsonResult)

                    return
                }
            } catch {
                // handle error
                debugPrint(#file, #function, error)
            }
        } else {
            debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath()))” does not exist")
        }

        mainRows               = self.emptyRowArray(key: .app)
        threeLineLargeRows     = self.emptyRowArray(key: .threeLineLarge)
        twoLineSmallRows       = self.emptyRowArray(key: .twoLineSmall)
        twoLineLargeRows       = self.emptyRowArray(key: .twoLineLarge)
        oneLineLargeRows       = self.emptyRowArray(key: .oneLineLarge)
        oneLineSmallRows       = self.emptyRowArray(key: .oneLineSmall)

        internalEventCalendars = []

        //        self.mainRows           = self.rowArray(key: .app)
        //        self.threeLineLargeRows = self.rowArray(key: .threeLineLarge)
        //        self.twoLineSmallRows   = self.rowArray(key: .twoLineSmall)
        //        self.twoLineLargeRows   = self.rowArray(key: .twoLineLarge)
        //        self.oneLineLargeRows   = self.rowArray(key: .oneLineLarge)
        //        self.oneLineSmallRows   = self.rowArray(key: .oneLineSmall)
        //
        //        self.internalEventCalendars = ASAUserData.internalEventCalendarArray()
    } // func loadPreferences()

    override init() {
        super.init()

        self.containerURL = ASAUserData.checkForContainerExistence()
        self.presentedItemURL = self.containerURL

        NSFileCoordinator.addFilePresenter(self)

        self.loadPreferences()
    } // init()

    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    public func savePreferences() {
//        self.saveRowArray(rowArray: self.mainRows, key: .app)
//        self.saveRowArray(rowArray: self.threeLineLargeRows, key: .threeLineLarge)
//        self.saveRowArray(rowArray: self.twoLineLargeRows, key: .twoLineLarge)
//        self.saveRowArray(rowArray: self.twoLineSmallRows, key: .twoLineSmall)
//        self.saveRowArray(rowArray: self.oneLineLargeRows, key: .oneLineLarge)
//        self.saveRowArray(rowArray: self.oneLineSmallRows, key: .oneLineSmall)
//
//        self.saveInternalEventCalendarArray(internalEventCalendarArray: self.internalEventCalendars)

        let processedMainRows = self.processedRowArray(rowArray: self.mainRows)
        let processedThreeLargeRows = self.processedRowArray(rowArray: self.threeLineLargeRows)
        let processedTwoLineLargeRows = self.processedRowArray(rowArray: self.twoLineLargeRows)
        let processedTwoLineSmallRows = self.processedRowArray(rowArray: self.twoLineSmallRows)
        let processedOneLineLargeRows = self.processedRowArray(rowArray: self.oneLineLargeRows)
        let processedOneLineSmallRows = self.processedRowArray(rowArray: self.oneLineSmallRows)

        let processedInternalEventCalendarArray = self.processedInternalEventCalendarArray(internalEventCalendarArray: self.internalEventCalendars)
        let temp: Dictionary<String, Any> = [
            ASARowArrayKey.app.rawValue:  processedMainRows,
            ASARowArrayKey.threeLineLarge.rawValue:  processedThreeLargeRows,
            ASARowArrayKey.twoLineLarge.rawValue:  processedTwoLineLargeRows,
            ASARowArrayKey.twoLineSmall.rawValue:  processedTwoLineSmallRows,
            ASARowArrayKey.oneLineLarge.rawValue:  processedOneLineLargeRows,
            ASARowArrayKey.oneLineSmall.rawValue:  processedOneLineSmallRows,
            INTERNAL_EVENT_CALENDARS_KEY:  processedInternalEventCalendarArray
        ]
        let data = (try? JSONSerialization.data(withJSONObject: temp, options: []))
//        debugPrint(#file, #function, String(data: data!, encoding: .utf8) as Any)
        if data != nil {
            do {
                let url: URL = URL(fileURLWithPath: self.preferencesFilePath()!)

                try data!.write(to: url, options: .atomic)

                debugPrint(#file, #function, "Preferences successfully saved")
            } catch {
                debugPrint(#file, #function, error)
            }
        } else {
            debugPrint(#file, #function, "Data is nil")
        }

    } // func savePreferences()
    
    
    // MARK: -

    private func processedRowArray(rowArray:  Array<ASARow>) ->  Array<Dictionary<String, Any>> {
        var temp:  Array<Dictionary<String, Any>> = []
        for row in rowArray {
            let dictionary = row.dictionary()
            temp.append(dictionary)
        }
        return temp
    } // func processedRowArray(rowArray:  Array<ASARow>) ->  Array<Dictionary<String, Any>>
    
//    private func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey) {
//        //        debugPrint(#file, #function, rowArray)
//        var temp:  Array<Dictionary<String, Any>> = []
//        for row in rowArray {
//            let dictionary = row.dictionary()
//            temp.append(dictionary)
//        }
//
//        ASAUserData.self.userDefaults.set(temp, forKey: key.rawValue)
//        ASAUserData.self.userDefaults.synchronize()
//    } // public func saveRowArray(rowArray:  Array<ASARow>, key:  ASARowArrayKey)
    
//    private class func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
//        //        debugPrint(#file, #function, key)
//
//        let temp = self.userDefaults.array(forKey: key.rawValue)
//        var tempArray:  Array<ASARow> = []
//
//        if temp != nil {
//            for dictionary in temp! {
//                let row = ASARow.newRow(dictionary: dictionary as! Dictionary<String, Any>)
//                tempArray.append(row)
//            } // for dictionary in temp!
//        }
//
//        let numberOfRows = tempArray.count
//        let minimumNumberOfRows = key.minimumNumberOfRows()
//        if numberOfRows < minimumNumberOfRows {
//
//            tempArray += Array.init(repeatElement(ASARow.generic(), count: minimumNumberOfRows - numberOfRows))
//        }
//
//        //        debugPrint(#file, #function, tempArray)
//        return tempArray
//    } // public func rowArray(key:  ASARowArrayKey) -> Array<ASARow>

    private class func rowArray(key:  ASARowArrayKey, dictionary:  Dictionary<String, Any>?) -> Array<ASARow> {
        //        debugPrint(#file, #function, key)

        if dictionary == nil {
            return []
        }

        let temp = dictionary![key.rawValue] as! Array<Dictionary<String, Any>>?
        var tempArray:  Array<ASARow> = []

        if temp != nil {
            for dictionary in temp! {
                let row = ASARow.newRow(dictionary: dictionary)
                tempArray.append(row)
            } // for dictionary in temp!
        } else {
            return []
        }

        let numberOfRows = tempArray.count
        let minimumNumberOfRows = key.minimumNumberOfRows()
        if numberOfRows < minimumNumberOfRows {

            tempArray += Array.init(repeatElement(ASARow.generic(), count: minimumNumberOfRows - numberOfRows))
        }

        //        debugPrint(#file, #function, tempArray)
        return tempArray
    } // class func rowArray(key:  ASARowArrayKey, dictionary:  Dictionary<String, Any>?) -> Array<ASARow>

    private class func internalEventCalendarArray(dictionary:  Dictionary<String, Any>?) -> Array<ASAInternalEventCalendar> {
        if dictionary == nil {
            return []
        }

//        let temp = self.userDefaults.array(forKey: INTERNAL_EVENT_CALENDARS_KEY)
        let temp = dictionary![INTERNAL_EVENT_CALENDARS_KEY] as! Array<Dictionary<String, Any>>?
        var tempArray:  Array<ASAInternalEventCalendar> = []

        if temp != nil {
            for dictionary in temp! {
                let eventCalendar = ASAInternalEventCalendar.newInternalEventCalendar(dictionary: dictionary)
                if eventCalendar != nil {
                    tempArray.append(eventCalendar!)
                }
            } // for dictionary in temp!
        }

        return tempArray
    } // class func internalEventCalendarArray(dictionary:  Dictionary<String, Any>?) -> Array<ASAInternalEventCalendar>

    private func processedInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>) -> Array<Dictionary<String, Any>> {
        var temp:  Array<Dictionary<String, Any>> = []
        for eventCalendar in self.internalEventCalendars {
            let dictionary = eventCalendar.dictionary()
            temp.append(dictionary)
        } //for eventCalendar in self.internalEventCalendars
        return temp
    } // func processedInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>) -> Array<Dictionary<String, Any>>
    
//    private func saveInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>) {
//        var temp:  Array<Dictionary<String, Any>> = []
//        for eventCalendar in self.internalEventCalendars {
//            let dictionary = eventCalendar.dictionary()
//            temp.append(dictionary)
//        } //for eventCalendar in self.internalEventCalendars
//
//        ASAUserData.self.userDefaults.set(temp, forKey: INTERNAL_EVENT_CALENDARS_KEY)
//        ASAUserData.self.userDefaults.synchronize()
//    } // func saveInternalEventCalendarArray(internalEventCalendarArray:  Array<ASAInternalEventCalendar>)
    
//    private class func internalEventCalendarArray() -> Array<ASAInternalEventCalendar> {
//        let temp = self.userDefaults.array(forKey: INTERNAL_EVENT_CALENDARS_KEY)
//        var tempArray:  Array<ASAInternalEventCalendar> = []
//
//        if temp != nil {
//            for dictionary in temp! {
//                let eventCalendar = ASAInternalEventCalendar.newInternalEventCalendar(dictionary: dictionary as! Dictionary<String, Any>)
//                if eventCalendar != nil {
//                    tempArray.append(eventCalendar!)
//                }
//            } // for dictionary in temp!
//        }
//
//        return tempArray
//    } // class func internalEventCalendarArray() -> Array<ASAInternalEventCalendar>


    // MARK: -

    var presentedItemURL: URL?

    var presentedItemOperationQueue: OperationQueue = OperationQueue.main

    func presentedSubitemDidChange(at url: URL) {
        debugPrint(#file, #function, url)
        self.loadPreferences()
    }

    func presentedItemDidChange() {
        debugPrint(#file, #function)
        self.loadPreferences()
    }

} // class ASAUserDate
