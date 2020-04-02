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
    @Published var mainRows:  Array<ASARow> = [ASARow.generic()]
} // class ASAUserDate
