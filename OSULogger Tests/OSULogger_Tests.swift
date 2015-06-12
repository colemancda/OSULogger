//
//  OSULogger_Tests.swift
//  OSULogger Tests
//
//  Created by William Dillon on 6/10/15.
//  Copyright © 2015 Oregon State University (COAS). All rights reserved.
//

import XCTest

class OSULogger_Tests: XCTestCase {
    
    var xmlPath:     String! = nil
    var stringPath:  String! = nil
    var xmlContents: String! = nil
    var strContents: String! = nil
    var xmlInput:    NSXMLElement! = nil
    var sampleLog:   OSULogger! = nil
    
    override func setUp() {
        super.setUp()

        if let resourceURL = NSBundle(forClass: OSULogger_Tests.self).resourceURL {
            xmlPath = NSURL(string: "exampleLog.xml", relativeToURL: resourceURL)?.path
        }
        
        assert(xmlPath != nil, "Unable to find exampleXMLLogFile.")

        do {
            xmlContents = try String(contentsOfFile: xmlPath!)
        } catch {
            assert(false, "Unable to load example XML file")
        }
        
        do {
            xmlInput = try NSXMLElement(XMLString: xmlContents)
        } catch {
            assert(false, "Unable to create XML from example file")
        }

        if let resourceURL = NSBundle(forClass: OSULogger_Tests.self).resourceURL {
            stringPath = NSURL(string: "exampleLog.string", relativeToURL: resourceURL)?.path
        }
        
        assert(stringPath != nil, "Unable to find exampleStringLogFile.")

        do {
            strContents = try String(contentsOfFile: stringPath!)
        } catch {
            assert(false, "Unable to load example string log file")
        }

        sampleLog = OSULogger(xmlRep: xmlInput)
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
        assert(sharedLogger.events.count == sampleLog.events.count * 2 + 1,
            "Some log events were missed (\(sharedLogger.events.count) == \(sampleLog.events.count * 2 + 1))")
        
        // Iterate through the logs and make sure that everything is in there
        for var i = 0; i < sampleLog.events.count; i++ {
            // Test messages
            assert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 0 + 1].message, "Failed to preserve message in logger")
            assert(sampleLog.events[i].message  == sharedLogger.events[i * 2 + 1 + 1].message, "Failed to preserve message in logger")
            // Test severities
            assert(OSULogger.Severity.Undefined == sharedLogger.events[i * 2 + 0 + 1].severity, "Failed to set default severity in logger")
            assert(sampleLog.events[i].severity == sharedLogger.events[i * 2 + 1 + 1].severity, "Failed to preserve severity in logger")
        }
    }
    
    func testPerformanceXMLLoad() {
        self.measureBlock() {
            _ = OSULogger(xmlRep: self.xmlInput)
        }
    }

    func testPerformanceXMLWrite() {
        self.measureBlock() {
            _ = self.sampleLog.document
        }
    }
    
    func testStringFromXML() {
        let stringOutput = OSULogger.stringFrom(xmlInput)

        assert(stringOutput == strContents, "String output mismatch")
    }

    func testXMLReadAndWrite() {
        // Create an XML representation of the sample log
        let xmlStringOutput: String! = sampleLog.xmlStringValue()
        assert(xmlStringOutput != nil, "Unable to get XML String output")
        
        // Try to create a new logger class from the created XML
        var xmlTemp: NSXMLElement! = nil
        do {
            xmlTemp = try NSXMLElement(XMLString: xmlStringOutput)
        } catch {
            assert(false, "NSXMLElement was not able to be made from XMLOutput")
        }
        
        // Try to create the logger
        _ = OSULogger(xmlRep: xmlTemp)
    }
}
