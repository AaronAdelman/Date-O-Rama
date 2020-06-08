//
//  ComplicationController.swift
//  DoubleDate WatchKit Extension
//
//  Created by אהרן שלמה אדלמן on 2017-11-14.
//  Copyright © 2017 Adelsoft. All rights reserved.
//

import ClockKit
import WatchKit

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
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("\(#file) \(#function) after \(date), limit = \(limit)")
        
        var entries: [CLKComplicationTimelineEntry]? = []
        var when = date
        for _ in 1...limit {
            when = when + (60 * 60 * 24)
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
            //            let image: UIImage = UIImage(named: "Circular")!
            //            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            //            template.imageProvider = CLKImageProvider(onePieceImage: image)
            //            handler(template)
            handler(nil)
        case .utilitarianSmall:
            //            let image: UIImage = UIImage(named: "Utilitarian")!
            //            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            //            template.imageProvider = CLKImageProvider(onePieceImage: image)
            //            handler(template)
            handler(nil)
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
    
    func getTimelineEntryForComplication(complication: CLKComplication, now: Date) -> CLKComplicationTimelineEntry? {
        print("\(#file) \(#function) now = \(now)")
        
        switch complication.family {
        case .circularSmall:
            //            let image: UIImage = UIImage(named: "Circular")!
            //            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            //            template.imageProvider = CLKImageProvider(onePieceImage: image)
            //            handler(template)
            return nil
        case .utilitarianSmall:
            //            let image: UIImage = UIImage(named: "Utilitarian")!
            //            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            //            template.imageProvider = CLKImageProvider(onePieceImage: image)
            //            handler(template)
            return nil
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
