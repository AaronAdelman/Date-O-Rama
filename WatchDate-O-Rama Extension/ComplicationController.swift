//
//  ComplicationController.swift
//  Date-O-Rama WatchKit Extension
//
//  Created by אהרן שלמה אדלמן on 2017-11-14.
//  Copyright © 2017 Adelsoft. All rights reserved.
//

import ClockKit
import WatchKit
import SwiftUI

extension ASAModel {
    func locationWithClocks(for complicationFamily:  CLKComplicationFamily) -> ASALocationWithClocks? {
        switch complicationFamily {
        case .modularLarge, .graphicRectangular:
            return self.threeLineLargeClocks
            
        case .modularSmall, .circularSmall, .graphicCircular:
            return self.twoLineSmallClocks
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            return self.oneLineSmallClocks
            
        case .utilitarianLarge:
            return self.oneLineLargeClocks
            
        case .extraLarge:
            return self.twoLineLargeClocks
            
        default:
            return nil
        } // switch complicationFamily
    } // func locationWithClocks(for complicationFamily:  CLKComplicationFamily) -> Array<ASARow>?
} // extension ASAModel


// MARK: -

class ComplicationController: NSObject, CLKComplicationDataSource {
//    public var complication:  CLKComplication?
    
    let  userData = ASAModel.shared

    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        // TODO:  Deprecated!
//        debugPrint("\(#file) \(#function)")
        
        handler([.forward
                 //            , .backward
        ])
    } // func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void)
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // TODO:  Deprecated!
//        debugPrint("\(#file) \(#function)")
        
        handler(Date.distantPast)
    } // func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void)
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        debugPrint("\(#file) \(#function)")
        
        handler(Date.distantFuture)
    } // func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void)
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
//        debugPrint("\(#file) \(#function)")
        
        handler(.showOnLockScreen)
    } // func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void)
    
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
//        debugPrint("\(#file) \(#function)")
        
        // TODO:  Is this section needed?
//        let myDelegate = WKApplication.shared().delegate as! ExtensionDelegate
//        myDelegate.complicationController = self
//        self.complication = complication
        // End of questionable section.
        
        // Call the handler with the current timeline entry
        
        let now = Date()
//        debugPrint("• \(#file) \(#function) now = \(now)")
        let entry = self.getTimelineEntryForComplication(complication: complication, now:  now
        )
        
        handler(entry)
    } // func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)

    func earliestStartOfNextDay(when:  Date, locationWithClocks:  ASALocationWithClocks) -> Date {
        var result = Date.distantFuture
        
        for clock in locationWithClocks.clocks {
            let startOfNextDay = clock.startOfNextDay(date: when, location: locationWithClocks.location)
            if startOfNextDay < result {
                result = startOfNextDay
            }
        } // for clock in locationWithClocks.clocks
        
        return result
    } // func earliestStartOfNextDay(when:  Date, locationWithClocks:  ASALocationWithClocks) -> Date
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
//        debugPrint("\(#file) \(#function) after \(date), limit = \(limit)")
        
        var entries: [CLKComplicationTimelineEntry]? = []
        var when = date
        let rowArray = self.userData.locationWithClocks(for: complication.family)
        if rowArray == nil {
            return
        }
        
        for _ in 1...limit {
            when = self.earliestStartOfNextDay(when: when, locationWithClocks: rowArray!)
            entries?.append(self.getTimelineEntryForComplication(complication: complication, now: when)!)
        } // for i
