//
//  EKParticipantStatusExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

extension EKParticipantStatus {
    var systemName: String {
        switch self {
        case .unknown:
            return "u.circle"
            
        case .pending:
            return "questionmark.circle"

        case .accepted:
            return "checkmark.circle"

        case .declined:
            return "x.circle"

        case .tentative:
            return "t.circle"

        case .delegated:
            return "d.circle"

        case .completed:
            return "c.circle"

        case .inProcess:
            return "i.circle"

        @unknown default:
            return "questionmark"
        } // switch self
    } // var systemName
    
    var color: Color {
        switch self {
        case .accepted:
            return .green
            
        default:
            return .black
        } // switch self
    } // var color: Color
} // extension EKParticipantStatus
