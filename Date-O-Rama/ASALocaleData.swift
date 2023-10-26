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
    var standardLocaleRecords:  Array<ASALocaleRecord> = []
    var recordsForUsersLanguage: Array<ASALocaleRecord> = []
    var recordsForUsersRegion:  Array<ASALocaleRecord> = []
    
    public func defaultLocaleRecords() -> [ASALocaleRecord] {
        return [ASALocaleRecord(id: "", nativeName: NSLocalizedString("DEFAULT_LOCALE", comment: ""))]
    }

    init() {
        let standardLocaleIdentifiers = [
            "ar_001", "ca_ES", "cs_CZ", "da_DK", "de_DE", "el_GR", "en_AU", "en_CA", "en_GB", "en_US", "es_419", "es_ES", "fi_FI", "fr_CA", "fr_FR", "he_IL", "hi_IN", "hr_HR", "hu_HU", "id_ID", "it_IT", "ja_JP", "ko_KR", "ms_MY", "nl_NL", "no_NO", "pl_PL", "pt_PT", "pt_BR", "ro_RO", "ru_RU", "sk_SK", "sv_SE", "th_TH", "tr_TR", "uk_UA", "vi_VN", "zh_CN", "zh_HK", "zh_TW"
        ]
        let sortedStandardLocaleRecords = self.sortedLocalizedRecords(identifiers: standardLocaleIdentifiers)
        
        let defaultRecords: [ASALocaleRecord] = defaultLocaleRecords()
        let availableLocaleIdentifiers = Locale.availableIdentifiers
        let sortedAvailableLocaleRecords = self.sortedLocalizedRecords(identifiers: availableLocaleIdentifiers)
        self.allRecords = defaultRecords + sortedAvailableLocaleRecords
        self.standardLocaleRecords = defaultRecords + sortedStandardLocaleRecords
        self.recordsForUsersLanguage = self.recordsForTheUsersLanguage()
        self.recordsForUsersRegion = self.recordsForTheUsersRegion()
    } // init()
    
    public func sortedLocalizedRecords(identifiers:  Array<String>) -> Array<ASALocaleRecord> {
        var temp:  Array<ASALocaleRecord> = []
        for identifier in identifiers {
            let record = ASALocaleRecord(id: identifier, nativeName: identifier.asSelfLocalizedLocaleIdentifier)
            temp.append(record)
        } // for identifier in availableLocaleIdentifiers
        return temp.sorted(by: {$0.nativeName < $1.nativeName})
    } // func sortedLocalizedRecords(identifiers:  Array<String>) -> Array<ASALocaleRecord>
    
    func recordsForTheUsersLanguage() -> Array<ASALocaleRecord> {
        let usersLanguageCode = Locale.autoupdatingCurrent.languageCode
        //        debugPrint(#file, #function, "User’s language code", usersLanguageCode)
        let result = self.allRecords.filter {
            let languageCode = $0.id.localeLanguageCode
            //            debugPrint(#file, #function, "Language code", languageCode)
            return languageCode == usersLanguageCode
        }
        return result
    } // func recordsFor(languageCode:  String) -> Array<ASALocaleRecord>
    
    func recordsForTheUsersRegion() -> Array<ASALocaleRecord> {
        let usersRegionCode = Locale.autoupdatingCurrent.regionCode
        //        debugPrint(#file, #function, "User’s language code", usersLanguageCode)
        let result = self.allRecords.filter {
            let regionCode = $0.id.localeRegionCode
            //            debugPrint(#file, #function, "Language code", languageCode)
            return regionCode == usersRegionCode
        }
        return result
    } // func recordsForUsersRegion() -> Array<ASALocaleRecord>
} // struct ASALocaleData
