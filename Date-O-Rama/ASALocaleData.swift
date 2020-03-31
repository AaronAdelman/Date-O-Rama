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
        var temp:  Array<ASALocaleRecord> = []
        let availableLocaleIdentifiers = Locale.availableIdentifiers
        for identifier in availableLocaleIdentifiers {
            let record = ASALocaleRecord(id: identifier, nativeName: identifier.asSelfLocalizedLocaleIdentifier())
            temp.append(record)
        } // for identifier in availableLocaleIdentifiers
        self.records = [ASALocaleRecord(id: "", nativeName: NSLocalizedString("DEFAULT_LOCALE", comment: ""))] + temp.sorted(by: {$0.nativeName < $1.nativeName})
    } // init()
} // struct ASALocaleData
