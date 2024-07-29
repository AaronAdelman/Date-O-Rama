//
//  ASALocaleData.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation


struct ASALocaleRecord:  Identifiable {
    var id: String
    var nativeName: String
    var localName: String
} // struct ASALocaleRecord


extension String {
    var asSelfLocalizedLocaleIdentifier:  String! {
        if self == "" {
            return NSLocalizedString("DEFAULT_LOCALE", comment: "")
        }
        
        let locale = Locale(identifier: self)
        let localizedString = locale.localizedString(forIdentifier: self)
        if localizedString != nil {
            return localizedString
        } else {
            return self
        }
    } // var asSelfLocalizedLocaleIdentifier
} // extension String


struct ASALocaleData {
    var allRecords:  Array<ASALocaleRecord> = []
    
    public func defaultLocaleRecords() -> [ASALocaleRecord] {
        return [ASALocaleRecord(id: "", nativeName: NSLocalizedString("DEFAULT_LOCALE", comment: ""), localName: "")]
    }

    init() {
        let defaultRecords: [ASALocaleRecord] = defaultLocaleRecords()
        let availableLocaleIdentifiers = Locale.availableIdentifiers
        let sortedAvailableLocaleRecords = self.sortedLocalizedRecords(identifiers: availableLocaleIdentifiers)
        self.allRecords = defaultRecords + sortedAvailableLocaleRecords
    } // init()
    
    public func sortedLocalizedRecords(identifiers:  Array<String>) -> Array<ASALocaleRecord> {
        var temp:  Array<ASALocaleRecord> = []
                
        let currentLocale: Locale = Locale.current
        for identifier in identifiers {
            let localName = currentLocale.localizedString(forIdentifier: identifier) ?? ""
            
            let record = ASALocaleRecord(id: identifier, nativeName: identifier.asSelfLocalizedLocaleIdentifier, localName: localName)
            temp.append(record)
        } // for identifier in availableLocaleIdentifiers
        return temp.sorted(by: {$0.nativeName < $1.nativeName})
    } // func sortedLocalizedRecords(identifiers:  Array<String>) -> Array<ASALocaleRecord>
} // struct ASALocaleData
