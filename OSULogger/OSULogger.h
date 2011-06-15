//
//  Logger.h
//  agent
//
//  Created by William Dillon on 3/31/10.
//  Copyright 2010 Oregon State University. All rights reserved.
//

#import <asl.h>
#import <Cocoa/Cocoa.h>

#define LOG_FLVS(string, severity) {[[OSULogger sharedLogger] \
logString:string withFile:[NSString stringWithCString:__BASE_FILE__ encoding:NSUTF8StringEncoding] line:__LINE__ version:[NSString stringWithCString:GIT_COMMIT encoding:NSUTF8StringEncoding] andSeverity:severity];}
#define LOG_FLV(string) {[[OSULogger sharedLogger] \
logString:string withFile:__BASE_FILE__ line:__LINE__ version:[NSString stringWithCString:GIT_COMMIT encoding:NSUTF8StringEncoding] andSeverity:LOG_INFO];}
//#define OSULog(...) {[[OSULogger sharedLogger] logString:[NSString stringWithFormat:__VA_ARGS__]];}
//#define OSULogs(severity, ...) {[[OSULogger sharedLogger] logString:[NSString stringWithFormat:__VA_ARGS__] withSeverity:severity];}

void OSULog(NSString *format, ... ) NS_FORMAT_FUNCTION(1, 2);
void OSULogs(NSInteger, NSString *format, ... ) NS_FORMAT_FUNCTION(2, 3);

typedef void (^LogBlock)(void);

enum LOG_SEVERITY {
	LOG_FAIL  = 4,
	LOG_WARN  = 3,
	LOG_INFO  = 2,
	LOG_DEBUG = 1,
	LOG_NONE  = 0
};

@protocol OSULoggerDelegate <NSObject>
@optional
- (void)logUpdatedString:(NSString *)newString;
- (void)logUpdatedXML:(NSXMLElement *)newElement;

@end

@interface OSULogger : NSObject {
	
	NSXMLDocument *document;
	NSXMLElement *root;
	
	NSDateFormatter *formatter;
	
	dispatch_group_t loggerGroup;
	dispatch_queue_t loggerQueue;
	
	id <OSULoggerDelegate> delegate;

@private
	aslclient aslClient;
}

@property(readonly) NSXMLDocument *document;

+ (char *)version;
+ (OSULogger *)sharedLogger;

- (void)logString:(NSString *)string;
- (void)logString:(NSString *)string withSeverity:(NSInteger)severity;
- (void)logString:(NSString *)string
		 withFile:(NSString *)file
			 line:(NSInteger)line
		  version:(NSString *)version
	  andSeverity:(NSInteger)severity;

- (void)flush;

// This function is for class internal use only
- (void)internalLogString:(NSString *)string
			 withSeverity:(NSInteger)severity
				  andDate:(NSDate *)date;

- (NSString *)stringValue;

@property(retain) id <OSULoggerDelegate> delegate;

- (void)logUsingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
//- (void)logSeverety:(NSInteger)severity usingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (NSString *)description;

@end
