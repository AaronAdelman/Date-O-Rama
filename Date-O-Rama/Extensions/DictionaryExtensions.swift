//
//  DictionaryExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    func value(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String? {
        // Attempt to get an appropriate localized string out of a dictionary where the keys are locale identifiers
        
//        let userLocaleIdentifier = requestedLocaleIdentifier == "" ? Locale.autoupdatingCurrent.identifier : requestedLocaleIdentifier
        let userLocaleIdentifier = requestedLocaleIdentifier.effectiveIdentifier
        let firstAttempt = self[userLocaleIdentifier]
        if firstAttempt != nil {
            return firstAttempt
        }
        
        let userLanguageCode = userLocaleIdentifier.localeLanguageCode
        if userLanguageCode != nil {
            let secondAttempt = self[userLanguageCode!]
            if secondAttempt != nil {
                return secondAttempt
            }
        }
        
        let thirdAttempt = self[eventsFileDefaultLocaleIdentifier]
        if thirdAttempt != nil {
            return thirdAttempt
        }
        
        let fourthAttempt = self["en"]
        if fourthAttempt != nil {
            return fourthAttempt
        }
        
        if self.count > 0 {
            let (_, firstValue) = self.first!
            return firstValue
        }
      
        // If everything else fails…
        return nil
    } // func value(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String?
} // extension Dictionary where Key == String, Value == String

extension Dictionary where Key == String, Value == URL {
    func value(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> URL? {
        // Attempt to get an appropriate localized string out of a dictionary where the keys are locale identifiers
        
        let userLocaleIdentifier = requestedLocaleIdentifier == "" ? Locale.autoupdatingCurrent.identifier : requestedLocaleIdentifier
        let firstAttempt = self[userLocaleIdentifier]
        if firstAttempt != nil {
            return firstAttempt
        }
        
        let userLanguageCode = userLocaleIdentifier.localeLanguageCode
        if userLanguageCode != nil {
            let secondAttempt = self[userLanguageCode!]
            if secondAttempt != nil {
                return secondAttempt
            }
        }
        
        let thirdAttempt = self[eventsFileDefaultLocaleIdentifier]
        if thirdAttempt != nil {
            return thirdAttempt
        }
        
        let fourthAttempt = self["en"]
        if fourthAttempt != nil {
            return fourthAttempt
        }
        
        if self.count > 0 {
            let (_, firstValue) = self.first!
            return firstValue
        }
      
        // If everything else fails…
        return nil
    } // func value(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> URL?
} // extension Dictionary where Key == String, Value == URL
