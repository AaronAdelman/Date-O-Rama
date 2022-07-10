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
#if os(watchOS)
import ClockKit
#endif

enum ASAPreferencesFileCode {
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
} // enum ASAPreferencesFileCode


// MARK: -


final class ASAUserData:  NSObject, ObservableObject, NSFilePresenter {
    static let shared = ASAUserData()
    
    
    // MARK:  - Model objects
    
    @Published var mainClocks:  Array<ASALocationWithClocks> = [ASALocationWithClocks(location: ASALocationManager.shared.deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true)]
    
    private func reloadComplicationTimelines() {
#if os(watchOS)
        // Update any complications on active watch faces.
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
#endif
    }
    
    @Published var threeLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: false) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var twoLineSmallClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: false) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var twoLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: false) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var oneLineLargeClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: false) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    @Published var oneLineSmallClocks: ASALocationWithClocks = ASALocationWithClocks(location: .NullIsland, clocks: [], usesDeviceLocation: false) {
        didSet {
            self.reloadComplicationTimelines()
        } // didSet
    }
    
    
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
    
    fileprivate func preferencesFilePath(code:  ASAPreferencesFileCode) -> String? {
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
    
    func locationsWithClocksArray(key:  ASAClockArrayKey) -> Array<ASALocationWithClocks> {
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
        let deviceLocation = ASALocationManager.shared.deviceLocation
        
        switch key {
        case .app:
            return ASALocationWithClocks(location: deviceLocation, clocks: [ASAClock.generic], usesDeviceLocation: true)
            
        case .threeLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .full),
                ASAClock.generic(calendarCode: .HebrewGRA, dateFormat: .full),
                ASAClock.generic(calendarCode: .IslamicSolar, dateFormat: .full)
            ], usesDeviceLocation: true)
            
        case .twoLineSmall:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .abbreviatedWeekday),
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .dayOfMonth)
            ], usesDeviceLocation: true)
            
        case .twoLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [
                ASAClock.generic(calendarCode: .Gregorian, dateFormat:  .abbreviatedWeekdayWithDayOfMonth),
                ASAClock.generic(calendarCode: .HebrewGRA, dateFormat:  .abbreviatedWeekdayWithDayOfMonth)
            ], usesDeviceLocation: true)
            
        case .oneLineSmall:
            return ASALocationWithClocks(location: deviceLocation, clocks: [                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .abbreviatedWeekdayWithDayOfMonth)
            ], usesDeviceLocation: true)
            
        case .oneLineLarge:
            return ASALocationWithClocks(location: deviceLocation, clocks: [                ASAClock.generic(calendarCode: .Gregorian, dateFormat: .mediumWithWeekday)
            ], usesDeviceLocation: true)
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
                let data = defaults.object(forKey:  ASAPreferencesFileCode.clocks.suffix) as! Data
#else
                let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
#endif
                //                debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
                //                debugPrint(#file, #function, jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
                    //                    debugPrint(#file, #function, jsonResult)
                    self.mainClocks = ASAUserData.locationsWithClocksArray(key: .app, dictionary: jsonResult)
                    
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
                    let data = defaults.object(forKey:  ASAPreferencesFileCode.complications.suffix) as! Data
#else
                    let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: [])
#endif
                    //                    debugPrint(#file, #function, data, String(bytes: data, encoding: .utf8) as Any)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
                    //                    debugPrint(#file, #function, jsonResult)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        // do stuff
                        //                        debugPrint(#file, #function, jsonResult)
                        self.threeLineLargeClocks = ASAUserData.locationsWithClocksArray(key: .threeLineLarge, dictionary: jsonResult)[0]
                        self.twoLineLargeClocks = ASAUserData.locationsWithClocksArray(key: .twoLineLarge, dictionary: jsonResult)[0]
                        self.twoLineSmallClocks = ASAUserData.locationsWithClocksArray(key: .twoLineSmall, dictionary: jsonResult)[0]
                        self.oneLineLargeClocks = ASAUserData.locationsWithClocksArray(key: .oneLineLarge, dictionary: jsonResult)[0]
                        self.oneLineSmallClocks = ASAUserData.locationsWithClocksArray(key: .oneLineSmall, dictionary: jsonResult)[0]
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
                    //                    debugPrint(#file, #function, "Preferences file path is nil!")
                }
            } catch {
                debugPrint(#file, #function, error)
            }
#endif
        } else {
            //            debugPrint(#file, #function, "Data is nil")
        }
    } // func writePreferences(_ dictionary: [String : Any], code:  ASAPreferencesFileCode)
    
    public func savePreferences(code:  ASAPreferencesFileCode) {
        self.objectWillChange.send()
        
        if code == .clocks {
            let processedMainClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: self.mainClocks, forComplication: false)
            
            let temp1a: Dictionary<String, Any> = [
                ASAClockArrayKey.app.rawValue:  processedMainClocks
            ]
            
            writePreferences(temp1a, code: .clocks)
        }
        
        if code == .complications {
            let processedThreeLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.threeLineLargeClocks], forComplication: true)
            let processedTwoLineLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.twoLineLargeClocks], forComplication: true)
            let processedTwoLineSmallClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.twoLineSmallClocks], forComplication: true)
            let processedOneLineLargeClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.oneLineLargeClocks], forComplication: true)
            let processedOneLineSmallClocks = self.locationsWithClocksArrayAsJSON(locationsWithClocksArray: [self.oneLineSmallClocks], forComplication: true)
            
            let temp2: Dictionary<String, Any> = [
                ASAClockArrayKey.threeLineLarge.rawValue:  processedThreeLargeClocks,
                ASAClockArrayKey.twoLineLarge.rawValue:  processedTwoLineLargeClocks,
                ASAClockArrayKey.twoLineSmall.rawValue:  processedTwoLineSmallClocks,
                ASAClockArrayKey.oneLineLarge.rawValue:  processedOneLineLargeClocks,
                ASAClockArrayKey.oneLineSmall.rawValue:  processedOneLineSmallClocks
            ]
            
            writePreferences(temp2, code: .complications)
        }
        
