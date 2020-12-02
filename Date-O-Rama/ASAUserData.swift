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

enum ASAPreferencesFileCode {
    case clocks
    case events
    case complications

    var suffix:  String {
        get {
            switch self {
            case .clocks:
                return "/Documents/Clock Preferences.json"

            case .events:
                return "/Documents/Event Preferences.json"

            case .complications:
                return "/Documents/Complication Preferences.json"
            } // switch self
        } // get
    } // var suffix
} // enum ASAPreferencesFileCode


// MARK: -

fileprivate let INTERNAL_EVENT_CALENDARS_KEY  = "INTERNAL_EVENT_CALENDARS"
fileprivate let EXTERNAL_EVENT_CALENDARS_KEY  = "EXTERNAL_EVENT_CALENDARS"


final class ASAUserData:  NSObject, ObservableObject, NSFilePresenter {
    private static var sharedUserData: ASAUserData = {
        let userData = ASAUserData()
        
        return userData
    }()
    
    class func shared() -> ASAUserData {
        return sharedUserData
    } // class func shared() -> ASAUserData


    // MARK:  -
    
    @Published var mainRows:  Array<ASARow> = []

    @Published var internalEventCalendars:  Array<ASAInternalEventCalendar> = []
    @Published var externalEventCalendarIdentifiers:  Array<String> = [] {
        didSet {
            ASAExternalEventManager.shared.reloadExternalCalendars(calendarIdentifiers: externalEventCalendarIdentifiers)
        } // didSet
    }
    
    @Published var threeLineLargeRows:  Array<ASARow> = []
    @Published var twoLineSmallRows:    Array<ASARow> = []
    @Published var twoLineLargeRows:    Array<ASARow> = []
    @Published var oneLineLargeRows:    Array<ASARow> = []
    @Published var oneLineSmallRows:    Array<ASARow> = []

    var containerURL:  URL?


    // MARK:  -

