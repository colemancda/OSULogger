//
//  CBridge.swift
//  OSULogger
//
//  Created by Orlando Bassotto on 2016-02-23.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation

class CObserver : OSULoggerObserver {
    typealias Callback = @convention(c) (UnsafeMutablePointer <Void>, UnsafePointer <Void>) -> Void

    struct Event {
        var severity: Int32
        var customSeverityName: UnsafePointer <CChar>
        var timestamp: UInt64
        var function: UnsafePointer <CChar>
        var filename: UnsafePointer <CChar>
        var line: Int32
        var message: UnsafePointer <CChar>
    }

    private let callback: Callback
    private let info: UnsafeMutablePointer <Void>?

    init(_ callback: Callback, _ info: UnsafeMutablePointer <Void>?) {
        self.callback = callback
        self.info = info
    }

    func log(event: OSULogger.Event) {
        var cEvent = Event(severity: 0, customSeverityName: nil, timestamp: 0, function: nil, filename: nil, line: 0, message: nil)

        cEvent.severity = Int32(event.severity.level)

        if let date = event.date {
            cEvent.timestamp = UInt64(date.timeIntervalSince1970 * 1_000_000_000)
        }

        cEvent.line = Int32(event.line ?? 0)

        var customSeverityName = ""
        switch event.severity {
            case .Custom(let name):
                customSeverityName = name
                break
            default:
                break
        }

        let function = event.function ?? ""
        let filename = event.file ?? ""

        event.message.withCString { m in
            function.withCString { fn in
                filename.withCString { fp in
                    customSeverityName.withCString { csn in
                        if !customSeverityName.isEmpty {
                            cEvent.customSeverityName = csn
                        }
                        cEvent.message  = m
                        cEvent.function = function.isEmpty ? nil : fn
                        cEvent.filename = filename.isEmpty ? nil : fp
                        callback(info!, &cEvent)
                    }
                }
            }
        }
    }

    class func create(callback callback: Callback?, info: UnsafeMutablePointer <Void>?) -> CObserver? {
        guard let callback = callback else {
            return nil
        }
        return CObserver(callback, info)
    }
}

@_silgen_name("OSULoggerAddCallback")
func __OSULoggerAddCallback(callback: CObserver.Callback?, info: UnsafeMutablePointer <Void>?) -> Bool {
    if let observer = CObserver.create(callback: callback, info: info) {
        OSULogger.sharedLogger().observers.append(observer)
        return true
    }
    return false
}

@_silgen_name("_OSULog")
func __OSULog(severity: Int, message: UnsafePointer <CChar>, function: UnsafePointer <CChar>,
              filePath: UnsafePointer <CChar>, line: Int) {
    OSULog(OSULogger.Severity.fromLevel(severity),
           message: String.fromCString(message) ?? "(null)",
           function: String.fromCString(function) ?? "",
           filePath: String.fromCString(filePath) ?? "",
           line: line)
}

@_silgen_name("_OSULogCustom")
func __OSULog(severity: UnsafePointer <CChar>, message: UnsafePointer <CChar>,
              function: UnsafePointer <CChar>, filePath: UnsafePointer <CChar>,
              line: Int) {
    let severity = String.fromCString(severity) ?? ""
    OSULog(severity.isEmpty ? OSULogger.Severity.Undefined : OSULogger.Severity.Custom(severity),
           message: String.fromCString(message) ?? "(null)",
           function: String.fromCString(function) ?? "",
           filePath: String.fromCString(filePath) ?? "",
           line: line)
}
