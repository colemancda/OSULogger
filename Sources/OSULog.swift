//
//  OSULogger+Functions.swift
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation

public func OSULog(message: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    OSULog(.Undefined, message: message, function: function, filePath: filePath, line: line)
}

public func OSULog(_ severity: OSULogger.Severity, message: String, function: String = #function, filePath: String = #file, line: Int = #line) {
    let pathComponents = filePath.components(separatedBy: "/")
    if let fileName = pathComponents.last {
        OSULogger.sharedLogger().log(message, severity: severity, function: function, file: fileName, line: line)
    }
}
