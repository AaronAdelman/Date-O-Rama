//
//  ASACalendarWithEaster.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 30/04/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarWithEaster: ASACalendarWithEras, ASACalendarWithMonths
{
    func calculateEaster(era: Int, year: Int) -> (month: Int, day: Int)?
}
