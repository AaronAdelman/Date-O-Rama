//
//  ASAModel.swift
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
#if os(watchOS)
import ClockKit
#endif
import WatchConnectivity


// MARK: -


final class ASAModel:  NSObject, ObservableObject, NSFilePresenter, Sendable {
    fileprivate let TIMESTAMP_KEY = "timestamp"

    enum PreferencesFileCode {
        case clocks
        case complications
        
        var suffix:  String {
            get {
                switch self {
                case .clocks:
                    return "/Documents/Clock Preferences.json"
                    
                case .complications:
                    return "/Documents/Complication Preferences.json"
                } // switch self
            } // get
        } // var suffix
    } // enum PreferencesFileCode

    
    @MainActor static let shared = ASAModel()
    static let locationManager   = ASALocationManager.shared
    
    
    // MARK:  - Model objects
    
    @Published var mainClocks:  Array<ASALocationWithClocks> = [ASALocationWithClocks(location: locationManager.deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true, locationManager: ASAModel.locationManager)]
    
    private func reloadComplicationTimelines() {
#if os(watchOS)
        // Update any complications on active watch faces.
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
#endif
    }
    
    @Published var threeLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: true, locationManager: ASAModel.locationManager) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var twoLineSmallClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: true, locationManager: ASAModel.locationManager) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var twoLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: true, locationManager: ASAModel.locationManager) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var oneLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: true, locationManager: ASAModel.locationManager) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var oneLineSmallClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: true, locationManager: ASAModel.locationManager) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    
    var clocksTimestamp: Date        = .distantPast
    var complicationsTimestamp: Date = .distantPast
    
    // MARK:  -
    
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
                    debugPrint(#file, #function, "Container created")
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
                    debugPrint(#file, #function, "Documents created")
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
    
    fileprivate func preferencesFilePath(code:  PreferencesFileCode) -> String? {
        if self.containerURL == nil {
            return nil
        }
        
        let possibilityPath = self.containerURL!.path + code.suffix
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: URL(fileURLWithPath: possibilityPath))
        } catch {
            debugPrint(#file, #function, "startDownloadingUbiquitousItem error:", error)
            return nil
        }
        let exists = FileManager.default.fileExists(atPath: possibilityPath)
        if exists {
            return possibilityPath
        }
        
        return possibilityPath
    } // func func preferencesFilePath(code:  PreferencesFileCode) -> String?
    
    private func preferenceFileExists(code:  PreferencesFileCode) -> Bool {
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
    } // func preferenceFileExists(code:  PreferencesFileCode) -> Bool
    
    func locationsWithClocksArray(key: ASAClockArrayKey) -> Array<ASALocationWithClocks> {
        switch key {
        case .app:
            return self.mainClocks
            
        case .threeLineLarge:
            return [self.threeLineLargeClocks]
            
        case .twoLineSmall:
            return [self.twoLineSmallClocks]
            
        case .twoLineLarge:
            return [self.twoLineLargeClocks]
            
        case .oneLineLarge:
            return [self.oneLineLargeClocks]
            
        case .oneLineSmall:
            return [self.oneLineSmallClocks]
        } // switch key
    } // func locationsWithClocksArray(key:  ASAClockArrayKey) -> Array<ASALocationWithClocks>
    
    func defaultLocationWithClocks(key:  ASAClockArrayKey) -> ASALocationWithClocks {
        let deviceLocation = ASAModel.locationManager.deviceLocation
        
        switch key {
        case .app:
            return ASALocationWithClocks(location: deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
            
        case .threeLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .full),
                ASAClock.generic(calendarCode: .HebrewGRA, dateFormat: .full),
                ASAClock.generic(calendarCode: .IslamicSolar, dateFormat: .full)
            ], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
            
        case .twoLineSmall:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .abbreviatedWeekday),
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .dayOfMonth)
            ], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
            
        case .twoLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .abbreviatedWeekdayWithDayOfMonth),
                ASAClock.generic(calendarCode: .HebrewGRA, dateFormat:  .abbreviatedWeekdayWithDayOfMonth)
            ], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
            
        case .oneLineSmall:
            return ASALocationWithClocks(location: deviceLocation, clocks: [                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .abbreviatedWeekdayWithDayOfMonth)
                                                                           ], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
            
        case .oneLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .mediumWithWeekday)
                                                                           ], usesDeviceLocation: true, locationManager: ASAModel.locationManager)
        } // switch key
    } // func defaultLocationWithClocks(key:  ASAClockArrayKey) -> ASALocationWithClocks
    
    fileprivate func loadPreferences() {
        var genericSuccess = false
        var complicationsSuccess = false
#if os(watchOS)
        let defaults = UserDefaults.standard
#endif
        
        if preferenceFileExists(code: .clocks) {
            let path = self.preferencesFilePath(code: .clocks)
            
            //            debugPrint(#file, #function, "Preference file “\(String(describing: path))” exists")
            do {
#if os(watchOS)
                let data = defaults.object(forKey:  PreferencesFileCode.clocks.suffix) as! Data
#else
                let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
#endif
                //                debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
                //                debugPrint(#file, #function, jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
                    //                    debugPrint(#file, #function, jsonResult)
                    
                    let timestamp: Date? = Date.date(timeIntervalSince1970: jsonResult[TIMESTAMP_KEY] as? TimeInterval)
                    if timestamp == nil || timestamp! > self.clocksTimestamp {
                        self.mainClocks = ASAModel.locationsWithClocksArray(key: .app, dictionary: jsonResult)
                    }
                    
                    genericSuccess = true
                }
            } catch {
                // handle error
                debugPrint(#file, #function, error)
            }
        } else {
            //            debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath(code: .clocks)))” does not exist")
        }
        
        if #available(iOS 13.0, watchOS 6.0, *) {
            if preferenceFileExists(code: .complications) {
                let path = self.preferencesFilePath(code: .complications)
                //                debugPrint(#file, #function, "Preference file “\(String(describing: path))” exists")
                do {
#if os(watchOS)
                    let data = defaults.object(forKey:  PreferencesFileCode.complications.suffix) as! Data
#else
                    let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
#endif
                    //                    debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
                    //                    debugPrint(#file, #function, jsonResult)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        // do stuff
                        //                        debugPrint(#file, #function, jsonResult)
                        let timestamp: Date? = Date.date(timeIntervalSince1970: jsonResult[TIMESTAMP_KEY] as? TimeInterval)
                        if timestamp == nil || timestamp! > self.complicationsTimestamp {
                            self.threeLineLargeClocks = ASAModel.locationsWithClocksArray(key: .threeLineLarge, dictionary: jsonResult)[0]
                            self.twoLineLargeClocks = ASAModel.locationsWithClocksArray(key: .twoLineLarge, dictionary: jsonResult)[0]
                            self.twoLineSmallClocks = ASAModel.locationsWithClocksArray(key: .twoLineSmall, dictionary: jsonResult)[0]
                            self.oneLineLargeClocks = ASAModel.locationsWithClocksArray(key: .oneLineLarge, dictionary: jsonResult)[0]
                            self.oneLineSmallClocks = ASAModel.locationsWithClocksArray(key: .oneLineSmall, dictionary: jsonResult)[0]
                        }
                        complicationsSuccess = true
                    }
                } catch {
                    // handle error
                    debugPrint(#file, #function, error)
                }
            } else {
                //                debugPrint(#file, #function, "Preference file “\(String(describing: self.preferencesFilePath(code: .complications)))” does not exist")
            }
        }
        
        if !genericSuccess {
            mainClocks               = [self.defaultLocationWithClocks(key: .app)]
        }
        
        if #available(iOS 13.0, watchOS 6.0, *) {
            if !complicationsSuccess {
                threeLineLargeClocks = self.defaultLocationWithClocks(key: .threeLineLarge)
                twoLineSmallClocks   = self.defaultLocationWithClocks(key: .twoLineSmall)
                twoLineLargeClocks   = self.defaultLocationWithClocks(key: .twoLineLarge)
                oneLineLargeClocks   = self.defaultLocationWithClocks(key: .oneLineLarge)
                oneLineSmallClocks   = self.defaultLocationWithClocks(key: .oneLineSmall)
            }
        }
    } // func loadPreferences()
    
    override init() {
        self.containerURL = ASAModel.checkForContainerExistence()
        self.presentedItemURL = self.containerURL

        super.init()
        self.loadPreferences()
        NSFileCoordinator.addFilePresenter(self)
    } // init()
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    } // deinit
    
    fileprivate func writePreferences(_ dictionary: [String : Any], code:  PreferencesFileCode) {
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
                    //                    debugPrint(#file, #function, "Preferences file path is nil!")
                }
            } catch {
                debugPrint(#file, #function, error)
            }
#endif
        } else {
            //            debugPrint(#file, #function, "Data is nil")
        }
    } // func writePreferences(_ dictionary: [String : Any], code:  PreferencesFileCode)
    
    @MainActor public func savePreferences(code:  PreferencesFileCode) {
        self.objectWillChange.send()
        
        if code == .clocks {
            let processedMainClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: self.mainClocks, forComplication: false)
            
            let timestamp: Date = Date()
            let temp1a: Dictionary<String, Any> = [
                TIMESTAMP_KEY: timestamp.timeIntervalSince1970,
                ASAClockArrayKey.app.rawValue:  processedMainClocks
            ]
            
            self.clocksTimestamp = timestamp
            writePreferences(temp1a, code: .clocks)
        } else if code == .complications {
            let processedThreeLineLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.threeLineLargeClocks], forComplication: true)
            let processedTwoLineLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.twoLineLargeClocks], forComplication: true)
            let processedTwoLineSmallClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.twoLineSmallClocks], forComplication: true)
            let processedOneLineLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.oneLineLargeClocks], forComplication: true)
            let processedOneLineSmallClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.oneLineSmallClocks], forComplication: true)
            
            let timestamp: Date = Date()
            let temp2: Dictionary<String, Any> = [
                TIMESTAMP_KEY: timestamp.timeIntervalSince1970,
                ASAClockArrayKey.threeLineLarge.rawValue:  processedThreeLineLargeClocks,
                ASAClockArrayKey.twoLineLarge.rawValue:  processedTwoLineLargeClocks,
                ASAClockArrayKey.twoLineSmall.rawValue:  processedTwoLineSmallClocks,
                ASAClockArrayKey.oneLineLarge.rawValue:  processedOneLineLargeClocks,
                ASAClockArrayKey.oneLineSmall.rawValue:  processedOneLineSmallClocks
            ]
            
            self.complicationsTimestamp = timestamp
            writePreferences(temp2, code: .complications)
        }
        
