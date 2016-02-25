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
            ("testSeverityComparable", testSeverityComparable),
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

    var strContents:        String? = nil
    var xmlDocument: NSXMLDocument? = nil
    var jsonInput:            JSON? = nil
    var sampleLog:       OSULogger? = nil

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    override func setUp() {
        doSetUp();
    }
#else
    func setUp() {
        doSetUp();
    }
#endif

    func loadExamplesRelativeTo(URL: NSURL) -> Bool {
        let xmlURL    = NSURL(string: "exampleLog.xml",    relativeToURL: URL)
        let stringURL = NSURL(string: "exampleLog.string", relativeToURL: URL)
        let jsonURL   = NSURL(string: "exampleLog.json",   relativeToURL: URL)

        assert(xmlURL != nil && stringURL != nil && jsonURL != nil,
            "Unable to create resource URLs.") 

        xmlDocument = try? NSXMLDocument(contentsOfURL: xmlURL!, options: 0)
        guard xmlDocument != nil else {
            return false
        }

        strContents = try? String(contentsOfURL: stringURL!, encoding: NSUTF8StringEncoding)
        guard strContents != nil else {
            return false
        }

        jsonInput = try? JSON.decode(try String(contentsOfURL: jsonURL!, encoding: NSUTF8StringEncoding))
        guard jsonInput != nil else {
            return false
        }

        return true
    }
 
    func doSetUp() {

        // First try to load the files assuming that OSULogger is the base package
        // Then try to load the files assuming that we're subordinate
        // If that fails, we're hosed.
        if loadExamplesRelativeTo(NSURL(fileURLWithPath: "./Packages/OSULogger-1.0.0/Tests/OSULogger/")) == false {
            guard loadExamplesRelativeTo(NSURL(fileURLWithPath: "./Tests/OSULogger/")) != false else {
// FIXME: Do we really need to specify the contents of the version tag here??
                assert(false, "Unable to load example files for test")
                return
            }
        }

        XCTAssert(xmlDocument != nil)
        sampleLog = OSULogger(xmlRep: xmlDocument!.rootElement()!)
    }

    func testSeverityComparable() {
        XCTAssert(OSULogger.Severity.Undefined == OSULogger.Severity.Undefined, "Undefined does not compare for equality.")
        XCTAssert(OSULogger.Severity.Debugging == OSULogger.Severity.Debugging, "Debugging does not compare for equality.")
        XCTAssert(OSULogger.Severity.Information == OSULogger.Severity.Information, "Information does not compare for equality.")
        XCTAssert(OSULogger.Severity.Warning == OSULogger.Severity.Warning, "Warning does not compare for equality.")
        XCTAssert(OSULogger.Severity.Error == OSULogger.Severity.Error, "Error does not compare for equality.")
        XCTAssert(OSULogger.Severity.Fatal == OSULogger.Severity.Fatal, "Fatal does not compare for equality.")
        XCTAssert(OSULogger.Severity.Custom("Test") == OSULogger.Severity.Custom("Test"), "Custom(\"Test\") does not compare for equality.")
        XCTAssert(OSULogger.Severity.Undefined != OSULogger.Severity.Information, "Undefined and Information do not compare for inequality.")
        XCTAssert(OSULogger.Severity.Custom("ABC") != OSULogger.Severity.Custom("DEF"), "Custom(\"ABC\") and Custom(\"DEF\") do not compare for inequality.")
        XCTAssert(OSULogger.Severity.Undefined < OSULogger.Severity.Information, "Undefined is not less-than Information")
        XCTAssert(OSULogger.Severity.Debugging <= OSULogger.Severity.Information, "Debugging is not less-than-or-equal-to Information")
        XCTAssert(OSULogger.Severity.Fatal > OSULogger.Severity.Information, "Fatal is not greater-than Information")
        XCTAssert(OSULogger.Severity.Error >= OSULogger.Severity.Warning, "Error is not greater-than-or-equal-to Warning")
        XCTAssert(OSULogger.Severity.Custom("ABC") > OSULogger.Severity.Information, "Custom(\"ABC\") is not greater-than Information")
    }

    func testLoggerEquivalence() {
        XCTAssert(sampleLog != nil, "SampleLog was not initialized for this test.")
        XCTAssert(sampleLog! == sampleLog!, "Logger doesn't equal itself.")
        XCTAssert(sampleLog! != OSULogger.sharedLogger(), "Logger not equal doesn't work")
    }

    func testSharedLogger() {
        XCTAssert(sampleLog != nil, "SampleLog was not initialized for this test.")
        XCTAssert(xmlDocument != nil, "xmlDocument was not initialized for this test.")
        let sharedLogger = OSULogger.sharedLogger()

        sharedLogger.clearEvents()

        // Iterate through the sample logs and add some stuff to the shared logger
        for event in sampleLog!.events {
            sharedLogger.log(event.message)
            sharedLogger.log(event.message, severity: event.severity)
        }

        // Flush the log to make sure that everything has been written
        sharedLogger.flush()

        // Make sure the correct number of events was created
        XCTAssert(sharedLogger.events.count == sampleLog!.events.count * 2,
            "Some log events were missed (\(sharedLogger.events.count) == \(sampleLog!.events.count * 2))")

        // Iterate through the logs and make sure that everything is in there
        for  i in 0 ..< sampleLog!.events.count {
            // Test messages
            XCTAssert(sampleLog!.events[i].message  == sharedLogger.events[i * 2 + 0].message, "Failed to preserve message in logger")
            XCTAssert(sampleLog!.events[i].message  == sharedLogger.events[i * 2 + 1].message, "Failed to preserve message in logger")
            // Test severities
            XCTAssert(OSULogger.Severity.Undefined == sharedLogger.events[i * 2 + 0].severity, "Failed to set default severity in logger")
            XCTAssert(sampleLog!.events[i].severity == sharedLogger.events[i * 2 + 1].severity, "Failed to preserve severity in logger")
        }
    }

    func testPerformanceXMLLoad() {
        XCTAssert(xmlDocument != nil, "xmlDocument was not initialized for this test.")
        _ = OSULogger(xmlRep: xmlDocument!.rootElement()!)
    }

    func testPerformanceJSONLoad() {
        XCTAssert(jsonInput != nil, "jsonInput was not initialized for this test.")
        _ = OSULogger(jsonRep: jsonInput!)
    }

    func testPerformanceXMLWrite() {
        XCTAssert(sampleLog != nil, "SampleLog was not initialized for this test.")
        _ = sampleLog!.xmlDocument
    }

    func testPerformanceJSONWrite() {
        XCTAssert(sampleLog != nil, "SampleLog was not initialized for this test.")
        _ = sampleLog!.jsonRep
    }

    func testStringFromXML() {
        XCTAssert(xmlDocument != nil, "xmlDocument was not initialized for this test.")
        XCTAssert(strContents != nil, "strContents was not initialized for this test.")

        let stringOutput = OSULogger.stringFrom(xmlDocument!.rootElement()!)

        XCTAssert(stringOutput == strContents, "String output mismatch")
    }

    func testXMLReadAndWrite() {
        XCTAssert(sampleLog != nil, "SampleLog was not initialized for this test.")

        // Try to create a new logger class from the created XML
        do {
            // Create an XML representation of the sample log
            let xmlStringOutput: String! = sampleLog!.xmlDocument.XMLString
            XCTAssert(xmlStringOutput != nil, "Unable to get XML String output")

            let xmlTemp = try NSXMLDocument(XMLString: xmlStringOutput!, options: 0)

            // Try to create the logger
            //print("SampleLog: \(sampleLog!.xmlDocument)")
            //print("Logger: \(OSULogger(xmlRep: xmlTemp.rootElement()!).xmlDocument)")
            XCTAssert( OSULogger(xmlRep: xmlTemp.rootElement()!) == sampleLog!, "Log created from intermediate XML does not match original.")

        } catch {
            XCTAssert(false, "NSXMLElement was not able to be made from XMLOutput")
        }
    }
}
