//
//  OSULogger.swift
//  OSULogger
//
//  Created by William Dillon on 6/10/15.
//  Copyright © 2015 Oregon State University (COAS). All rights reserved.
//


import Cocoa

func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

func != (lhs: NSDate, rhs: NSDate) -> Bool {
    return !(lhs == rhs)
}

func == (lhs: OSULogger.Event, rhs: OSULogger.Event) -> Bool {
    if lhs.severity != rhs.severity {
        #if DEBUG
            print("Logs don't match because severities don't match (\(lhs.severity) != \(rhs.severity))")
        #endif
        return false
    }
    
    if lhs.date     != rhs.date     {
        #if DEBUG
            print("Logs don't match because dates don't match (\(lhs.date) != \(rhs.date))")
        #endif
        return false
    }
    
    if lhs.message  != rhs.message  {
        #if DEBUG
            print("Logs don't match because messages don't match (\(lhs.message) != \(rhs.message))")
        #endif
        return false
    }
    
    return true
}

func != (lhs: OSULogger.Event, rhs: OSULogger.Event) -> Bool {
    return !(lhs == rhs)
}

func == (lhs: OSULogger, rhs: OSULogger) -> Bool {
    // First, flush the logs
    lhs.flush()
    rhs.flush()
    
    // Next, make sure that the message counts are equal
    if lhs.events.count != rhs.events.count {
        #if DEBUG
            print("Logs don't match because counts don't match (\(lhs.events.count) != \(rhs.events.count))")
        #endif

        return false
    }
    
    // Finally, iterate through the list of events and ensure that they're equal
    for var i = 0; i < lhs.events.count; i++ {
        if lhs.events[i] != rhs.events[i] {
            #if DEBUG
                print("Logs don't match because event \(i) don't match")
            #endif

            return false
        }
    }
    
    return true
}

let _sharedLogger = OSULogger()

public class OSULogger: NSObject {
    public enum Severity: Int {
        case Failure     = 4
        case Warning     = 3
        case Information = 2
        case Debugging   = 1
        case Undefined   = 0
        
        func justifiedString() -> String {
            switch self {
            case .Failure:     return "Failure    "
            case .Warning:     return "Warning    "
            case .Information: return "Information"
            case .Debugging:   return "Debugging  "
            case .Undefined:   return "Undefined  "
            }
        }

        func string() -> String {
            switch self {
            case .Failure:     return "Failure"
            case .Warning:     return "Warning"
            case .Information: return "Information"
            case .Debugging:   return "Debugging"
            case .Undefined:   return "Undefined"
            }
        }

        static func stringValue(string: String) -> Severity {
            switch string {
            case Severity.Debugging.string(),   Severity.Debugging.justifiedString():   return Severity.Debugging
            case Severity.Failure.string(),     Severity.Failure.justifiedString():     return Severity.Failure
            case Severity.Warning.string(),     Severity.Warning.justifiedString():     return Severity.Warning
            case Severity.Information.string(), Severity.Information.justifiedString(): return Severity.Information
            default: return Severity.Undefined
            }
        }
    }
    
    public struct Event {
        let date: NSDate
        let severity: Severity
        let message: String
    }
    
    let dispatchQueue: dispatch_queue_t
    
    var events = [Event]()
    
    let dateFormatter = NSDateFormatter()
    var attributedString = NSMutableAttributedString()
    var fontAttributes = [String: AnyObject]()
    var font: NSFont
    
    var callback: ((Event) -> Void)? = nil
    
    var document: NSXMLDocument {
        get {
            let root = NSXMLElement(name: "log")
            root.addAttribute(NSXMLNode.attributeWithName("timestamp", stringValue: NSDate.description()) as! NSXMLNode)
            
            // By coping events locally, we can be sure that the array is stable
            for event in events {
                let xmlEvent = NSXMLElement(name: "event", stringValue: event.message)
                xmlEvent.addAttribute(NSXMLNode.attributeWithName("severity",  stringValue: event.severity.string()) as! NSXMLNode)
                xmlEvent.addAttribute(NSXMLNode.attributeWithName("timestamp", stringValue: dateFormatter.stringFromDate(event.date)) as! NSXMLNode)
                root.addChild(xmlEvent)
            }
            
            let document = NSXMLDocument(rootElement: root)
            document.characterEncoding = "UTF-8"

            return document
        }
    }
    
    class func stringFrom(xmlRep: NSXMLElement) -> String {
        var string = ""
        