//        debugPrint("\(#file) \(#function) entries = \(String(describing: entries))")
        
        
        // Call the handler with the timeline entries prior to the given date
        handler(entries)
    } // func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
    
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
//        debugPrint("\(#file) \(#function)")
        
        // This method will be called once per supported complication, and the results will be cached
        //        handler(nil)
        
        let now = Date()
        
        switch complication.family {
        case .circularSmall:
            let template = self.circularSmallTemplate(now: now)
            handler(template)
            
        case .extraLarge:
            let template = self.extraLargeTemplate(now: now)
            handler(template)
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = self.utilitarianSmallTemplate(now: now)
            handler(template)
            
        case .utilitarianLarge:
            let template = self.utilitarianLargeTemplate(now: now)
            handler(template)

        case .modularSmall:
            let template = self.modularSmallTemplate(now: now)
            handler(template)
            
        case .modularLarge:
            let template = self.modularLargeTemplate(now: now)
            handler(template)
            
        case .graphicRectangular:
            let template = self.graphicRectangularTemplate(now: now)
            handler(template)
            
        case .graphicCircular:
            let template = self.graphicCircularTemplate(now: now)
            handler(template)
            
        default:
            handler(nil)
        } // switch complication.family
    } // func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    
    func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.always)
    } // func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void)
    
    
    // MARK:  -
    
    func oneLineSmallRowString(now:  Date) -> String {
        let locationWithClocks = self.userData.oneLineSmallClocks
        let headerRow = locationWithClocks.clocks[0]
        
        // Header date
        let headerString = headerRow.dateString(now: now, location: locationWithClocks.location)

//        debugPrint(#file, #function, headerString)
        return headerString
    } // func oneLineSmallRowString(now:  Date) -> String

    func oneLineLargeRowString(now:  Date) -> String {
        let locationWithClocks = self.userData.oneLineLargeClocks
        let headerRow = locationWithClocks.clocks[0]
        
        // Header date
        let headerString = headerRow.dateString(now: now, location: locationWithClocks.location)

//        debugPrint(#file, #function, headerString)
        return headerString
    } // func oneLineLargeRowString(now:  Date) -> String

    func twoLineSmallRowStrings(now:  Date) -> (headerString:  String, body1String:  String) {
        let locationWithClocks = self.userData.twoLineSmallClocks
        let clocks = locationWithClocks.clocks
        let location = locationWithClocks.location
        let headerRow = clocks[0]
        let body1Row  = clocks[1]
        
        // Header date
        let headerString = headerRow.dateString(now: now, location: location)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now, location: location)

//        debugPrint(#file, #function, headerString, body1String)
        return (headerString, body1String)
    } // func twoLineSmallRowStrings(now:  Date) -> (headerString:  String, body1String:  String)
    
    func twoLineLargeRowStrings(now:  Date) -> (headerString:  String, body1String:  String) {
        let locationWithClocks = self.userData.twoLineLargeClocks
        let clocks = locationWithClocks.clocks
        let location = locationWithClocks.location
        let headerRow = clocks[0]
        let body1Row  = clocks[1]
        
        // Header date
        let headerString = headerRow.dateString(now: now, location: location)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now, location: location)

//        debugPrint(#file, #function, headerString, body1String)
        return (headerString, body1String)
    } // func twoLineLargeRowStrings(now:  Date) -> (headerString:  String, body1String:  String)

    
    func threeLineLargeRowStrings(now:  Date) -> (headerString:  String, body1String:  String, body2String:  String) {
        let locationWithClocks = self.userData.threeLineLargeClocks
        let clocks = locationWithClocks.clocks
        let location = locationWithClocks.location
        let headerRow = clocks[0]
        let body1Row  = clocks[1]
        let body2Row  = clocks[2]
        
        // Header date
        let headerString = headerRow.dateString(now: now, location: location)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now, location: location)
        
        // Body 2 date
        let body2String = body2Row.dateString(now: now, location: location)

