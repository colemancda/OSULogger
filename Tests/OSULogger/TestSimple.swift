//
//  TestSimple.swift
//  OSULogger Tests
//
//  Created by William Dillon on 2015-06-12.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import XCTest
@testable import OSULogger

class OSULogger_TestSimple : XCTestCase {

    var allTests : [(String, () throws -> Void)] {
        return [
            ("testSimple", testSimple)
        ]
    }

    func testSimple() {
        let logger = OSULogger.sharedLogger()
        logger.callback = { (event: OSULogger.Event) -> () in
            XCTAssertEqual(event.message, "Hello world.")
        }
        logger.log("Hello world.", severity: .Information)
    }

}

