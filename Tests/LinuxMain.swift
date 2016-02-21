//
//  LinuxMain.swift
//  OSULogger Tests
//
//  Created by Orlando Bassotto on 2016-02-21.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import XCTest

@testable import OSULoggertest

XCTMain([
    OSULogger_TestComplete(),
    OSULogger_TestSimple(),
])
