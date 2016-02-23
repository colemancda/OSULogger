//
//  OSUConsoleLoggerObserver.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#else
import Glibc
#endif

private let escape  = "\u{001B}["
private let normal  = escape + "m"
private let red     = escape + "31m"
private let green   = escape + "32m"
private let yellow  = escape + "33m"
private let blue    = escape + "34m"
private let magenta = escape + "35m"
private let cyan    = escape + "36m"
private let white   = escape + "37m"

public class OSUConsoleLoggerObserver : OSULoggerObserver {

    let dateFormatter = NSDateFormatter()

    public init() {
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
    }

    public func log(event: OSULogger.Event) {
        let color: String
        let restore: String
        if isatty(fileno(stderr)) != 0 {
            switch event.severity {
            case .Fatal:       color = magenta
            case .Error:       color = red
            case .Warning:     color = yellow
            case .Information: color = green
            case .Debugging:   color = white
            case .Undefined:   color = cyan
            case .Custom(_):   color = blue
            }
            restore = normal
        } else {
            color = ""
            restore = ""
        }
        fputs("\(dateFormatter.stringFromDate(event.date!)), \(color)\(event.severity)\(restore): \(event.message)\n", stderr)
    }
}
