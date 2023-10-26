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
            return "checkmark.circle"
            
        case .pending:
            return "questionmark.circle"

        case .accepted:
            return "checkmark.circle"

        case .declined:
            return "multiply.circle"

        case .tentative:
            return "questionmark.circle"

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
            
        case .tentative:
            return .orange
            
        case .declined:
            return .red
            
        default:
            return .black
        } // switch self
    } // var color: Color
    
    var text: String {
        var rawValue = ""
        
        switch self {
        case .unknown:
            rawValue = "EKParticipantStatus.unknown"
            
        case .pending:
            rawValue = "EKParticipantStatus.pending"

        case .accepted:
            rawValue = "EKParticipantStatus.accepted"

        case .declined:
            rawValue = "EKParticipantStatus.declined"

        case .tentative:
            rawValue = "EKParticipantStatus.tentative"

        case .delegated:
            rawValue = "EKParticipantStatus.delegated"

        case .completed:
            rawValue = "EKParticipantStatus.completed"

        case .inProcess:
            rawValue = "EKParticipantStatus.inProcess"

        @unknown default:
            rawValue = "EKParticipantStatus.unknown default"
        } // switch self
        
        return NSLocalizedString(rawValue, comment: "")
    }
} // extension EKParticipantStatus
