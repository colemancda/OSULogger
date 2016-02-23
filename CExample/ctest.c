/*
 *  CExample/ctest.c
 *  OSULogger
 *
 *  Created by Orlando Bassotto on 2016-02-23.
 *  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
 *  Read LICENSE in the top level directory for further licensing information.
 */

#include <OSULogger/OSULogger.h>

#include <stdio.h>
#include <stdint.h>
#include <time.h>

static void callback(void *info, OSUEvent const *event)
{
    char timebuf[64];
    char const *severity;
    struct tm tm;
    struct timespec tv;
    FILE *fp = (FILE *)info;

    tv.tv_sec  = event->timestamp / 1000000000;
    tv.tv_nsec = event->timestamp % 1000000000;
    localtime_r(&tv.tv_sec, &tm);

    switch (event->severity) {
        case kOSULogSeverityUndefined: severity = "Undefined"; break;
        case kOSULogSeverityDebugging: severity = "Debugging"; break;
        case kOSULogSeverityInformation: severity = "Information"; break;
        case kOSULogSeverityWarning: severity = "Warning"; break;
        case kOSULogSeverityError: severity = "Error"; break;
        case kOSULogSeverityFatal: severity = "Fatal"; break;
        case kOSULogSeverityCustom: severity = event->customSeverityName; break;
        default: severity = "Unknown"; break;
    }

    strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M:%S", &tm);
    fprintf(fp, "%s.%03u ", timebuf, (unsigned)(tv.tv_nsec / 1000000));
    if (event->filename != NULL && event->line != 0) {
        fprintf(fp, "[%s:%d] ", event->filename, event->line);
    }
    if (event->function != NULL) {
        fprintf(fp, "[%s] ", event->function);
    }
    fprintf(fp, "%s: %s\n", severity, event->message);
}

int main()
{
    OSULoggerAddCallback(callback, stderr);

    OSULog(kOSULogSeverityInformation, "Logging from C!");
    OSULog(kOSULogSeverityDebugging, "More logging from C!");
    OSULogCustom("CustomLevel1", "A custom log level");
    OSULogCustom(NULL, "An undefined custom log level");
    OSULog(kOSULogSeverityWarning, NULL);
    OSULogCustom("CustomLevel2", NULL);
    OSULogCustom(NULL, NULL);

    return 0;
}
