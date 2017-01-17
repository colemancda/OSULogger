//
//  OSULogger.h
//  OSULogger
//
//  Created by William Dillon on 2015-06-10.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

//#import <asl.h>

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
	LOG_FATAL = 5,
	LOG_ERROR = 4,
	LOG_WARN  = 3,
	LOG_INFO  = 2,
	LOG_DEBUG = 1,
	LOG_NONE  = 0
};
