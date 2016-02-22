//
//  OSULogger.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

#if os(OSX) || os(iOS)
import Cocoa
#else
import Foundation
#endif

let escape  = "\u{001B}["
let normal  = escape + "m"
let red     = escape + "31m"
let green   = escape + "32m"
let yellow  = escape + "33m"
let blue    = escape + "34m"
let magenta = escape + "35m"
let cyan    = escape + "36m"
let white   = escape + "37m"

public class OSULogger : NSObject {

    internal static let _sharedLogger = OSULogger()

    public enum Severity : Int, CustomStringConvertible {
        case Fatal       = 5
        case Error       = 4
        case Warning     = 3
        case Information = 2
        case Debugging   = 1
        case Undefined   = 0

        public var description: String {
            switch self {
            case .Fatal:       return "Fatal"
            case .Error:       return "Error"
            case .Warning:     return "Warning"
            case .Information: return "Information"
            case .Debugging:   return "Debugging"
            case .Undefined:   return "Undefined"
            }
        }

        static func fromString(string: String?) -> Severity {
            guard let string = string else {
                return .Undefined
            }
            switch string {
            case Severity.Debugging.description:
                return .Debugging
            case Severity.Fatal.description:
                return .Fatal
            case Severity.Error.description:
                return .Error
            case Severity.Warning.description:
                return .Warning
            case Severity.Information.description:
                return .Information
            default:
                return .Undefined
            }
        }
    }

    public struct Event {
        let date: NSDate?
        let severity: Severity
        let message: String
        let function: String?
        let file: String?
        let line: Int?
    }

#if OSULOGGER_ASYNC_SUPPORT
    private let dispatchQueue: dispatch_queue_t
#endif

    var events = [Event]()

    let dateFormatter = NSDateFormatter()
#if os(OSX) || os(iOS)
    public var attributedString = NSMutableAttributedString()
    var fontAttributes = [String: AnyObject]()
    var font: NSFont
#endif

    // This is a place to keep track of how stale a remote log is
    public var updateDate: NSDate? = nil

    public var observers = [OSULoggerObserver]()

    public init(queueLabel: String = "edu.orst.ceoas.osulogger") {
#if OSULOGGER_ASYNC_SUPPORT
        dispatchQueue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL)
#endif

#if os(OSX) || os(iOS)
        dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
#endif
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"

#if os(OSX) || os(iOS)
        if #available(iOS 9.0, OSX 10.11, *) {
            font = NSFont.monospacedDigitSystemFontOfSize(CGFloat(8.0), weight: NSFontWeightRegular)
        } else {
            font = NSFont.systemFontOfSize(8.0)
        }

        fontAttributes[NSFontAttributeName] = font
        fontAttributes[NSForegroundColorAttributeName] = NSColor.blackColor()
#endif

        super.init()
    }

    deinit {
        self.flush()
    }

    internal func _formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }

    internal func _parseDate(string: String) -> NSDate {
        return dateFormatter.dateFromString(string)!
    }

#if os(OSX) || os(iOS)
    @objc public class func sharedLogger() -> OSULogger { return _sharedLogger }
#else
    public class func sharedLogger() -> OSULogger { return _sharedLogger }
#endif

    @objc public func flush() {
#if OSULOGGER_ASYNC_SUPPORT
        // Wait for up to one second for the dispatch queue to process pending logs
        dispatch_sync(dispatchQueue) { () -> Void in
            return
        }
#endif
    }

    public func clearEvents() {
        events.removeAll()
    }

    private func _updateString(event: Event) {
#if os(OSX) || os(iOS)
        var attributes = fontAttributes

        // Set the color of the line based upon the severity
        switch event.severity {
        case .Undefined: break
        case .Information: break
        case .Warning:   attributes[NSForegroundColorAttributeName] = NSColor.orangeColor()
        case .Error:     attributes[NSForegroundColorAttributeName] = NSColor.redColor()
        case .Fatal:     attributes[NSForegroundColorAttributeName] = NSColor.magentaColor()
        case .Debugging: attributes[NSForegroundColorAttributeName] = NSColor.grayColor()
        }

        if let date = event.date {
            attributedString.appendAttributedString(NSAttributedString(
                string: "\(_formatDate(date)): "))
        }

        attributedString.appendAttributedString(NSAttributedString(
            string: "\(event.severity.description.stringByPadding(13, pad: " ")): \(event.message))",
            attributes: attributes))
#endif
    }

    private func noop() { }

