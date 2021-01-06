//
//  EKCalendarExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

extension EKCalendar {
    var color:  Color {
        return Color(self.cgColor)
    } // var color
} // extension EKCalendar
