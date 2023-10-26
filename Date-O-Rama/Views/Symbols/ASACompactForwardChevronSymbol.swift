//
//  ASACompactForwardChevronSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 21/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACompactForwardChevronSymbol: View {
    var characterDirection:  Locale.LanguageDirection {
        return Locale.characterDirection(forLanguage: Locale.current.identifier)
    } // var characterDirection
    
    var body: some View {
        switch characterDirection {
        case .leftToRight:
            Image(systemName: "chevron.compact.right")
            
        case .rightToLeft:
            Image(systemName: "chevron.compact.left")
        default:
            Image(systemName: "chevron.compact.right")
        } // switch characterDirection
    }
}

struct ASACompactForwardChevronSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASACompactForwardChevronSymbol()
    }
}
