//
//  ASASkyGradient.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASASkyGradient: View {
    fileprivate func skyGradientColors(transitionType:  ASATransitionType) -> [Color] {
        let hour: Int = processedRow.hour

        if transitionType == .midnight || transitionType == .noon {
            let color = Color.backgroundColor(transitionType: transitionType, hour: hour)
            return [color, color]
        }

        var topColor:  Color
        var bottomColor:  Color

        let minute: Int = processedRow.minute

        let minutes = hour * 60 + minute

        var eveningTwilightStart:  Int = 0
        var eveningTwilightEnd:  Int   = 0
        var morningTwilightStart:  Int = 0
        var morningTwilightEnd:  Int   = 0

        let LENGTH_OF_DAY = 24 * 60 * 60

        let TWILIGHT_LENGTH_SUNSET_TRANSITION     = 83
        let EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION = 60
        let LATE_TWILIGHT_LENGTH_DUSK_TRANSITION  = 12

        switch transitionType {
        case .sunset:
            eveningTwilightStart = 0
            eveningTwilightEnd = eveningTwilightStart + TWILIGHT_LENGTH_SUNSET_TRANSITION
            morningTwilightEnd = 12 * 60
            morningTwilightStart = morningTwilightEnd - TWILIGHT_LENGTH_SUNSET_TRANSITION

        case .dusk:
            let transitionLength = EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION
            eveningTwilightStart = LENGTH_OF_DAY - EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION
            eveningTwilightEnd = LATE_TWILIGHT_LENGTH_DUSK_TRANSITION
            morningTwilightEnd = 13 * 60
            morningTwilightStart = morningTwilightEnd - transitionLength

        default:
            debugPrint(#file, #function, transitionType)
        } // switch transitionType

        if morningTwilightStart <= minutes && minutes < morningTwilightEnd {
            // Morning twilight
            let progress = CGFloat((minutes - morningTwilightStart) / (morningTwilightEnd - morningTwilightStart))
            topColor = Color.blend(startColor: .midnightBlue, endColor: .skyBlue, progress: progress)
            bottomColor = Color.blend(startColor: .midnightBlue, endColor: .sunsetRed, progress: progress)
        } else if transitionType == .sunset && eveningTwilightStart <= minutes && minutes < eveningTwilightEnd {
            // Evening twilight, sunset transition
            let progress = CGFloat(minutes) / CGFloat(eveningTwilightEnd)
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if transitionType == .dusk && eveningTwilightStart <= minutes {
            // Early evening twilight, dusk transition
            let progress = CGFloat((LENGTH_OF_DAY - minutes) / (EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION))
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if transitionType == .dusk && minutes < eveningTwilightEnd {
            // Late evening twilight, dusk transition
            let progress = CGFloat((EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + minutes) / (EARLY_TWILIGHT_LENGTH_DUSK_TRANSITION + LATE_TWILIGHT_LENGTH_DUSK_TRANSITION))
            topColor = Color.blend(startColor: .skyBlue, endColor: .midnightBlue, progress: progress)
            bottomColor = Color.blend(startColor: .sunsetRed, endColor: .midnightBlue, progress: progress)
        } else if hour >= 0 && hour <= 11 {
            // Night
            topColor = .midnightBlue
            bottomColor = .midnightBlue
        } else {
            // Day
            topColor = .skyBlue
            bottomColor = .skyBlue
        }

        return [topColor, bottomColor]
    } // func skyGradientColors() -> [Color]

    var processedRow:  ASAProcessedRow

    var body: some View {
        LinearGradient(gradient: Gradient(colors: skyGradientColors(transitionType: processedRow.transitionType)), startPoint: .top, endPoint: .bottom)
    }
}

//struct ASASkyGradient_Previews: PreviewProvider {
//    static var previews: some View {
//        ASASkyGradient()
//    }
//}
