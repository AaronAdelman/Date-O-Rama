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

final class ASAUserData:  ObservableObject {
    @Published var mainRows:  Array<ASARow>
//        = [ASARow.generic()]
    
    init() {
        self.mainRows = ASAConfiguration.rowArray(key: .app)
    }
    
    public func savePreferences() {
        ASAConfiguration.saveRowArray(rowArray: self.mainRows, key: .app)
    }
} // class ASAUserDate
