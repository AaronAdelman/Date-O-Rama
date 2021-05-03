//
//  EKParticipantExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 03/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

extension EKParticipant {
    var EMailAddress: String {
        return self.url.relativeString.replacingOccurrences(of: "mailto:", with: "")
    } // var EMailAddress: String
} // extension EKParticipant
