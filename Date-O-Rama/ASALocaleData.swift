//
//  ASALocaleData.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation


struct ASALocaleRecord:  Identifiable {
    var id:  String
    var nativeName:  String
} // struct ASALocaleRecord


extension String {
    func asSelfLocalizedLocaleIdentifier() -> String! {
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
    } // func asSelfLocalizedLocaleIdentifier() -> String!
} // extension String


struct ASALocaleData {
    var records:  Array<ASALocaleRecord> = []
    
    init() {
        let standardLocaleIdentifiers = [
            "ar",
            "ca",
            "cs",
            "da",
            "de",
            "el",
            "en_AU",
            "en_CA",
            "en_GB",
            "en",
            "es_419",
            "es",
            "fi",
            "fr_CA",
            "fr",
            "he",
            "hi",
            "hr",
            "hu",
            "id",
            "it",
            "ja",
            "ko",
            "ms",
            "nl",
            "no",
            "pl",
            "pt_PT",
            "pt",
            "ro",
            "ru",
            "sk",
            "sv",
            "th",
            "tr",
            "uk",
            "vi",
            "zh_CN",
            "zh_HK",
            "zh_TW"
        ]
        let sortedStandardLocaleRecords = self.sortedLocalizedRecords(identifiers: standardLocaleIdentifiers)
        
        let defaultRecords: [ASALocaleRecord] = [ASALocaleRecord(id: "", nativeName: NSLocalizedString("DEFAULT_LOCALE", comment: ""))]
        let availableLocaleIdentifiers = Locale.availableIdentifiers
        let sortedAvailableLocaleRecords = self.sortedLocalizedRecords(identifiers: availableLocaleIdentifiers)
        self.records = defaultRecords + sortedStandardLocaleRecords + sortedAvailableLocaleRecords
    } // init()
    
    private func sortedLocalizedRecords(identifiers:  Array<String>) -> Array<ASALocaleRecord> {
        var temp:  Array<ASALocaleRecord> = []
        for identifier in identifiers {
            let record = ASALocaleRecord(id: identifier, nativeName: identifier.asSelfLocalizedLocaleIdentifier())
            temp.append(record)
        } // for identifier in availableLocaleIdentifiers
        return temp.sorted(by: {$0.nativeName < $1.nativeName})
    }
} // struct ASALocaleData
