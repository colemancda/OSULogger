//
//  OSULoggerTests.m
//  OSULoggerTests
//
//  Created by William Dillon on 1/18/11.
//  Copyright 2011 Oregon State University (COAS). All rights reserved.
//

#import "OSULoggerTests.h"
#import "OSULogger.h"

@implementation OSULoggerTests

- (void)setUp {
    [super setUp];
    
	
}

- (void)testOSULogger
{
	// Test initialization of the OSULogger
	OSULogger *logger = [OSULogger sharedLogger];
	STAssertNotNil(logger, @"Logger failed to initialize.");
	
	// 
	
}

- (void)tearDown {

    
    [super tearDown];
}

@end