    class func ubiquityContainerURL() -> URL? {
        let result: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)
//        debugPrint(#file, #function, result as Any)
        return result
    }

    private class func checkForContainerExistence() -> URL? {
        // check for container existence
        if let url = ubiquityContainerURL() {
            let needToCreateContainer = !FileManager.default.fileExists(atPath: url.path)
//            debugPrint(#file, #function, "Need to create container:", needToCreateContainer)
            if needToCreateContainer {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//                    debugPrint(#file, #function, "Container created")
                } catch {
                    debugPrint(#file, #function, error.localizedDescription)
                }
            }

            let documentsPath = url.path + "/Documents"
            let needToCreateDocuments = !FileManager.default.fileExists(atPath: documentsPath)
//            debugPrint(#file, #function, "Need to create documents:", needToCreateDocuments)
            if needToCreateDocuments {
                do {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: documentsPath), withIntermediateDirectories: true, attributes: nil)
//                    debugPrint(#file, #function, "Documents created")
                }  catch {
                    debugPrint(#file, #function, error.localizedDescription)
                }
            }

            return url
        } else {
//            debugPrint(#file, #function, "Something else happened")
        }

        return nil
    } // func checkForContainerExistence()

    fileprivate func preferencesFilePath(code:  ASAPreferencesFileCode) -> String? {
        if self.containerURL == nil {
            return nil
        }

        let possibilityPath = self.containerURL!.path + code.suffix
        do {
        try FileManager.default.startDownloadingUbiquitousItem(at: URL(fileURLWithPath: possibilityPath))
        } catch {
            debugPrint(#file, #function, "startDownloadingUbiquitousItem error:", error)
        }
        let exists = FileManager.default.fileExists(atPath: possibilityPath)
        if exists {
            return possibilityPath
        }

        return possibilityPath
    } // func func preferencesFilePath(code:  ASAPreferencesFileCode) -> String?

    private func preferenceFileExists(code:  ASAPreferencesFileCode) -> Bool {
        #if os(watchOS)
        let defaults = UserDefaults.standard
        return defaults.object(forKey: code.suffix) != nil
        #else
        if self.containerURL == nil {
            return false
        }

        let path = self.preferencesFilePath(code: code)
        if path == nil {
            return false
        }
        let result = FileManager.default.fileExists(atPath: path!)
        return result
        #endif
    } // func preferenceFileExists(code:  ASAPreferencesFileCode) -> Bool
    
     func rowArray(key:  ASARowArrayKey) -> Array<ASARow> {
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
        var genericSuccess = false
        var complicationsSuccess = false
        #if os(watchOS)
        let defaults = UserDefaults.standard
        #endif

        if preferenceFileExists(code: .clocks) {
            let path = self.preferencesFilePath(code: .clocks)
            
            debugPrint(#file, #function, "Preference file “\(String(describing: path))” exists")
            do {
                #if os(watchOS)
                let data = defaults.object(forKey:  ASAPreferencesFileCode.clocks.suffix) as! Data
                #else
                let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
                #endif
//                debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
//                debugPrint(#file, #function, jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
//                    debugPrint(#file, #function, jsonResult)
                    self.mainRows = ASAUserData.rowArray(key: .app, dictionary: jsonResult)
                    
                    genericSuccess = true
                }
            } catch {
                // handle error
                debugPrint(#file, #function, error)
            }
        } else {
            debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath(code: .clocks)))” does not exist")
        }
        
        if preferenceFileExists(code: .events) {
            let path = self.preferencesFilePath(code: .events)
            debugPrint(#file, #function, "Preference file “\(String(describing: path))” exists")
            do {
                #if os(watchOS)
                let data = defaults.object(forKey:  ASAPreferencesFileCode.events.suffix) as! Data
                #else
                let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
                #endif
//                debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
//                debugPrint(#file, #function, jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
//                    debugPrint(#file, #function, jsonResult)
                    //                    self.mainRows = ASAUserData.rowArray(key: .app, dictionary: jsonResult)
                    self.internalEventCalendars = ASAUserData.internalEventCalendarArray(dictionary: jsonResult)
                    self.externalEventCalendarIdentifiers = jsonResult[EXTERNAL_EVENT_CALENDARS_KEY] as! Array<String>
                    
                    genericSuccess = true
                }
            } catch {
                // handle error
                debugPrint(#file, #function, error)
            }
        } else {
            debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath(code: .events)))” does not exist")
        }
        
        if #available(iOS 13.0, watchOS 6.0, *) {
            if preferenceFileExists(code: .complications) {
                let path = self.preferencesFilePath(code: .complications)
                debugPrint(#file, #function, "Preference file “\(String(describing: path))” exists")
                do {
                    #if os(watchOS)
                    let data = defaults.object(forKey:  ASAPreferencesFileCode.complications.suffix) as! Data
                    #else
                    let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
                    #endif
//                    debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
//                    debugPrint(#file, #function, jsonResult)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        // do stuff
//                        debugPrint(#file, #function, jsonResult)
                        self.threeLineLargeRows = ASAUserData.rowArray(key: .threeLineLarge, dictionary: jsonResult)
                        self.twoLineLargeRows = ASAUserData.rowArray(key: .twoLineLarge, dictionary: jsonResult)
                        self.twoLineSmallRows = ASAUserData.rowArray(key: .twoLineSmall, dictionary: jsonResult)
                        self.oneLineLargeRows = ASAUserData.rowArray(key: .oneLineLarge, dictionary: jsonResult)
                        self.oneLineSmallRows = ASAUserData.rowArray(key: .oneLineSmall, dictionary: jsonResult)
                        complicationsSuccess = true
                    }
                } catch {
                    // handle error
                    debugPrint(#file, #function, error)
                }
            } else {
                debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath(code: .clocks)))” does not exist")
            }
        }
        
        if !genericSuccess {
            mainRows               = self.emptyRowArray(key: .app)
            internalEventCalendars = []
        }
        
        if #available(iOS 13.0, watchOS 6.0, *) {
            if !complicationsSuccess {
                threeLineLargeRows     = self.emptyRowArray(key: .threeLineLarge)
                twoLineSmallRows       = self.emptyRowArray(key: .twoLineSmall)
                twoLineLargeRows       = self.emptyRowArray(key: .twoLineLarge)
                oneLineLargeRows       = self.emptyRowArray(key: .oneLineLarge)
                oneLineSmallRows       = self.emptyRowArray(key: .oneLineSmall)
            }
        }
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
    } // deinit
    
    fileprivate func writePreferences(_ dictionary: [String : Any], code:  ASAPreferencesFileCode) {
        let data = (try? JSONSerialization.data(withJSONObject: dictionary, options: []))
        //        debugPrint(#file, #function, String(data: data!, encoding: .utf8) as Any)
        if data != nil {
                #if os(watchOS)
                let defaults = UserDefaults.standard
                defaults.setValue(data, forKey: code.suffix)
                #else
                do {
                let preferencesFilePath: String? = self.preferencesFilePath(code: code)
                if preferencesFilePath != nil {
                    let url: URL = URL(fileURLWithPath: preferencesFilePath!)

                    try data!.write(to: url, options: .atomic)

                    // debugPrint(#file, #function, "Preferences successfully saved")
                } else {
                    debugPrint(#file, #function, "Preferences file path is nil!")
                }
            } catch {
                debugPrint(#file, #function, error)
            }
                #endif
        } else {
            debugPrint(#file, #function, "Data is nil")
        }
    } // func writePreferences(_ dictionary: [String : Any], code:  ASAPreferencesFileCode)

    public func savePreferences(code:  ASAPreferencesFileCode) {
        if code == .clocks {
            let processedMainRows = self.processedRowArray(rowArray: self.mainRows)

            let temp1a: Dictionary<String, Any> = [
                ASARowArrayKey.app.rawValue:  processedMainRows
//                ,
//                MAIN_ROWS_GROUPING_OPTION_KEY:  self.mainRowsGroupingOption.rawValue
            ]

            writePreferences(temp1a, code: .clocks)
        }

        if code == .events {
            let processedInternalEventCalendarArray = self.processedInternalEventCalendarArray(internalEventCalendarArray: self.internalEventCalendars)

            let temp1b: Dictionary<String, Any> = [
                INTERNAL_EVENT_CALENDARS_KEY:  processedInternalEventCalendarArray,
                EXTERNAL_EVENT_CALENDARS_KEY:  ASAExternalEventManager.shared.calendarIdentifiers
            ]

            writePreferences(temp1b, code: .events)
        }

        if code == .complications {
            if #available(iOS 13.0, watchOS 6.0, *) {
                let processedThreeLargeRows = self.processedRowArray(rowArray: self.threeLineLargeRows)
                let processedTwoLineLargeRows = self.processedRowArray(rowArray: self.twoLineLargeRows)
                let processedTwoLineSmallRows = self.processedRowArray(rowArray: self.twoLineSmallRows)
                let processedOneLineLargeRows = self.processedRowArray(rowArray: self.oneLineLargeRows)
                let processedOneLineSmallRows = self.processedRowArray(rowArray: self.oneLineSmallRows)

                let temp2: Dictionary<String, Any> = [
                    ASARowArrayKey.threeLineLarge.rawValue:  processedThreeLargeRows,
                    ASARowArrayKey.twoLineLarge.rawValue:  processedTwoLineLargeRows,
                    ASARowArrayKey.twoLineSmall.rawValue:  processedTwoLineSmallRows,
                    ASARowArrayKey.oneLineLarge.rawValue:  processedOneLineLargeRows,
                    ASARowArrayKey.oneLineSmall.rawValue:  processedOneLineSmallRows
                ]

                writePreferences(temp2, code: .complications)
            }
        }

        #if os(iOS)
        #if targetEnvironment(macCatalyst)
        
        #else
        let app = UIApplication.shared
            let appDelegate = app.delegate as! AppDelegate
            appDelegate.sendUserData(appDelegate.session)
        #endif
        #endif
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

    public func setRowArray(rowArray: Array<ASARow>, key: ASARowArrayKey) {
        switch key {
        case .app:
            self.mainRows = rowArray

        case .threeLineLarge:
            self.threeLineLargeRows = rowArray

        case .twoLineSmall:
            self.twoLineSmallRows = rowArray

        case .twoLineLarge:
            self.twoLineLargeRows = rowArray

        case .oneLineLarge:
            self.oneLineLargeRows = rowArray

        case .oneLineSmall:
            self.oneLineSmallRows = rowArray
        } // switch key
    } // func setRowArray(rowArray: Array<ASARow>, key: ASARowArrayKey)

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


    // MARK: - NSFilePresenter

    var presentedItemURL: URL?

    var presentedItemOperationQueue: OperationQueue = OperationQueue.main

    func presentedSubitemDidChange(at url: URL) {
//        debugPrint(#file, #function, url)
        self.loadPreferences()
    } // func presentedSubitemDidChange(at url: URL)

    func presentedItemDidChange() {
//        debugPrint(#file, #function)
        self.loadPreferences()
    } // func presentedItemDidChange()
} // class ASAUserDate
