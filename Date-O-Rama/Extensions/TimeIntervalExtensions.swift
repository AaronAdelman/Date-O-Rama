//
//  TimeIntervalExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

extension TimeInterval {
    var formatted: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full

        return formatter.string(from: self)
    }
}
