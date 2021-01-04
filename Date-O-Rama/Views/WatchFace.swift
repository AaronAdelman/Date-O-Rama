//
//  WatchFace.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  Based on https://medium.com/dwarves-foundation/draw-watch-face-using-swiftui-a863ad347b2c
//

import Foundation
import SwiftUI


struct Tick:  Shape {
    var isLong:  Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + (isLong ? 2.0 : 1.0)))
        return path
    } // func path(in rect: CGRect) -> Path
} // struct Tick


struct Ticks:  View {
    var isNight:  Bool

    var body: some View {
        ForEach(0..<60) {
            position
            in
            Tick(isLong: position % 5 == 0)
                .stroke(lineWidth: 1.0)
                .rotationEffect(.radians(Double.pi * 2.0 / 60 * Double(position)))
                .foregroundColor(Color(isNight ? "tickNight" : "tickDay"))
        }
    } // var body
} // struct Ticks


struct Number:  View {
    var isNight:  Bool
    var hour:  Int
    var numberFormatter:  NumberFormatter

    var body: some View {
        VStack {
            Text(numberFormatter.string(from: NSNumber(integerLiteral: hour)) ?? ""
)
                .font(Font.system(size: 9.0, weight: .bold))
                .rotationEffect(.radians(-(Double.pi * 2 / 12 * Double(hour))))
                .foregroundColor(Color(isNight ? "numberNight" : "numberDay"))

            Spacer().frame(height:  44.0)
        }
        .padding()
        .rotationEffect(.radians((Double.pi * 2 / 12 * Double(hour))))
    }
}


struct Numbers:  View {
    var isNight:  Bool
    var numberFormatter:  NumberFormatter

    var body: some View {
        ZStack {
            ForEach(1..<13) {
                hour
                in
                Number(isNight: isNight, hour: hour, numberFormatter: numberFormatter)
            }
        }
    }
}


struct Hand:  Shape {
    var offset:  CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(origin: CGPoint(x: rect.origin.x, y: rect.origin.y + offset), size: CGSize(width: rect.width, height: rect.height / 2.0 - offset)))
        return path
    }
}


// MARK:  - Watch

let WATCH_DIMENSION:  CGFloat             = 64.0
let BACKGROUND_CIRCLE_DIMENSION:  CGFloat = WATCH_DIMENSION - 2.0
let OUTSIDE_STROKE_WIDTH:  CGFloat        =  1.0
let TICKS_DIMENSION                       = BACKGROUND_CIRCLE_DIMENSION - 2.0 * OUTSIDE_STROKE_WIDTH
let HUB_DIMENSION:  CGFloat               =  3.0

struct Watch:  View {
    var hour:  Int
    var minute:  Int
    var second:  Int
    var isNight:  Bool

    let radianInOneHour = 2.0 * Double.pi / 12.0
    let radianInOneMinute = 2.0 * Double.pi / 60.0

    var minuteAngle:  Double {
        get {
            return Double(minute) * radianInOneMinute
        } // get
    } // var minuteAngle
    var hourAngle:  Double {
        get {
            var actualHour = Double(hour) + (Double(minute) / 60.0)
            if actualHour > 12.0 {
                actualHour -= 12.0
            }
            let result: Double = actualHour * radianInOneHour
            return result
        } // get
    } // var hourAngle

    var secondAngle:  Double  {
        get {
            return Double(second) * radianInOneMinute
        } // get
    } // var secondAngle

    var numberFormatter:  NumberFormatter

    var body:  some View {
        ZStack {
            Circle()
                .strokeBorder(Color(isNight ? "clockBorderNight" : "clockBorderDay"), lineWidth: OUTSIDE_STROKE_WIDTH)
                .background(Circle()
                                .foregroundColor(Color(isNight ? "clockBackgroundNight" : "clockBackgroundDay")))
                .frame(width: BACKGROUND_CIRCLE_DIMENSION, height: BACKGROUND_CIRCLE_DIMENSION, alignment: .center)
                .blur(radius: 0.3)
            Ticks(isNight: isNight)
                .frame(width: TICKS_DIMENSION, height: TICKS_DIMENSION, alignment: .center)
            
            Numbers(isNight: isNight, numberFormatter: numberFormatter)
                .frame(width: TICKS_DIMENSION, height: TICKS_DIMENSION, alignment: .center)

            // Hour hand
            Hand(offset: 18.0)
                .fill()
                .frame(width: 2.0, alignment: .center)
                .rotationEffect(.radians(hourAngle))
                .foregroundColor(Color(isNight ? "hourHandNight" : "hourHandDay"))

            // Minute hand
            Hand(offset: 7.0)
                .fill()
                .frame(width: 2.0, alignment: .center)
                .rotationEffect(.radians(minuteAngle))
                .foregroundColor(Color(isNight ? "minuteHandNight" : "minuteHandDay"))

            // Second hand
            Hand(offset: 3.0)
                .fill()
                .foregroundColor(Color(isNight ? "secondHandNight" : "secondHandDay"))
                .frame(width: 1.0, alignment: .center)
                .rotationEffect(.radians(secondAngle))

            Circle()
                .fill()
                .foregroundColor(Color(isNight ? "clockHubNight" : "clockHubDay"))
                .frame(width: HUB_DIMENSION, height: HUB_DIMENSION, alignment: .center)
//                .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
        }
        .frame(width: WATCH_DIMENSION, height: WATCH_DIMENSION, alignment: .center)
        .environment(\.layoutDirection, .leftToRight)
    }
}

