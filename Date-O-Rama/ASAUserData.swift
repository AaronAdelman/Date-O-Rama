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

final class ASAUserData:  ObservableObject {
    private static var sharedUserData: ASAUserData = {
        let userData = ASAUserData()
        
        return userData
    }()
    
    class func shared() -> ASAUserData {
        return sharedUserData
    } // class func shared() -> ASAUserData

    @Published var mainRows:  Array<ASARow>
    @Published var internalEventCalendars:  Array<ASAInternalEventCalendar>
    
    init() {
        self.mainRows = ASAConfiguration.rowArray(key: .app)
        self.internalEventCalendars = [] // TODO:  FIX THIS!
        let coder = CLGeocoder();
        for row in self.mainRows {
            if row.location != nil {
                coder.reverseGeocodeLocation(row.location!) { (placemarks, error) in
                    let place = placemarks?.last;

                    if place != nil {
                        row.placeName = place?.name
                        row.locality = place?.locality
                        row.country = place?.country
                        row.ISOCountryCode = place?.isoCountryCode
                    }
//                    debugPrint(#file, #function, row.location as Any, place as Any)
                }
            }
        } // for row in self.mainRows
    } // init()
    
    public func savePreferences() {
        ASAConfiguration.saveRowArray(rowArray: self.mainRows, key: .app)
    }
} // class ASAUserDate
