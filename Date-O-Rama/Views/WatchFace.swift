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

struct Arc:  Shape {
    var startAngle:  Angle = .radians(0.0)
    var endAngle:  Angle   = .radians(Double.pi * 2.0)
    var clockwise:  Bool   = true

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width / 2.0, rect.height / 2.0)

        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return path
    } // func path(in rect: CGRect) -> Path
} // struct Arc


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
    var body: some View {
        ForEach(0..<60) {
            position
            in
            Tick(isLong: position % 5 == 0)
                .stroke(lineWidth: 1.0)
                .rotationEffect(.radians(Double.pi * 2.0 / 60 * Double(position)))
        }
    } // var body
} // struct Ticks


//struct Number:  View {
//    var hour:  Int
//
//    var body: some View {
////        VStack {
//            Text("\(hour)")
////                .fontWeight(.bold)
//                .rotationEffect(.radians(-(Double.pi * 2.0 / 12.0 * Double(hour))))
//                .font(.caption2)
////            Spacer()
////        }
//        .padding()
//        .rotationEffect(.radians((Double.pi * 2.0 / 12.0 * Double(hour))))
//    }
//}
//
//
//struct Numbers:  View {
//    var body: some View {
//        ZStack {
//            ForEach(1..<13) {
//                hour
//                in
//                Number(hour: hour)
//            }
//        }
//    }
//}


struct Hand:  Shape {
    var offset:  CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(origin: CGPoint(x: rect.origin.x, y: rect.origin.y + offset), size: CGSize(width: rect.width, height: rect.height / 2.0 - offset)), cornerSize: CGSize(width: rect.width / 2.0, height: rect.width / 2.0))
        return path
    }
}


// MARK:  - Watch

let WATCH_DIMENSION:  CGFloat = 48.0
let HUB_DIMENSION:  CGFloat   =  2.0

struct Watch:  View {
    var hour:  Int
    var minute:  Int
    var second:  Int

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

    var body:  some View {
        ZStack {
            Arc(startAngle: .radians(0.0), endAngle: .radians(Double.pi * 2.0))
                .stroke(lineWidth: 1.0)
            Ticks()
            //            Numbers()
            Circle()
                .fill()
                .frame(width: HUB_DIMENSION, height: HUB_DIMENSION, alignment: .center)
            // Minute hand
            Hand(offset: 7.0)
                .fill()
                .frame(width: 1.0, alignment: .center)
                .rotationEffect(.radians(minuteAngle))
//                .foregroundColor(.primary)

            // Hour hand
            Hand(offset: 12)
                .fill()
                .frame(width: 2.0, alignment: .center)
                .rotationEffect(.radians(hourAngle))
//                .foregroundColor(.primary)

            // Second hand
            Hand(offset: 3.0)
                .fill()
                .foregroundColor(.orange)
                .frame(width: 0.5, alignment: .center)
                .rotationEffect(.radians(secondAngle))

            Circle()
                .fill()
//                .foregroundColor(.gray)
                .frame(width: 4.0, height: 4.0, alignment: .center)
                .shadow(color: .black, radius: 1.0, x: 1.0, y: 1.0)
        }
        .frame(width: WATCH_DIMENSION, height: WATCH_DIMENSION, alignment: .center)
        .environment(\.layoutDirection, .leftToRight)
    }
}

