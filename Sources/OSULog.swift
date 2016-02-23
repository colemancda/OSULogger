//
//  OSULogger+Functions.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

public func OSULog(string: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    OSULog(.Undefined, string: string, function: function, filePath: filePath, line: line)
}

public func OSULog(severity: OSULogger.Severity, string: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    let pathComponents = filePath.componentsSeparatedByString("/")
    if let fileName = pathComponents.last {
        OSULogger.sharedLogger().log(string, severity: severity, function: function, file: fileName, line: line)
    }
}

@_silgen_name("_OSULog")
public func OSULogYouShouldNeverCallMeInSwiftButOnlyInC(severity: Int, string: UnsafePointer <Int8>,
                                                        function: UnsafePointer <Int8>,
                                                        filePath: UnsafePointer <Int8>, line: Int) {
    OSULog(OSULogger.Severity.fromLevel(severity), string: String.fromCString(string)!,
           function: String.fromCString(function)!, filePath: String.fromCString(filePath)!,
           line: line)
}
