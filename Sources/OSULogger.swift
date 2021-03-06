//
//  OSULogger.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation

public class OSULogger : NSObject {

    internal static let _sharedLogger = OSULogger()

    public enum Severity : CustomStringConvertible {
        case Undefined
        case Debugging
        case Information
        case Warning
        case Error
        case Fatal
        case Custom(String)

        public var description: String {
            switch self {
            case .Fatal:             return "Fatal"
            case .Error:             return "Error"
            case .Warning:           return "Warning"
            case .Information:       return "Information"
            case .Debugging:         return "Debugging"
            case .Undefined:         return "Undefined"
            case .Custom(let label): return label
            }
        }

        static func from(string: String?) -> Severity {
            guard let string = string else {
                return .Undefined
            }
            let trimmedString = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if trimmedString.isEmpty {
                return .Undefined
            }
            switch trimmedString {
            case Severity.Debugging.description:   return .Debugging
            case Severity.Fatal.description:       return .Fatal
            case Severity.Error.description:       return .Error
            case Severity.Warning.description:     return .Warning
            case Severity.Information.description: return .Information
            case Severity.Undefined.description:   return .Undefined
            default:                               return .Custom(trimmedString)
            }
        }

        public var level: Int {
            switch self {
            case .Undefined:   return -1
            case .Debugging:   return 0
            case .Information: return 1
            case .Warning:     return 2
            case .Error:       return 3
            case .Fatal:       return 4
            case .Custom(_):   return 5
            }
        }

        static func from(level: Int) -> Severity {
            switch level {
            case Severity.Debugging.level:   return .Debugging
            case Severity.Fatal.level:       return .Fatal
            case Severity.Error.level:       return .Error
            case Severity.Warning.level:     return .Warning
            case Severity.Information.level: return .Information
            default:                         return .Undefined
            }
        }
    }

    public struct Event {
        let date: Date?
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

    let oldDateFormatter = DateFormatter()
    let iso8601DateFormatter = DateFormatter()

    // This is a place to keep track of how stale a remote log is
    public var updateDate: Date? = nil

    public var observers = [OSULoggerObserver]()

    public init(queueLabel: String = "edu.orst.ceoas.osulogger") {

#if DEBUG
        // When debugging, also print output to the console
        observers.append(OSUConsoleLoggerObserver())
#endif

#if OSULOGGER_ASYNC_SUPPORT
        dispatchQueue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL)
#endif

        oldDateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        iso8601DateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"
        iso8601DateFormatter.timeZone = TimeZone(abbreviation: "UTC")!

        super.init()
    }

    deinit {
        flush()
    }

    internal func _formatDate(_ date: Date, useISO8601Format: Bool = true) -> String {
        if useISO8601Format {
            return iso8601DateFormatter.string(from: date)
        } else {
            return oldDateFormatter.string(from: date)
        }
    }

    internal func _parseDate(string: String) -> Date {
        if let date = iso8601DateFormatter.date(from: string) {
            return date
        }
        if let date = oldDateFormatter.date(from: string) {
            return date
        }
        return Date.distantPast
    }

    public class func sharedLogger() -> OSULogger { return _sharedLogger }

    public func flush() {
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

    private func noop() { }

    public func log(_ message: String, severity: Severity = Severity.Undefined,
                    function: String = #function, file: String = #file,
                    line: Int = #line) {
#if DEBUG
        if severity == .Error || severity == .Fatal {
            noop()
        }
#endif
#if OSULOGGER_ASYNC_SUPPORT
        dispatch_async(dispatchQueue, { self._log(Date(), severity: severity, message: message, function: function, file: file, line: line) })
#else
        _log(date: Date(), severity: severity, message: message, function: function, file: file, line: line)
#endif
    }

    // This function should only execute on the main thread.
    private func _log(date: Date, severity: Severity, message: String, function: String,
                      file: String, line: Int) {
        // Append a new event to the log array
        let event = Event(date: date, severity: severity, message: message, function: function, file: file, line: line)
        events.append(event)

        // If we have observers, call them on the main thread
        if !observers.isEmpty {
            for observer in self.observers {
#if OSULOGGER_ASYNC_SUPPORT
                dispatch_async(dispatch_get_main_queue(), { observer.log(event) })
#else
                observer.log(event: event)
#endif
            }
        }
    }
}

extension OSULogger.Severity : Comparable { }

public func < (lhs: OSULogger.Severity, rhs: OSULogger.Severity) -> Bool {
    return lhs.level < rhs.level
}

public func == (lhs: OSULogger.Severity, rhs: OSULogger.Severity) -> Bool {
    switch (lhs, rhs) {
    case (.Undefined, .Undefined):
        fallthrough
    case (.Debugging, .Debugging):
        fallthrough
    case (.Information, .Information):
        fallthrough
    case (.Warning, .Warning):
        fallthrough
    case (.Error, .Error):
        fallthrough
    case (.Fatal, .Fatal):
        return true

    case (.Custom(let label1), .Custom(let label2)):
        return label1 == label2

    default:
        return false
    }
}

extension OSULogger.Event : Equatable { }

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