#if os(iOS)
        if WCSession.isSupported() {
            let appDelegate: AppDelegate = AppDelegate.shared
            appDelegate.sendUserData(appDelegate.session)
        }
#endif
    } // func savePreferences()
    
    
    // MARK: - Translation between JSON and model objects
    
    private func locationsWithClocksArrayAsJSON(locationsWithClocksArray:  Array<ASALocationWithClocks>, forComplication:  Bool) ->  Array<Dictionary<String, Any>> {
        var temp:  Array<Dictionary<String, Any>> = []
        for locationWithClocks in locationsWithClocksArray {
            for clock in locationWithClocks.clocks {
                let dictionary = clock.dictionary(forComplication: forComplication, location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation)
                temp.append(dictionary)
            } // for clock in locationWithClocks.clocks
        } // for locationWithClocks in locationsWithClocksArray
        return temp
    } // private func processedClocksArray(clocksArray:  Array<ASALocationWithClocks>, forComplication:  Bool) ->  Array<Dictionary<String, Any>>
    
    public func setLocationsWithClocksArray(locationsWithClocksArray: Array<ASALocationWithClocks>, key: ASAClockArrayKey) {
        switch key {
        case .app:
            self.mainClocks = locationsWithClocksArray
            
        case .threeLineLarge:
            self.threeLineLargeClocks = locationsWithClocksArray[0]
            
        case .twoLineSmall:
            self.twoLineSmallClocks = locationsWithClocksArray[0]
            
        case .twoLineLarge:
            self.twoLineLargeClocks = locationsWithClocksArray[0]
            
        case .oneLineLarge:
            self.oneLineLargeClocks = locationsWithClocksArray[0]
            
        case .oneLineSmall:
            self.oneLineSmallClocks = locationsWithClocksArray[0]
        } // switch key
    } // func setLocationsWithClocksArray(locationsWithClocksArray: Array<ASALocationWithClocks>, key: ASAClockArrayKey)
    
    public static func arrayOfDictionariesToArrayOfLocationsWithClocks(array: [[String : Any]]?, key: ASAClockArrayKey) -> [ASALocationWithClocks] {
        var tempArray:  Array<ASALocationWithClocks> = []
        
        if array != nil {
            for dictionary in array! {
                let (clock, location, usesDeviceLocation) = ASAClock.new(dictionary: dictionary)
                let index = tempArray.firstIndex(where: {
                    if $0.usesDeviceLocation && usesDeviceLocation {
                        return true
                    }
                    
                    return $0.location == location && $0.usesDeviceLocation == usesDeviceLocation
                })
                if index == nil {
                    tempArray.append(ASALocationWithClocks(location: location, clocks: [clock], usesDeviceLocation: usesDeviceLocation, locationManager: ASAModel.locationManager))
                } else {
                    tempArray[index!].clocks.append(clock)
                }
            } // for dictionary in temp!
        } else {
            return []
        }
        if key == .app {
            return tempArray
        }
        
        let numberOfClocks = tempArray[0].clocks.count
        let minimumNumberOfClocks = key.minimumNumberOfClocks
        if numberOfClocks < minimumNumberOfClocks {
            while tempArray[0].clocks.count < minimumNumberOfClocks {
                tempArray[0].clocks.append(ASAClock.generic)
            }
        }
        
        //        debugPrint(#file, #function, tempArray)
        return tempArray
    } // public static func arrayOfDictionariesToArrayOfLocationsWithClocks(array: [[String : Any]]?, key: ASAClockArrayKey) -> [ASALocationWithClocks]
    
    private class func locationsWithClocksArray(key:  ASAClockArrayKey, dictionary:  Dictionary<String, Any>?) -> Array<ASALocationWithClocks> {
        //        debugPrint(#file, #function, key)
        
        if dictionary == nil {
            return []
        }
        
        let temp = dictionary![key.rawValue] as! Array<Dictionary<String, Any>>?
        return arrayOfDictionariesToArrayOfLocationsWithClocks(array: temp, key: key)
    } // private class func clockArray(key:  ASAClockArrayKey, dictionary:  Dictionary<String, Any>?) -> Array<ASALocationWithClocks>
    
    
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
    
    @Published var selectedTabIndex: Int = 0
} // class ASAModel


