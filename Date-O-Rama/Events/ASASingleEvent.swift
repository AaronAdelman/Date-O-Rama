//
//  ASASingleEvent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/06/2023.
//  Copyright © 2023 Adelsoft. All rights reserved.
//

import Foundation

protocol ASASingleEvent: ASAEventCompatible {
    var url: URL? { get } // The URL for the calendar item.
    var hasNotes: Bool { get } // A Boolean value that indicates whether the calendar item has notes.
    var notes: String? { get } // The notes associated with the calendar item.
} // protocol ASASingleEvent
