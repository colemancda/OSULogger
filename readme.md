#OSULogger

[![Version](https://img.shields.io/badge/version-v0.1.2-blue.svg)](https://github.com/hpux735/OSULogger/releases/latest)
![Platforms](https://img.shields.io/badge/platforms-linux%20%7C%20Darwin-lightgrey.svg)
![Architectures](https://img.shields.io/badge/architectures-x86__64%20%7C%20arm-green.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

**OSULogger** is a relatively simple logging library the provides some unique features.  Getting started is easy, simply add us to your ```Package.swift``` file, add an import to ```OSULogger``` and log a message
```OSULogger.sharedLogger().log("Hello world.", severity: .Information)```

JSON and XML Serialization
--------------------------
OSULogger will let you load and save logs using JSON and XML.  This can be a useful feature in cases where you may have a distrbuted architecture and want to coalesce logging onto a master node, client application or monitor.  To access the logging in JSON use the ```jsonRep``` computed property, and similarly the ```xmlRep``` for the XML representation.

Observers
---------
OSULogger allows the user to supply a list of observers that will be notified when new events occur.  To add an observer, simply append a type that conforms to the ```OSULoggerObserver``` protocol to the ```observers``` array.

Unique features
---------------
- Custom severity levels.  Using the .Custom() severity, you can provide a string that indicates the importance of the message you're logging
- Log and Event equality checking.  Curious whether two logs are the same?  Want to check whether the same message appears in other logs?  Equality FTW.
- OSULogger's swift class can be used from C.  To achieve this, you'll need to provide some extra path information to the compiler, like so:

We'll use gcc in this case, but it should work with clang.  First, we include the swift library directory for the compiler using ```-L ${SWIFT_LIB_PATH}```.  Next, we have to provide the linker with that path again, but this time as a runtime path using ```-Wl,-rpath,${SWIFT_LIB_PATH}```.  Then we have the typical stuff where we provide the output filename using ```-o test```, and the input file ```../test.c```.  Finally, we have to tell the compiler and linker about OSULogger.  To do that, we provide it the artisnal, hand-crafted, C header in the Headers directory -- ```-I Headers/```, provide the project library path to the compiler using ```-L .build/debug```, tell the linker to link with OSULogger -- ```-lOSULogger``` and tell the linker where to find it at runtime ```-Wl,-rpath,`pwd`/.build/debug```.  Put it all together and you have:

```gcc -L ${SWIFT_LIB_PATH} -Wl,-rpath,${SWIFT_LIB_PATH} -o test ../test.c -I Headers/ -L .build/debug/ -lOSULogger -Wl,-rpath,`pwd`/.build/debug```

An example C program that makes use of this is as simple as this:

```
#include "OSULogger/OSULogger.h"

int main()
{
    OSULog(kOSULogSeverityInformation, "Logging from C!");
    return 0;
}
```
I also encourage you to try out the example project (along with its Makefile) in the ```CExample``` directory.