// MARK:  -

extension ASAModel {
    @MainActor func removeMainClock(uuid: UUID) {
        for i in 0..<self.mainClocks.count {
            let index = self.mainClocks[i].clocks.firstIndex(where: {$0.uuid == uuid})
            if index != nil {
                self.mainClocks[i].clocks.remove(at: index!)
                self.savePreferences(code: .clocks)
                return
            }
        } // for i in 0..<self.mainClocks.count
    } // func removeMainClock(uuid: UUID)
    
    @MainActor func addLocationWithClocks(_ newLocationWithClocks: ASALocationWithClocks) {
        self.mainClocks.insert(newLocationWithClocks, at: 0)
        self.savePreferences(code: .clocks)
    } //func addLocationWithClocks(_ newLocationWithClocks: ASALocationWithClocks)
    
    @MainActor func addMainClock(clock: ASAClock, location: ASALocation) {
        for i in 0..<self.mainClocks.count {
            if self.mainClocks[i].location == location {
                self.mainClocks[i].clocks.insert(clock, at: 0)
                self.savePreferences(code: .clocks)
                return
            }
        } // for i in 0..<self.mainClocks.count
        
        let newLocationWithClocks = ASALocationWithClocks(location: location, clocks: [clock], usesDeviceLocation: false, locationManager: ASAModel.locationManager)
        addLocationWithClocks(newLocationWithClocks)
    } // func addMainClock(clock: ASAClock, location: ASALocation)
    
    @MainActor func removeLocationWithClocks(_ locationWithClocks: ASALocationWithClocks) {
        let index = self.mainClocks.firstIndex(of: locationWithClocks)
        if index != nil {
            self.mainClocks.remove(at: index!)
            self.savePreferences(code: .clocks)
        }
    } // func removeLocationWithClocks(_ locationWithClocks: ASALocationWithClocks)
    
    func locationsWithClocksArrayDictionary(key:  ASAClockArrayKey, forComplication:  Bool) -> Array<Dictionary<String, Any>> {
        let locationsWithClocksArray: Array<ASALocationWithClocks> = self.locationsWithClocksArray(key: key)
        
        var temp:  Array<Dictionary<String, Any>> = []
        for locationWithClocks in locationsWithClocksArray {
            for clock in locationWithClocks.clocks {
                let dictionary = clock.dictionary(forComplication: forComplication, location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation)
                temp.append(dictionary)
            }
        }
        
        return temp
    } // func locationsWithClocksArrayDictionary(key:  ASAClockArrayKey, forComplication:  Bool) -> Array<Dictionary<String, Any>>
} // extension ASAModel
