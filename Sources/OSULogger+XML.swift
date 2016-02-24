//
//  OSULogger+XML.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation

//
// XML Support Extension
//
public extension OSULogger {

    public var xmlDocument: NSXMLDocument {
        get {
            let root = NSXMLElement(name: "log")
            root.addAttribute(NSXMLNode.attributeWithName("timestamp", stringValue: NSDate().description) as! NSXMLNode)

            // By coping events locally, we can be sure that the array is stable
            for event in events {
                let xmlEvent = NSXMLElement(name: "event", stringValue: event.message)
                xmlEvent.addAttribute(NSXMLNode.attributeWithName("severity",  stringValue: event.severity.description) as! NSXMLNode)
                xmlEvent.addAttribute(NSXMLNode.attributeWithName("timestamp", stringValue: _formatDate(event.date!)) as! NSXMLNode)
                root.addChild(xmlEvent)
            }

            return NSXMLDocument(rootElement: root)
        }
    }

    public class func stringFrom(xmlRep: NSXMLElement) -> String {
        var string = ""

        if let children = xmlRep.children {
            for child in children {
                if let element = child as? NSXMLElement {
                    if  let timestamp = element.attributeForName("timestamp")?.stringValue,
                        let severity  = element.attributeForName("severity")?.stringValue,
                        let message   = element.stringValue {
                            string = string + "\(timestamp): \(severity): \(message)\n"
                    }
                }
            }
        }

        return string
    }

    public convenience init(xmlRep: NSXMLElement) {
        self.init()

        if let children = xmlRep.children {
            for child in children {
                if let element = child as? NSXMLElement {
                    let date = _parseDate(
                        element.attributeForName("timestamp")?.stringValue ?? "")
                    let severity  = Severity.fromString(
                        element.attributeForName("severity")?.stringValue ?? "")
                    let line = Int(element.attributeForName("line")?.stringValue ?? "")
                    let file = element.attributeForName("file")?.stringValue
                    let function = element.attributeForName("function")?.stringValue
                    if let message = element.stringValue {
                        events.append(Event(date: date, severity: severity, message: message, function: function, file: file, line: line))
                    }
                }
            }
        }
    }

}
