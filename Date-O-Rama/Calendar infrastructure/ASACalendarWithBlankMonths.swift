//
//  ASACalendarWithBlankMonths.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 15/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarWithBlankMonths: ASACalendarWithMonths {
    var blankMonths: Array<Int> { get }
    var blankWeekdaySymbol: String { get }
} // protocol ASACalendarWithBlankMonths