#if os(OSX) || os(iOS)
    @objc public func logStringObjc(string: String, severity: Int) {
        var sev = Severity(rawValue: severity)
        if sev == nil { sev = Severity.Undefined }
        self.log(string, severity: sev!)
    }

    @objc(logString:withFile:line:version:andSeverity:)
    public func log(
    string: String,
    file: String = #file,
    line: Int = #line,
    version: String,
    severity: Int) {
            // We only want the source name of the #file macro, so lets only keep
            // the last component of the path
            let pathComponents = file.componentsSeparatedByString("/")
            if let fileName = pathComponents.last {
                let sev: Severity
                if let temp = Severity(rawValue: severity) {
                    sev = temp
                } else {
                    sev = Severity.Undefined
                    self.log(string, severity: sev, function: "", file: fileName, line: line)
                }
            }
    }
#endif

    public func log(string: String, severity: Severity = Severity.Undefined,
                    function: String = #function, file: String = #file,
                    line: Int = #line) {
#if DEBUG
        if severity == .Error || severity == .Fatal {
            noop()
        }
#endif
#if OSULOGGER_ASYNC_SUPPORT
        dispatch_async(dispatchQueue, { self._log(NSDate(), severity: severity, message: string, function: function, file: file, line: line) })
#else
        _log(NSDate(), severity: severity, message: string, function: function, file: file, line: line)
#endif
    }

    // This function should only execute on the main thread.
    private func _log(date: NSDate, severity: Severity, message: String, function: String,
                      file: String, line: Int) {
        // Append a new event to the log array
        let event = Event(date: date, severity: severity, message: message, function: function, file: file, line: line)
        events.append(event)

        // If we have observers, call them on the main thread
        if !observers.isEmpty {
#if OSULOGGER_ASYNC_SUPPORT
            dispatch_async(dispatch_get_main_queue(), {
                for observer in self.observers {
                    observer.log(event)
                }
            })
#else
            for observer in self.observers {
                observer.log(event)
            }
#endif
        }

        // Update the attributed string log
        _updateString(event)

        // When debugging, also print output to the console
        #if DEBUG
            let color: String
            switch severity {
            case .Fatal: color = magenta
            case .Error: color = red
            case .Warning: color = yellow
            case .Information: color = green
            case .Debugging: color = white
            case .Undefined: color = blue
            }
            print("\(_formatDate(date)), \(color)\(severity)\(normal): \(message)")
        #endif
    }
}

public func == (lhs: OSULogger.Event, rhs: OSULogger.Event) -> Bool {
    if lhs.severity != rhs.severity {
        #if DEBUG
            print("Logs don't match because severities don't match (\(lhs.severity) != \(rhs.severity))")
        #endif
        return false
    }

    if lhs.date != rhs.date {
        #if DEBUG
            print("Logs don't match because dates don't match (\(lhs.date) != \(rhs.date))")
        #endif
        return false
    }

    if lhs.message != rhs.message {
        #if DEBUG
            print("Logs don't match because messages don't match (\(lhs.message) != \(rhs.message))")
        #endif
        return false
    }

    return true
}

public func != (lhs: OSULogger.Event, rhs: OSULogger.Event) -> Bool {
    return !(lhs == rhs)
}

public func == (lhs: OSULogger, rhs: OSULogger) -> Bool {
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
    for i in 0 ..< lhs.events.count {
        if lhs.events[i] != rhs.events[i] {
            #if DEBUG
                print("Logs don't match because event \(i) don't match")
            #endif

            return false
        }
    }

    return true
}
