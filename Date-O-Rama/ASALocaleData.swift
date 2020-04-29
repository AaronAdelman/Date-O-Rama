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
            "ar_001",
            "ca_ES",
            "cs_CZ",
            "da_DK",
            "de_DE",
            "el_GR",
            "en_AU",
            "en_CA",
            "en_GB",
            "en_US",
            "es_419",
            "es_ES",
            "fi_FI",
            "fr_CA",
            "fr_FR",
            "he_IL",
            "hi_IN",
            "hr_HR",
            "hu_HU",
            "id_ID",
            "it_IT",
            "ja_JP",
            "ko_KR",
            "ms_MY",
            "nl_NL",
            "no_NO",
            "pl_PL",
            "pt_PT",
            "pt_BR",
            "ro_RO",
            "ru_RU",
            "sk_SK",
            "sv_SE",
            "th_TH",
            "tr_TR",
            "uk_UA",
            "vi_VN",
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
