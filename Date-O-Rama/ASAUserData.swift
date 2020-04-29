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
    @Published var mainRows:  Array<ASARow>
    
    init() {
        self.mainRows = ASAConfiguration.rowArray(key: .app)
        let coder = CLGeocoder();
        for row in self.mainRows {
            if row.location != nil {
                coder.reverseGeocodeLocation(row.location!) { (placemarks, error) in
                    let place = placemarks?.last;
                    
                    if place != nil {
                        row.placemark = place
                    }
                    debugPrint(#file, #function, row.location as Any, place as Any)
                }
            }
        } // for row in self.mainRows
    } // init()
    
    public func savePreferences() {
        ASAConfiguration.saveRowArray(rowArray: self.mainRows, key: .app)
    }
} // class ASAUserDate
