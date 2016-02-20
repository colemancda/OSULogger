//
//  OSULogger_Tests.swift
//  OSULogger Tests
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

@testable import OSULogger
import XCTest
import SwiftyJSON

class OSULogger_Tests: XCTestCase {
    
    var xmlPath:            String! = nil
    var stringPath:         String! = nil
    var xmlContents:        String! = nil
    var strContents:        String! = nil
    var xmlInput:     NSXMLElement! = nil
    var sampleLog:       OSULogger! = nil
    var jsonPath:           String! = nil
    var jsonContents:       NSData! = nil
    var jsonInput:            JSON! = nil
    
    override func setUp() {
        super.setUp()

        if let resourceURL = NSBundle(forClass: OSULogger_Tests.self).resourceURL {
            xmlPath    = NSURL(string: "exampleLog.xml",    relativeToURL: resourceURL)?.path
            jsonPath   = NSURL(string: "exampleLog.json",   relativeToURL: resourceURL)?.path
            stringPath = NSURL(string: "exampleLog.string", relativeToURL: resourceURL)?.path
        }
        
        assert(xmlPath    != nil, "Unable to find exampleXMLLogFile.")
        assert(jsonPath   != nil, "Unable to find exampleJSONLogFile.")
        assert(stringPath != nil, "Unable to find exampleStringLogFile.")

        do {
            xmlContents  = try String(contentsOfFile:  xmlPath)
            xmlInput     = try NSXMLElement(XMLString: xmlContents)
            strContents  = try String(contentsOfFile:  stringPath)
            jsonContents = NSData(contentsOfFile:  jsonPath)
            jsonInput    = JSON(data: jsonContents)
        } catch {
            assert(false, "Unable to load example file for test")
        }
        
        sampleLog = OSULogger(xmlRep: xmlInput)
    }
    
    func testLoggerEquivalence() {
        assert(sampleLog == sampleLog, "Logger doesn't equal itself.")
        assert(sampleLog != OSULogger.sharedLogger(), "Logger not equal doesn't work")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSharedLogger() {
        let sharedLogger = OSULogger.sharedLogger()
        
        
        // Iterate through the sample logs and add some stuff to the shared logger
        for event in sampleLog.events {
            sharedLogger.log(event.message)
            sharedLogger.log(event.message, severity: event.severity)
        }
        
        // Flush the log to make sure that everything has been written
        sharedLogger.flush()
        
        // Make sure the correct number of events was created
        assert(sharedLogger.events.count == sampleLog.events.count * 2,
            "Some log events were missed (\(sharedLogger.events.count) == \(sampleLog.events.count * 2))")
        
        // Iterate through the logs and make sure that everything is in there
        for var i = 0; i < sampleLog.events.count; i++ {
            // Test messages
            assert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 0].message, "Failed to preserve message in logger")
            assert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 1].message, "Failed to preserve message in logger")
            // Test severities
            assert(OSULogger.Severity.Undefined == sharedLogger.events[i * 2 + 0].severity, "Failed to set default severity in logger")
            assert(sampleLog.events[i].severity == sharedLogger.events[i * 2 + 1].severity, "Failed to preserve severity in logger")
        }
    }
    
    func testPerformanceXMLLoad() {
        self.measureBlock {
            _ = OSULogger(xmlRep: self.xmlInput)
        }
    }
    
    func testPerformanceJSONLoad() {
        self.measureBlock {
            _ = OSULogger(jsonRep: self.jsonInput)
        }
    }

    func testPerformanceXMLWrite() {
        self.measureBlock {
            _ = self.sampleLog.document
        }
    }

    func testPerformanceJSONWrite() {
        self.measureBlock {
            _ = self.sampleLog.jsonRep
        }
    }
    
    func testStringFromXML() {
        let stringOutput = OSULogger.stringFrom(xmlInput)

        assert(stringOutput == strContents, "String output mismatch")
    }
    
    func testXMLReadAndWrite() {
        // Try to create a new logger class from the created XML
        var xmlTemp: NSXMLElement! = nil
        do {
            // Create an XML representation of the sample log
            let xmlStringOutput: String! = sampleLog.xmlStringValue()
            assert(xmlStringOutput != nil, "Unable to get XML String output")

            xmlTemp = try NSXMLElement(XMLString: xmlStringOutput)
        } catch {
            assert(false, "NSXMLElement was not able to be made from XMLOutput")
        }
        
        // Try to create the logger
        assert(OSULogger(xmlRep: xmlTemp) == sampleLog, "Log created from intermediate XML does not match original")
    }
    
}
