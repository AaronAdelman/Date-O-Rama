//
//  FontExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    static var headlineMonospacedDigit:  Font {
        get {
            return Font.headline.monospacedDigit()
        } // get
    }

    static var subheadlineMonospacedDigit:  Font {
        get {
            return Font.subheadline.monospacedDigit()
        } // get
    }
}
