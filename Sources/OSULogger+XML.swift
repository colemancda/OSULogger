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

    public var xmlDocument: XMLDocument {
        get {
            let root = XMLElement(name: "log")
            root.addAttribute(XMLNode.attribute(withName: "timestamp", stringValue: Date().description) as! XMLNode)

            // By coping events locally, we can be sure that the array is stable
            for event in events {
                let xmlEvent = XMLElement(name: "event", stringValue: event.message)
                xmlEvent.addAttribute(XMLNode.attribute(withName: "severity",  stringValue: event.severity.description) as! XMLNode)
                xmlEvent.addAttribute(XMLNode.attribute(withName: "timestamp", stringValue: _formatDate(event.date!)) as! XMLNode)
                root.addChild(xmlEvent)
            }

            return XMLDocument(rootElement: root)
        }
    }

    public class func stringFrom(xmlRep: XMLElement) -> String {
        var string = ""

        if let children = xmlRep.children {
            for child in children {
                if let element = child as? XMLElement {
                    if  let timestamp = element.attribute(forName: "timestamp")?.stringValue,
                        let severity  = element.attribute(forName: "severity")?.stringValue,
                        let message   = element.stringValue {
                            string = string + "\(timestamp): \(severity): \(message)\n"
                    }
                }
            }
        }

        return string
    }

    public convenience init(xmlRep: XMLElement) {
        self.init()

        if let children = xmlRep.children {
            for child in children {
                if let element = child as? XMLElement {
                    let date = _parseDate(
                        string: element.attribute(forName: "timestamp")?.stringValue ?? "")
                    let severity  = Severity.from(string:
                        element.attribute(forName: "severity")?.stringValue ?? "")
                    let line = Int(element.attribute(forName: "line")?.stringValue ?? "")
                    let file = element.attribute(forName: "file")?.stringValue
                    let function = element.attribute(forName: "function")?.stringValue
                    if let message = element.stringValue {
                        events.append(Event(date: date, severity: severity, message: message, function: function, file: file, line: line))
                    }
                }
            }
        }
    }

}