//        debugPrint(#file, #function, headerString, body1String, body2String)
        return (headerString, body1String, body2String)
    } // func threeLineLargeRowStrings(now:  Date) -> (headerString:  String, body1String:  String, body2String:  String)

    
    // MARK:  -
    
    func modularSmallTemplate(now:  Date) -> CLKComplicationTemplateModularSmallStackText {
        let (headerString, body1String) = self.twoLineSmallRowStrings(now: now)
        let template = CLKComplicationTemplateModularSmallStackText(line1TextProvider: CLKSimpleTextProvider(text: headerString), line2TextProvider: CLKSimpleTextProvider(text: body1String))
        return template
    } // func modularSmallTemplate(now:  Date) -> CLKComplicationTemplateModularSmallStackText
    
    func modularLargeTemplate(now:  Date) -> CLKComplicationTemplateModularLargeStandardBody {
        let (headerString, body1String, body2String) = self.threeLineLargeRowStrings(now: now)
        let template = CLKComplicationTemplateModularLargeStandardBody(headerImageProvider: nil, headerTextProvider: CLKSimpleTextProvider(text: headerString), body1TextProvider: CLKSimpleTextProvider(text: body1String), body2TextProvider: CLKSimpleTextProvider(text:body2String))
        return template
    } // func modularLargeTemplate(now:  Date) -> CLKComplicationTemplateModularLargeStandardBody
    
    func graphicRectangularTemplate(now:  Date) -> CLKComplicationTemplateGraphicRectangularFullView<ASAThreeLineLargeView> {
        let (headerString, body1String, body2String) = self.threeLineLargeRowStrings(now: now)
        let template = CLKComplicationTemplateGraphicRectangularFullView(ASAThreeLineLargeView(line0: headerString, line1: body1String, line2: body2String))
        return template
    } // func graphicRectangularTemplate(now:  Date) -> CLKComplicationTemplateGraphicRectangularFullView<ASAThreeLineLargeView>
    
    func circularSmallTemplate(now:  Date) -> CLKComplicationTemplateCircularSmallStackText {
        let (headerString, body1String) = self.twoLineSmallRowStrings(now: now)
        let template = CLKComplicationTemplateCircularSmallStackText(line1TextProvider: CLKSimpleTextProvider(text: headerString), line2TextProvider: CLKSimpleTextProvider(text: body1String))
        return template
    } // func circularSmallTemplate(now:  Date) -> CLKComplicationTemplateCircularSmallStackText
    
    func extraLargeTemplate(now:  Date) -> CLKComplicationTemplateExtraLargeStackText {
        let (headerString, body1String) = self.twoLineLargeRowStrings(now: now)
        let template = CLKComplicationTemplateExtraLargeStackText(line1TextProvider: CLKSimpleTextProvider(text: headerString), line2TextProvider: CLKSimpleTextProvider(text: body1String))
        return template
    } // func extraLargeTemplate(now:  Date) -> CLKComplicationTemplateExtraLargeStackText
    
    func utilitarianSmallTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianSmallFlat {
        let headerString = self.oneLineSmallRowString(now: now)
        let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKSimpleTextProvider(text: headerString), imageProvider: nil)
        return template
    } // func utilitarianSmallTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianSmallFlat

    func utilitarianLargeTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let headerString = self.oneLineLargeRowString(now: now)
        let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKSimpleTextProvider(text: headerString), imageProvider: nil)
        return template
    } // func utilitarianLargeTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianLargeFlat
    
    func graphicCircularTemplate(now:  Date) -> CLKComplicationTemplateGraphicCircularStackText {
        let (headerString, body1String) = self.twoLineSmallRowStrings(now: now)

        let template = CLKComplicationTemplateGraphicCircularStackText(line1TextProvider: CLKSimpleTextProvider(text: headerString), line2TextProvider: CLKSimpleTextProvider(text: body1String))
        return template
    } // // func graphicCircularTemplate(now:  Date) -> CLKComplicationTemplateGraphicCircularStackText

    
    // MARK: -
    
    func getTimelineEntryForComplication(complication: CLKComplication, now: Date) -> CLKComplicationTimelineEntry? {
//        debugPrint("\(#file) \(#function) now = \(now)")
        
        switch complication.family {
        case .circularSmall:
            let template = self.circularSmallTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .extraLarge:
            let template = self.extraLargeTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = self.utilitarianSmallTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .utilitarianLarge:
            let template = self.utilitarianLargeTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .modularSmall:
            let template = self.modularSmallTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .modularLarge:
            let template = self.modularLargeTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .graphicRectangular:
            let template = self.graphicRectangularTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        case .graphicCircular:
            let template = self.graphicCircularTemplate(now: now)
            let entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: template)
            return entry
            
        default:
            return nil
        } // switch complication.family
    } // func getTimelineEntryForComplication(complication: CLKComplication, now: Date) -> CLKComplicationTimelineEntry?

    // MARK:  -

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let threeLineLargeClocksDescriptor = CLKComplicationDescriptor(
            identifier: ASAClockArrayKey.threeLineLarge.rawValue,
            displayName: NSLocalizedString("3-line large", comment: ""),
            supportedFamilies: [.modularLarge, .graphicRectangular])

        let twoLineSmallClocksDescriptor = CLKComplicationDescriptor(identifier: ASAClockArrayKey.twoLineSmall.rawValue, displayName: NSLocalizedString("2-line small", comment: ""), supportedFamilies: [.modularSmall, .circularSmall, .graphicCircular])

        let twoLineLargeClocksDescriptor = CLKComplicationDescriptor(identifier: ASAClockArrayKey.twoLineLarge.rawValue, displayName: NSLocalizedString("2-line large", comment: ""), supportedFamilies: [.extraLarge])

        let oneLineSmallClocksDescriptor = CLKComplicationDescriptor(identifier: ASAClockArrayKey.oneLineSmall.rawValue, displayName: NSLocalizedString("1-line small", comment: ""), supportedFamilies: [.utilitarianSmall, .utilitarianSmallFlat])

        let oneLineLargeClocksDescriptor = CLKComplicationDescriptor(identifier: ASAClockArrayKey.oneLineLarge.rawValue, displayName: NSLocalizedString("1-line large", comment: ""), supportedFamilies: [.utilitarianLarge])

        handler([threeLineLargeClocksDescriptor, twoLineSmallClocksDescriptor, twoLineLargeClocksDescriptor, oneLineSmallClocksDescriptor, oneLineLargeClocksDescriptor])
    } // func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void)
} // class ComplicationController: NSObject, CLKComplicationDataSource
