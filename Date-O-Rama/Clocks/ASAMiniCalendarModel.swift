//
//  ASAMiniCalendarModel.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 09/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

struct ASAMiniCalendarWeekdayModel {
    var symbol:  String
    var index:  Int
    var isWeekend: Bool
}

struct ASAMiniCalendarDayModel {
    let text: String
    let isWeekend: Bool
    let isAccented: Bool
}
