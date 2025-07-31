//
//  ASAClockDistilation.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

protocol ASAClockDistilation {
    var timeString:  String? { get }
    var transitionType:  ASATransitionType { get }
    var hour:  Int? { get }
    var minute:  Int? { get }
    var second:  Int? { get }
    var fractionalHour: Double? { get }
    var dayHalf: ASADayHalf? { get }
} // protocol ASAClockDistilation

// TODO:  Create an extension to take information in a distilation and figure out whether it’s day or night or whatever.
