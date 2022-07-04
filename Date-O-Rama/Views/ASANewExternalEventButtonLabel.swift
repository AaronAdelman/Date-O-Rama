//
//  ASANewExternalEventButtonLabel.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

struct ASANewExternalEventButtonLabel: View {
    var body: some View {
        HStack {
            Image(systemName: "rectangle.badge.plus")
            Text(NSLocalizedString("Add external event", comment: ""))
        } // HStack
    }
}