#if os(iOS)
#if targetEnvironment(macCatalyst)
        
#else
        let appDelegate: AppDelegate = AppDelegate.shared
        appDelegate.sendUserData(appDelegate.session)
#endif
#endif
    } // func savePreferences()
    
    
    // MARK: - Translation between JSON and model objects
    
    private func locationsWithClocksArrayAsJSON(locationsWithClocksArray:  Array<ASALocationWithClocks>, forComplication:  Bool) ->  Array<Dictionary<String, Any>> {
        var temp:  Array<Dictionary<String, Any>> = []
        for locationWithClocks in locationsWithClocksArray.clocks {
            let dictionary = locationWithClocks.dictionary(forComplication: forComplication, location: locationWithClocks.locationData, usesDeviceLocation: locationWithClocks.usesDeviceLocation)
            temp.append(dictionary)
        }
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
    
    public static func arrayOfDictionariesToArrayOfLocationsWithClocks(_ temp: [[String : Any]]?, _ key: ASAClockArrayKey) -> [ASALocationWithClocks] {
        var tempArray:  Array<ASAClock> = []
        
        if temp != nil {
            for dictionary in temp! {
                let clock = ASAClock.new(dictionary: dictionary)
                tempArray.append(clock)
            } // for dictionary in temp!
        } else {
            return []
        }
        
        let numberOfClocks = tempArray.count
        let minimumNumberOfClocks = key.minimumNumberOfClocks
        if numberOfClocks < minimumNumberOfClocks {
            tempArray += Array.init(repeatElement(ASAClock.generic, count: minimumNumberOfClocks - numberOfClocks))
        }
        
        //        debugPrint(#file, #function, tempArray)
        return tempArray.byLocation
    }
    
    private class func locationsWithClocksArray(key:  ASAClockArrayKey, dictionary:  Dictionary<String, Any>?) -> Array<ASALocationWithClocks> {
        //        debugPrint(#file, #function, key)
        
        if dictionary == nil {
            return []
        }
        
        let temp = dictionary![key.rawValue] as! Array<Dictionary<String, Any>>?
        return arrayOfDictionariesToArrayOfLocationsWithClocks(temp, key)
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
    
    
    // MARK:  - Events
    
    func mainClocksEvents(startDate:  Date, endDate:  Date) ->  Array<ASAEventCompatible> {
        var unsortedEvents: [ASAEventCompatible] = []
        for clock in self.mainClocks.clocks {
            let clockEvents = clock.events(startDate:  startDate, endDate:  endDate)
            unsortedEvents = unsortedEvents + clockEvents.dateEvents + clockEvents.timeEvents
        } // for for clock in self.mainClocks
        
        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        return events
    } // func mainClocksEvents(startDate:  Date, endDate:  Date, row:  ASARow) ->  Array<ASAEventCompatible>
} // class ASAUserData


// MARK:  -

extension ASAUserData {
    func row(uuidString: String, backupIndex:  Int) -> ASAClock {
        let tempUUID = UUID(uuidString: uuidString)
        if tempUUID == nil {
            return ASAClock.generic
        }
        
        for locationWithClocks in self.mainClocks {
            let temp = locationWithClocks.clocks.first(where: {$0.uuid == tempUUID!})
            if temp != nil {
                return temp!
            }
        }
        
        if self.numberOfMainClocks >= backupIndex + 1 {
            return self.mainClocks.clocks[backupIndex]
        }
        
        return ASAClock.generic
    } // func row(backupIndex:  Int) -> ASARow
    
    var numberOfMainClocks: Int {
        return self.mainClocks.count
    } // var numberOfMainClocks: Int
    
    func removeMainClock(uuid: UUID) {
        for i in 0..<self.mainClocks.count {
            let index = self.mainClocks[i].clocks.firstIndex(where: {$0.uuid == uuid})
            if index != nil {
                self.mainClocks[i].clocks.remove(at: index!)
                self.savePreferences(code: .clocks)
                return
            }
        } // for i in 0..<self.mainClocks.count
    } // func removeMainClock(uuid: UUID)
    
    func addLocationWithClocks(_ newLocationWithClocks: ASALocationWithClocks) {
        self.mainClocks.insert(newLocationWithClocks, at: 0)
        self.savePreferences(code: .clocks)
    }
    
    func addMainClock(clock: ASAClock) {
        for i in 0..<self.mainClocks.count {
            if self.mainClocks[i].location == clock.locationData {
                self.mainClocks[i].clocks.insert(clock, at: 0)
                self.savePreferences(code: .clocks)
                return
            }
        } // for i in 0..<self.mainClocks.count
        
        let newLocationWithClocks = ASALocationWithClocks(location: clock.locationData, clocks: [clock], usesDeviceLocation: clock.usesDeviceLocation)
        addLocationWithClocks(newLocationWithClocks)
    } // func addMainClock(clock: ASAClock)
    
    func removeLocationWithClocks(_ locationWithClocks: ASALocationWithClocks) {
        let index = self.mainClocks.firstIndex(of: locationWithClocks)
        if index != nil {
            self.mainClocks.remove(at: index!)
            self.savePreferences(code: .clocks)
        }
    }
} // extension ASAUserData
