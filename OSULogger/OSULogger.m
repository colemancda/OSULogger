//
//  Logger.m
//  agent
//
//  Created by William Dillon on 3/31/10.
//  Copyright 2010 Oregon State University. All rights reserved.
//

#import "version.h"
#import "OSULogger.h"
#import "OSULogger/OSULogger-Swift.h"
#import <stdarg.h>

//static OSULogger *sharedLogger = nil;

void OSULog(NSString *format, ... )
{
	// Do the work of generating the NSString now, using the format
	va_list arguments;
	va_start(arguments, format);
	NSString *tempString = [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
	
	// Enqueue the actual logging until later, but keep the timestamp
	
    [[OSULogger sharedLogger] logStringObjc:tempString severity:LOG_NONE];
}

void OSULogs(NSInteger severity, NSString *format, ... )
{
	va_list arguments;
	va_start(arguments, format);
	NSString *tempString = [[NSString alloc] initWithFormat:format
												  arguments:arguments];
	va_end(arguments);
	
    [[OSULogger sharedLogger] logStringObjc:tempString severity:severity];
}
