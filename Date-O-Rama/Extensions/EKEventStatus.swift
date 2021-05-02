//
//  EKEventStatus.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit
import SwiftUI

extension EKEventStatus {
    var text: String {
        var rawString = ""
        switch self {
        case .none:
            return ""
            
        case .confirmed:
            rawString = "EKEventStatus.confirmed"
            
        case .tentative:
            rawString = "EKEventStatus.tentative"

        case .canceled:
            rawString = "EKEventStatus.canceled"

        @unknown default:
            rawString = "EKEventStatus.@unknown default"
        } // switch self
        
        return NSLocalizedString(rawString, comment: "")
    } // var text: String
    
    var color: Color {
        switch self {
        case .none:
            return .black
            
        case .confirmed:
            return .green
            
        case .tentative:
            return .yellow
            
        case .canceled:
            return .red
            
        @unknown default:
            return .gray
        } // switch self
    } // var color: Color
} // extension EKEventStatus
