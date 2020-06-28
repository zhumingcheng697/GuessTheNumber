//
//  ComplicationController.swift
//  GuessTheNumber WatchKit Extension
//
//  Created by McCoy Zhu on 5/10/20.
//  Copyright © 2020 McCoy Zhu. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        switch complication.family {
        case .circularSmall:
            let tmpl = CLKComplicationTemplateCircularSmallSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            handler(tmpl)
            
        case .extraLarge:
            let tmpl = CLKComplicationTemplateExtraLargeSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Extra Large")!)
            handler(tmpl)
            
        case .graphicBezel:
            let circularTmpl = CLKComplicationTemplateGraphicCircularImage()
            circularTmpl.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!, tintedImageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Graphic Bezel")!))
            let tmpl = CLKComplicationTemplateGraphicBezelCircularText()
            tmpl.circularTemplate = circularTmpl
            tmpl.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("Guess The Number", comment: ""), shortText:  NSLocalizedString("Guess", comment: ""))
            handler(tmpl)
            
        case .graphicCircular:
            let tmpl = CLKComplicationTemplateGraphicCircularImage()
            tmpl.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!, tintedImageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Graphic Circular")!))
            handler(tmpl)
            
        case .graphicCorner:
            let tmpl = CLKComplicationTemplateGraphicCornerTextImage()
            tmpl.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!, tintedImageProvider: CLKImageProvider(onePieceImage: UIImage(named: "Complication/Graphic Corner")!))
            tmpl.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("Guess The Number", comment: ""), shortText:  NSLocalizedString("Guess", comment: ""))
            handler(tmpl)
            
        case .modularSmall:
            let tmpl = CLKComplicationTemplateModularSmallSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            handler(tmpl)
            
        case .utilitarianSmall:
            let tmpl = CLKComplicationTemplateUtilitarianSmallSquare()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            handler(tmpl)
            
        case .utilitarianSmallFlat:
            let tmpl = CLKComplicationTemplateUtilitarianSmallFlat()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Utilitatian Flat")!)
            tmpl.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("Guess The Number", comment: ""), shortText:  NSLocalizedString("Guess", comment: ""))
            handler(tmpl)
            
        case .utilitarianLarge:
            let tmpl = CLKComplicationTemplateUtilitarianLargeFlat()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Utilitatian Flat")!)
            tmpl.textProvider = CLKSimpleTextProvider(text: NSLocalizedString("Guess The Number", comment: ""), shortText:  NSLocalizedString("Guess", comment: ""))
            handler(tmpl)
            
        default:
            handler(nil)
        }
    }
    
}
