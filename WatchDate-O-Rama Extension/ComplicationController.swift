//
//  ComplicationController.swift
//  DoubleDate WatchKit Extension
//
//  Created by אהרן שלמה אדלמן on 2017-11-14.
//  Copyright © 2017 Adelsoft. All rights reserved.
//

import ClockKit
import WatchKit

extension ASAUserData {
    func rowArray(for complicationFamily:  CLKComplicationFamily) -> Array<ASARow>? {
        switch complicationFamily {
        case .modularLarge:
            return self.modularLargeRows
            
        case .modularSmall:
            return self.modularSmallRows
            
        case .utilitarianSmall:
            return self.utilitarianSmallRows
            
        case .utilitarianSmallFlat:
            return self.utilitarianSmallRows
            
        case .utilitarianLarge:
            return self.utilitarianLargeRows
            
        case .circularSmall:
            return self.circularSmallRows
            
        case .extraLarge:
            return self.extraLargeRows
            
        default:
            return nil
        } // switch complicationFamily
    } // func rowArray(for complicationFamily:  CLKComplicationFamily) -> Array<ASARow>?
} // extension ASAUserData


// MARK: -

class ComplicationController: NSObject, CLKComplicationDataSource {
    public var complication:  CLKComplication?
    
    let  userData = ASAUserData.shared()
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        print("\(#file) \(#function)")
        
        handler([.forward
            //            , .backward
        ])
    } // func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void)
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        print("\(#file) \(#function)")
        
        handler(Date.distantPast)
    } // func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void)
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        print("\(#file) \(#function)")
        
        handler(Date.distantFuture)
    } // func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void)
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        print("\(#file) \(#function)")
        
        handler(.showOnLockScreen)
    } // func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void)
    
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        print("\(#file) \(#function)")
        
        let myDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        myDelegate.complicationController = self
        self.complication = complication
        
        // Call the handler with the current timeline entry
        
        //        let now = Calendar.current.startOfDay(for: Date()) // Midnight.  Will need to rethink this for support of calendars which start the day at Sunset or other times other than midnight.
        let now = Date()
        print("• \(#file) \(#function) now = \(now)")
        let entry = self.getTimelineEntryForComplication(complication: complication, now:  now
        )
        
        handler(entry)
    } // func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    
    //    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
    //        print("\(#file) \(#function) before \(date), limit = \(limit)")
    //
    //        var entries: [CLKComplicationTimelineEntry]? = []
    //        var when = date
    //        for _ in 1...limit {
    //            when = when - (60 * 60 * 24)
    //            entries = [self.getTimelineEntryForComplication(complication: complication, now: when)!] + entries!
    //        } // for i
    //
    //// Call the handler with the timeline entries prior to the given date
    //        handler(entries)
    //    } // func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
    
    func earliestStartOfNextDay(when:  Date, rowArray:  Array<ASARow>) -> Date {
        var result = Date.distantFuture
        
        for row in rowArray {
            let startOfNextDay = row.startOfNextDay(date: when)
            if startOfNextDay < result {
                result = startOfNextDay
            }
        } // for row in rowArray
        
        return result
    } // func earliestStartOfNextDay(when:  Date, rowArray:  Array<ASARow>) -> Date
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("\(#file) \(#function) after \(date), limit = \(limit)")
        
        var entries: [CLKComplicationTimelineEntry]? = []
        var when = date
        let rowArray = self.userData.rowArray(for: complication.family)
        if rowArray == nil {
            return
        }
        
        for _ in 1...limit {
//            when = when + (60 * 60 * 24)
            when = self.earliestStartOfNextDay(when: when, rowArray: rowArray!)
            entries?.append(self.getTimelineEntryForComplication(complication: complication, now: when)!)
        } // for i
        print("\(#file) \(#function) entries = \(String(describing: entries))")
        
        
        // Call the handler with the timeline entries prior to the given date
        //        handler(nil)
        handler(entries)
    } // func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
    
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        print("\(#file) \(#function)")
        
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
            
        default:
            handler(nil)
        } // switch complication.family
    } // func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    
    func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.always)
    } // func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void)
    
    
    // MARK:  -
    
    func modularSmallTemplate(now:  Date) -> CLKComplicationTemplateModularSmallStackText {
        let headerRow = self.userData.modularSmallRows[0]
        let body1Row  = self.userData.modularSmallRows[1]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        //let headerString = "…"
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now)
        //let body1String = "…"
        
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: headerString)
        template.line2TextProvider = CLKSimpleTextProvider(text: body1String)
        return template
    } // func modularSmallTemplate(now:  Date) -> CLKComplicationTemplateModularSmallStackText
    
    func modularLargeTemplate(now:  Date) -> CLKComplicationTemplateModularLargeStandardBody {
        let headerRow = self.userData.modularLargeRows[0]
        let body1Row  = self.userData.modularLargeRows[1]
        let body2Row  = self.userData.modularLargeRows[2]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        //let headerString = "…"
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now)
        //let body1String = "…"
        
        // Body 2 date
        let body2String = body2Row.dateString(now: now)
        //let body2String = "…≥≥"
        
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: headerString)
        //            template.headerTextProvider.tintColor = ASAConfiguration().color(row: .header)
        template.body1TextProvider = CLKSimpleTextProvider(text: body1String)
        template.body2TextProvider = CLKSimpleTextProvider(text:body2String)
        return template
    } // func modularLargeTemplate(now:  Date) -> CLKComplicationTemplateModularLargeStandardBody
    
    func circularSmallTemplate(now:  Date) -> CLKComplicationTemplateCircularSmallStackText {
        let headerRow = self.userData.circularSmallRows[0]
        let body1Row  = self.userData.circularSmallRows[1]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now)
        
        let template = CLKComplicationTemplateCircularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: headerString)
        template.line2TextProvider = CLKSimpleTextProvider(text: body1String)
        return template
    } // func circularSmallTemplate(now:  Date) -> CLKComplicationTemplateCircularSmallStackText
    
    func extraLargeTemplate(now:  Date) -> CLKComplicationTemplateExtraLargeStackText {
        let headerRow = self.userData.extraLargeRows[0]
        let body1Row  = self.userData.extraLargeRows[1]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now)
       
        let template = CLKComplicationTemplateExtraLargeStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: headerString)
        template.line2TextProvider = CLKSimpleTextProvider(text: body1String)
        return template
    } // func extraLargeTemplate(now:  Date) -> CLKComplicationTemplateExtraLargeStackText
    
    func utilitarianSmallTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianSmallFlat {
        let headerRow = self.userData.utilitarianSmallRows[0]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKSimpleTextProvider(text: headerString)
        return template
    } // func utilitarianSmallTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianSmallFlat

    func utilitarianLargeTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let headerRow = self.userData.utilitarianLargeRows[0]
        
        // Header date
        let headerString = headerRow.dateString(now: now)
        
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = CLKSimpleTextProvider(text: headerString)
        return template
    } // func utilitarianLargeTemplate(now:  Date) -> CLKComplicationTemplateUtilitarianLargeFlat

    func getTimelineEntryForComplication(complication: CLKComplication, now: Date) -> CLKComplicationTimelineEntry? {
        print("\(#file) \(#function) now = \(now)")
        
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
        default:
            return nil
        } // switch complication.family
    } // func getTimelineEntryForComplication(complication: CLKComplication, now: Date) -> CLKComplicationTimelineEntry?
    
} // class ComplicationController: NSObject, CLKComplicationDataSource
