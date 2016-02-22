//
//  OSULogger+JSON.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

#if OSULOGGER_JSON_SUPPORT
import Foundation
import PMJSON

//
// JSON Support Extension
//
public extension OSULogger {

    public var jsonRep: JSON {
        get {
            var logsDict: [String: JSON] = ["timestamp": JSON.String(_formatDate(NSDate()))]

            var jsonEvents = ContiguousArray<JSON>()
            for event in events {
                var eventDict: [String: JSON] = [
                    "severity":  JSON.String(event.severity.description),
                    "message":   JSON.String(event.message)
                ]

                if let timestamp = event.date {
                    eventDict["timestamp"] = JSON.String(_formatDate(timestamp))
                }

                if let function = event.function {
                    eventDict["function"] = JSON.String(function)
                }

                if let file = event.file {
                    eventDict["file"] = JSON.String(file)
                }

                if let line = event.line {
                    eventDict["line"] = JSON.Int64(Int64(line))
                }

                jsonEvents.append(JSON.Object(JSONObject(eventDict)))
            }

            logsDict["events"] = JSON.Array(jsonEvents)
            return JSON.Object(JSONObject(logsDict))
        }
    }

    public convenience init(jsonRep: JSON) {
        self.init()

        if let timestampString = jsonRep["timestamp"]?.string {
            updateDate = _parseDate(timestampString)
        }

        if let jsonEvents = jsonRep["events"]?.array {
            for jsonEvent in jsonEvents where jsonEvent != nil {
                let severity = Severity.fromString(jsonEvent["severity"]?.string)
                let line     = jsonEvent["line"]?.int64
                let file     = jsonEvent["file"]?.string
                let function = jsonEvent["function"]?.string
                let message  = jsonEvent["message"]?.string
                // Log messages without a time or a message aren't usable.
                if let timestamp = jsonEvent["timestamp"]?.string,
                   let mess = message {
                    let time     = dateFormatter.dateFromString(timestamp) ?? nil
                    events.append(Event(
                        date: time,
                        severity: severity,
                        message: mess,
                        function: function,
                        file: file,
                        line: line
                        ))
                }
            }
        }
    }

}
#endif
