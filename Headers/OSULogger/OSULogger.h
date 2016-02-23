/*
 * Copyright © 2015-2016 Oregon State University (CEOAS).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __OSULogger_OSULogger_h
#define __OSULogger_OSULogger_h

#include <stdbool.h>
#include <stdint.h>

typedef enum OSULogSeverity {
    kOSULogSeverityUndefined = -1,
    kOSULogSeverityDebugging,
    kOSULogSeverityInformation,
    kOSULogSeverityWarning,
    kOSULogSeverityError,
    kOSULogSeverityFatal,
    kOSULogSeverityCustom
} OSULogSeverity;

typedef struct OSUEvent {
    OSULogSeverity  severity;
    char const     *customSeverityName;
    uint64_t        timestamp;
    char const     *function;
    char const     *filename;
    int32_t         line;
    char const     *message;
} OSUEvent;

typedef void (*OSULoggerCallback)(void *info, OSUEvent const *event);

#define OSULog(severity, string) \
 _OSULog(severity, string, __func__,  __FILE__, __LINE__)
#define OSULogCustom(severity, string) \
 _OSULogCustom(severity, string, __func__,  __FILE__, __LINE__)

#ifdef __cplusplus
extern "C" {
#endif

bool OSULoggerAddCallback(OSULoggerCallback callback, void *info);

void _OSULog(OSULogSeverity severity, char const *string, char const *function,
        char const *file, int line);
void _OSULogCustom(char const *severity, char const *string, char const *function,
        char const *file, int line);

#ifdef __cplusplus
}
#endif

#endif  /* !__OSULogger_OSULogger_h */
