//
//  OSULogger+Functions.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

public func OSULoggerLog(string: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    OSULoggerLog(.Undefined, string: string, function: function, filePath: filePath, line: line)
}

public func OSULoggerLog(severity: OSULogger.Severity, string: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    let pathComponents = filePath.componentsSeparatedByString("/")
    if let fileName = pathComponents.last {
        OSULogger.sharedLogger().log(string, severity: severity, function: function, file: fileName, line: line)
    }
}