        if let children = xmlRep.children as? [NSXMLElement] {
            for element in children {
                if  let timestamp = element.attributeForName("timestamp")?.stringValue,
                    let severity  = element.attributeForName("severity")?.stringValue,
                    let message   = element.stringValue {
                    string = string + "\(timestamp): \(severity): \(message)\n"
                }
            }
        }
        
        return string
    }
    
    convenience init(xmlRep: NSXMLElement) {
        self.init()
        
        if let children = xmlRep.children as? [NSXMLElement] {
            for element in children {
                if let timeElement = element.attributeForName("timestamp"),
                   let sevElement  = element.attributeForName("severity"),
                   let message = element.stringValue {
                    if let timeString = timeElement.stringValue,
                       let sevString  =  sevElement.stringValue {
                        if let date = dateFormatter.dateFromString(timeString) {
                            _log(date, severity: Severity.stringValue(sevString), string: message)
                        }
                    }
                }
            }
        }
    }
    
    override init() {
        if #available(iOS 9.0, OSX 10.11, *) {
            font = NSFont.monospacedDigitSystemFontOfSize(CGFloat(8.0), weight: NSFontWeightRegular)
        } else {
            font = NSFont.systemFontOfSize(8.0)
        }

        dispatchQueue = dispatch_queue_create("edu.orst.ceoas.osulogger", DISPATCH_QUEUE_SERIAL)
        
        super.init()
        
        dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        
        fontAttributes[NSFontAttributeName] = font
        fontAttributes[NSForegroundColorAttributeName] = NSColor.blackColor()
        
//        self.log("Starting OSULogger.", severity: .Information)
    }

    @objc public class func sharedLogger() -> OSULogger { return _sharedLogger }
 
    @objc public func logStringObjc(string: String, severity: Int) {
        var sev = Severity(rawValue: severity)
        if sev == nil { sev = Severity.Undefined }
        self.log(string, severity: sev!)
    }
    
    @objc(logString:withFile:line:version:andSeverity:)
    public func log(string: String, file: String = __FILE__, line: Int = __LINE__,
        version: String, severity: Int) -> Void {
        // We only want the source name of the __FILE__ macro, so lets only keep
        // the last component of the path
        let pathComponents = file.componentsSeparatedByString("\\/")
        if let fileName = pathComponents.last {
            let sev: Severity
            if let temp = Severity(rawValue: severity) {
                sev = temp
            } else {
                sev = Severity.Undefined
                self.log("\(fileName):\(line):\(version): \(string)", severity: sev)
            }
        }
    }

    @objc public func flush() -> Void {
        // Wait for up to one second for the dispatch queue to process pending logs
        dispatch_sync(dispatchQueue) { () -> Void in
            return
        }
    }
    
    // In the objc. api stringValue was used to get the XML string.
    // In Swift, we're moving away from that.  Alias stringValue in Objc to
    // xmlStringValue in swift.
    @objc(stringValue)
    public func xmlStringValue() -> String? {
        return self.document.XMLString
    }
    
    public func log(string: String, severity: Severity = Severity.Undefined) {
        dispatch_async(dispatchQueue, { self._log(NSDate(), severity: severity, string: string) })
    }
    
    private func _updateString(event: Event) -> Void {
        var attributes = fontAttributes
        
        // Set the color of the line based upon the severity
        switch event.severity {
        case .Undefined: break
        case .Information: break
        case .Warning:   attributes[NSForegroundColorAttributeName] = NSColor.orangeColor()
        case .Failure:   attributes[NSForegroundColorAttributeName] = NSColor.redColor()
        case .Debugging: attributes[NSForegroundColorAttributeName] = NSColor.grayColor()
        }

        attributedString.appendAttributedString(NSAttributedString(
            string: "\(dateFormatter.stringFromDate(event.date)): \(event.severity.justifiedString()): \(event.message))",
            attributes: attributes))
    }
    
    // This function should only execute on the main thread.
    private func _log(date: NSDate, severity: Severity, string: String) -> Void {
        // Append a new event to the log array
        let event = Event(date: date, severity: severity, message: string)
        events.append(event)

        // If a callback exists, call it on the main thread
        if callback != nil { dispatch_async(dispatch_get_main_queue(), { self.callback!(event) })}

        // Update the attributed string log
        _updateString(event)
        
        // When debugging, also print output to the console
        #if DEBUG
            print("\(dateFormatter.stringFromDate(date)), \(severity): \(string)")
        #endif
    }

    deinit {
        self.flush()
    }
}