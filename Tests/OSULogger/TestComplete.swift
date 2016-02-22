//
//  TestComplete.swift
//  OSULogger Tests
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import XCTest
import Foundation
import PMJSON
@testable import OSULogger

class OSULogger_TestComplete : XCTestCase {

    var allTests : [(String, () throws -> Void)] {
        return [
            ("testLoggerEquivalence", testLoggerEquivalence),
            ("testSharedLogger", testSharedLogger),
            ("testPerformanceXMLLoad", testPerformanceXMLLoad),
            ("testPerformanceJSONLoad", testPerformanceJSONLoad),
            ("testPerformanceXMLWrite", testPerformanceXMLWrite),
            ("testPerformanceJSONWrite", testPerformanceJSONWrite),
            ("testStringFromXML", testStringFromXML),
            ("testXMLReadAndWrite", testXMLReadAndWrite)
        ]
    }

    var xmlURL:              NSURL! = nil
    var stringURL:           NSURL! = nil
    var strContents:        String! = nil
    var xmlDocument: NSXMLDocument! = nil
    var sampleLog:       OSULogger! = nil
    var jsonURL:             NSURL! = nil
    var jsonInput:            JSON! = nil

#if os(OSX) || os(iOS)
    override func setUp() {
        doSetUp();
    }
#else
    func setUp() {
        doSetUp();
    }
#endif

    func doSetUp() {
        let resourceURL = NSURL(fileURLWithPath: "./Tests/OSULogger/")
        xmlURL    = NSURL(string: "exampleLog.xml",    relativeToURL: resourceURL)
        stringURL = NSURL(string: "exampleLog.string", relativeToURL: resourceURL)
        jsonURL   = NSURL(string: "exampleLog.json",   relativeToURL: resourceURL)
        XCTAssert(xmlURL    != nil, "Unable to find exampleXMLLogFile.")
        XCTAssert(stringURL != nil, "Unable to find exampleStringLogFile.")
        XCTAssert(jsonURL   != nil, "Unable to find exampleJSONLogFile.")

        do {
            xmlDocument  = try NSXMLDocument(contentsOfURL: xmlURL, options: 0)
            strContents  = try String(contentsOfURL: stringURL, encoding: NSUTF8StringEncoding)
            jsonInput    = try JSON.decode(try String(contentsOfURL: jsonURL, encoding: NSUTF8StringEncoding))
        } catch {
            XCTAssert(false, "Unable to load example file for test")
        }

        sampleLog = OSULogger(xmlRep: xmlDocument.rootElement()!)
    }

    func testLoggerEquivalence() {
        XCTAssert(sampleLog == sampleLog, "Logger doesn't equal itself.")
        XCTAssert(sampleLog != OSULogger.sharedLogger(), "Logger not equal doesn't work")
    }

    func testSharedLogger() {
        let sharedLogger = OSULogger.sharedLogger()

        sharedLogger.clearEvents()

        // Iterate through the sample logs and add some stuff to the shared logger
        for event in sampleLog.events {
            sharedLogger.log(event.message)
            sharedLogger.log(event.message, severity: event.severity)
        }

        // Flush the log to make sure that everything has been written
        sharedLogger.flush()

        // Make sure the correct number of events was created
        XCTAssert(sharedLogger.events.count == sampleLog.events.count * 2,
            "Some log events were missed (\(sharedLogger.events.count) == \(sampleLog.events.count * 2))")

        // Iterate through the logs and make sure that everything is in there
        for  i in 0 ..< sampleLog.events.count {
            // Test messages
            XCTAssert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 0].message, "Failed to preserve message in logger")
            XCTAssert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 1].message, "Failed to preserve message in logger")
            // Test severities
            XCTAssert(OSULogger.Severity.Undefined == sharedLogger.events[i * 2 + 0].severity, "Failed to set default severity in logger")
            XCTAssert(sampleLog.events[i].severity == sharedLogger.events[i * 2 + 1].severity, "Failed to preserve severity in logger")
        }
    }

    func testPerformanceXMLLoad() {
        _ = OSULogger(xmlRep: xmlDocument.rootElement()!)
    }

    func testPerformanceJSONLoad() {
        _ = OSULogger(jsonRep: jsonInput)
    }

    func testPerformanceXMLWrite() {
        _ = sampleLog.xmlDocument
    }

    func testPerformanceJSONWrite() {
        _ = sampleLog.jsonRep
        print(JSON.encodeAsString(sampleLog.jsonRep, pretty: true))
    }

    func testStringFromXML() {
        let stringOutput = OSULogger.stringFrom(xmlDocument.rootElement()!)

        XCTAssert(stringOutput == strContents, "String output mismatch")
    }

    func testXMLReadAndWrite() {
        // Try to create a new logger class from the created XML
        var xmlTemp: NSXMLDocument! = nil
        do {
            // Create an XML representation of the sample log
            let xmlStringOutput: String! = sampleLog.xmlDocument.XMLString
            XCTAssert(xmlStringOutput != nil, "Unable to get XML String output")

            xmlTemp = try NSXMLDocument(XMLString: xmlStringOutput!, options: 0)
        } catch {
            XCTAssert(false, "NSXMLElement was not able to be made from XMLOutput")
        }

        // Try to create the logger
        XCTAssert(OSULogger(xmlRep: xmlTemp.rootElement()!) == sampleLog, "Log created from intermediate XML does not match original")
    }

}
