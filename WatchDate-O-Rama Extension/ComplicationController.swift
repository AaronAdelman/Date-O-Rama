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
    
//    var headerRow = ASARow().newFromSubkey(subkey: .header)
//    var body1Row = ASARow().newFromSubkey(subkey: .body1)
//    var body2Row = ASARow().newFromSubkey(subkey: .body2)
    
    lazy var modularLargeRows = ASAUserData.rowArray(key: ASARowArrayKey.modularLarge)
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        print("\(#file) \(#function)")
        
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        print("\(#file) \(#function)")
        
        handler(Date.distantPast)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        print("\(#file) \(#function)")
        
        handler(Date.distantFuture)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        print("\(#file) \(#function)")
        
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        print("\(#file) \(#function)")
        
        let myDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        myDelegate.complicationController = self
        self.complication = complication
        
        // Call the handler with the current timeline entry
        
//        headerRow = ASARow().newFromSubkey(subkey: .header)
//        body1Row = ASARow().newFromSubkey(subkey: .body1)
//        body2Row = ASARow().newFromSubkey(subkey: .body2)
        
//        if headerRow == nil {
////            myDelegate.requestComplicationData()
//            handler(nil)
//            return
//        }
        
        let now = Calendar.current.startOfDay(for: Date()) // Midnight.  Will need to rethink this for support of calendars which start the day at Sunset or other times other than midnight.
        print("• \(#file) \(#function) now = \(now)")
        let entry = self.getTimelineEntryForComplication(complication: complication, now:  now
        )
        
        //        handler(nil)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        print("\(#file) \(#function) before \(date), limit = \(limit)")
        
        var entries: [CLKComplicationTimelineEntry]? = []
        var when = date
        for _ in 1...limit {
            when = when - (60 * 60 * 24)
            entries = [self.getTimelineEntryForComplication(complication: complication, now: when)!] + entries!
        } // for i
        
// Call the handler with the timeline entries prior to the given date
//        handler(nil)
        handler(entries)
    } // func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
    
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
        switch complication.family
        {
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
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "SimpleWC")
            template.line2TextProvider = CLKSimpleTextProvider(text: "Random")
//            let image: UIImage = UIImage(named: "Modular")!
//            let template = CLKComplicationTemplateModularSmallSimpleImage()
//            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
        case .modularLarge:
            let now = Date()
            
            let headerRow = self.modularLargeRows[0]
            let body1Row  = self.modularLargeRows[1]
            let body2Row  = self.modularLargeRows[2]
            
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
            handler(template)
        default:
            handler(nil)
        }
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.always)
    }
    
    // MARK:  -
    
    func getTimelineEntryForComplication(complication: CLKComplication, now: Date
//        , withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)
        )
        -> CLKComplicationTimelineEntry?
    {
        // NOTE: A bunch of stuff in this method may need to be relocated to the extension delegate.

        print("\(#file) \(#function) now = \(now)")
            

        // Calendrical calculations
        
        print("\(#file) \(#function) Modular large rows = \(self.modularLargeRows)")

        let headerRow = self.modularLargeRows[0]
        let body1Row  = self.modularLargeRows[1]
        let body2Row  = self.modularLargeRows[2]
 
        let headerString = headerRow.dateString(now: now)
        
        // Body 1 date
        let body1String = body1Row.dateString(now: now)
        
        // Body 2 date
        let body2String = body2Row.dateString(now: now)

        // Get the complication data from the extension delegate.
//        let myDelegate = WKExtension.shared().delegate as! ExtensionDelegate
//        var data : Dictionary = myDelegate.myComplicationData[ComplicationCurrentEntry]!
        
        var entry : CLKComplicationTimelineEntry?
        
        // Create the template and timeline entry.
        if complication.family == .modularLarge {
            let textTemplate = CLKComplicationTemplateModularLargeStandardBody()
            textTemplate.headerTextProvider = CLKSimpleTextProvider(text: headerString)
//            textTemplate.headerTextProvider.tintColor = ASAConfiguration().color(row: .header)
            textTemplate.body1TextProvider = CLKSimpleTextProvider(text: body1String)
            textTemplate.body2TextProvider = CLKSimpleTextProvider(text: body2String)

            // Create the entry.
            entry = CLKComplicationTimelineEntry(date: now as Date, complicationTemplate: textTemplate)
        }
        else {
            // ...configure entries for other complication families.
        }
        
        // Pass the timeline entry back to ClockKit.
//        handler(entry)
        return entry
    }

} // class ComplicationController: NSObject, CLKComplicationDataSource
